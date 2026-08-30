import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/volume_preset.dart';
import '../models/volume_stream.dart';
import '../repositories/volume_repository.dart';

class VolumeController extends ChangeNotifier {
  final VolumeRepository _repository;

  List<VolumeStream> _streams = [];
  int _masterPercentage = 0;
  bool _hasSavedSnapshot = false;
  bool _isLoading = true;
  String? _errorMessage;

  bool _isExternalChangeBannerVisible = false;
  String _externalChangeStreamName = '';
  Timer? _externalBannerTimer;

  StreamSubscription? _eventsSubscription;

  // Platform call coalescing timers
  final Map<int, Timer> _throttledStreamTimers = {};
  final Map<int, int> _pendingStreamVolumes = {};
  Timer? _throttledMasterTimer;
  int? _pendingMasterPercentage;

  VolumeController(this._repository);

  List<VolumeStream> get streams => _streams;
  int get masterPercentage => _masterPercentage;
  bool get hasSavedSnapshot => _hasSavedSnapshot;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isExternalChangeBannerVisible => _isExternalChangeBannerVisible;
  String get externalChangeStreamName => _externalChangeStreamName;

  bool get isAllMuted {
    final supported = _streams.filterSupported();
    if (supported.isEmpty) return false;
    return supported.every((s) => s.isMuted || s.currentVolume <= s.minVolume);
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final initialStreams = await _repository.fetchStreams();
      final master = await _repository.fetchMasterPercentage();
      final hasSnap = await _repository.hasSavedSnapshot();

      _streams = initialStreams;
      _masterPercentage = master;
      _hasSavedSnapshot = hasSnap;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load system volume streams';
      notifyListeners();
    }

    _eventsSubscription = _repository.volumeEventsStream.listen((event) {
      _masterPercentage = event.masterPercentage;
      _hasSavedSnapshot = event.hasSavedSnapshot;

      if (event.streams.isNotEmpty) {
        _streams = event.streams;
      }

      if (event.isExternal) {
        _showExternalBanner('Hardware Volume Button / External System');
      }

      notifyListeners();
    });
  }

  void _showExternalBanner(String source) {
    _externalChangeStreamName = source;
    _isExternalChangeBannerVisible = true;
    notifyListeners();

    _externalBannerTimer?.cancel();
    _externalBannerTimer = Timer(const Duration(seconds: 3), () {
      _isExternalChangeBannerVisible = false;
      notifyListeners();
    });
  }

  Future<void> setStreamPercentage(
    int streamType,
    int percentage, {
    bool isDragging = false,
  }) async {
    final index = _streams.indexWhere((s) => s.streamType == streamType);
    if (index == -1) return;

    final stream = _streams[index];
    final clampedPct = percentage.clamp(0, 100);
    final range = stream.maxVolume - stream.minVolume;
    final targetVolume = range > 0
        ? (stream.minVolume + ((clampedPct / 100.0) * range).round())
            .clamp(stream.minVolume, stream.maxVolume)
        : stream.minVolume;

    // Immediate UI update with exact 1% percentage
    _streams[index] = stream.copyWith(
      currentVolume: targetVolume,
      percentage: clampedPct,
      isMuted: clampedPct == 0 || targetVolume <= stream.minVolume,
    );
    _recalculateMasterPercentage();
    notifyListeners();

    if (isDragging) {
      _pendingStreamVolumes[streamType] = targetVolume;
      if (_throttledStreamTimers[streamType] == null ||
          !_throttledStreamTimers[streamType]!.isActive) {
        _throttledStreamTimers[streamType] =
            Timer(const Duration(milliseconds: 35), () async {
          final pending = _pendingStreamVolumes.remove(streamType);
          if (pending != null) {
            await _repository.setVolume(streamType, pending);
          }
        });
      }
    } else {
      _throttledStreamTimers[streamType]?.cancel();
      _pendingStreamVolumes.remove(streamType);
      await _repository.setVolume(streamType, targetVolume);
    }
  }

  Future<void> setStreamVolume(
    int streamType,
    int targetVolume, {
    bool isDragging = false,
  }) async {
    final index = _streams.indexWhere((s) => s.streamType == streamType);
    if (index == -1) return;

    final stream = _streams[index];
    final clamped = targetVolume.clamp(stream.minVolume, stream.maxVolume);
    final range = stream.maxVolume - stream.minVolume;
    final pct = range > 0
        ? (((clamped - stream.minVolume) / range) * 100).round().clamp(0, 100)
        : 0;

    // Immediate UI update
    _streams[index] = stream.copyWith(
      currentVolume: clamped,
      percentage: pct,
      isMuted: clamped <= stream.minVolume,
    );
    _recalculateMasterPercentage();
    notifyListeners();

    if (isDragging) {
      // Coalesce native platform call during continuous dragging
      _pendingStreamVolumes[streamType] = clamped;
      if (_throttledStreamTimers[streamType] == null ||
          !_throttledStreamTimers[streamType]!.isActive) {
        _throttledStreamTimers[streamType] =
            Timer(const Duration(milliseconds: 35), () async {
          final pending = _pendingStreamVolumes.remove(streamType);
          if (pending != null) {
            await _repository.setVolume(streamType, pending);
          }
        });
      }
    } else {
      // Direct update when tapping or dragging ends
      _throttledStreamTimers[streamType]?.cancel();
      _pendingStreamVolumes.remove(streamType);
      await _repository.setVolume(streamType, clamped);
    }
  }

  Future<void> adjustStreamVolume(int streamType, int direction) async {
    final index = _streams.indexWhere((s) => s.streamType == streamType);
    if (index == -1) return;

    final stream = _streams[index];
    final newPct = direction > 0
        ? (stream.percentage + 5).clamp(0, 100)
        : (stream.percentage - 5).clamp(0, 100);

    await setStreamPercentage(streamType, newPct);
  }

  Future<void> toggleStreamMute(int streamType) async {
    final index = _streams.indexWhere((s) => s.streamType == streamType);
    if (index == -1) return;

    final stream = _streams[index];
    final shouldMute = !stream.isMuted && stream.currentVolume > stream.minVolume;

    if (shouldMute) {
      await setStreamVolume(streamType, stream.minVolume);
      await _repository.setStreamMute(streamType, true);
    } else {
      final restoreVol = (stream.maxVolume * 0.5).round().clamp(1, stream.maxVolume);
      await setStreamVolume(streamType, restoreVol);
      await _repository.setStreamMute(streamType, false);
    }
  }

  Future<void> setMasterVolume(int percentage, {bool isDragging = false}) async {
    final clampedPct = percentage.clamp(0, 100);
    _masterPercentage = clampedPct;

    // Optimistically update supported streams
    for (int i = 0; i < _streams.length; i++) {
      final stream = _streams[i];
      if (stream.isSupported) {
        final range = stream.maxVolume - stream.minVolume;
        if (range > 0) {
          final target = stream.minVolume +
              ((clampedPct / 100.0) * range).round().clamp(0, range);
          _streams[i] = stream.copyWith(
            currentVolume: target,
            percentage: clampedPct,
            isMuted: clampedPct == 0,
          );
        }
      }
    }
    notifyListeners();

    if (isDragging) {
      _pendingMasterPercentage = clampedPct;
      if (_throttledMasterTimer == null || !_throttledMasterTimer!.isActive) {
        _throttledMasterTimer = Timer(const Duration(milliseconds: 35), () async {
          final pending = _pendingMasterPercentage;
          if (pending != null) {
            await _repository.setMasterVolume(pending);
          }
        });
      }
    } else {
      _throttledMasterTimer?.cancel();
      _pendingMasterPercentage = null;
      await _repository.setMasterVolume(clampedPct);
    }
  }

  Future<bool> applyPreset(VolumePreset preset) async {
    final Map<int, int> streamVolumeMap = {};

    for (int i = 0; i < _streams.length; i++) {
      final stream = _streams[i];
      if (!stream.isSupported) continue;

      int targetPct;
      switch (stream.streamType) {
        case 3: // Media
          targetPct = preset.mediaPercentage;
          break;
        case 2: // Ring
          targetPct = preset.ringPercentage;
          break;
        case 4: // Alarm
          targetPct = preset.alarmPercentage;
          break;
        case 0: // Voice Call
          targetPct = preset.callPercentage;
          break;
        default:
          targetPct = preset.mediaPercentage;
          break;
      }

      final range = stream.maxVolume - stream.minVolume;
      final targetVol = range > 0
          ? (stream.minVolume + ((targetPct / 100.0) * range).round())
              .clamp(stream.minVolume, stream.maxVolume)
          : stream.minVolume;

      streamVolumeMap[stream.streamType] = targetVol;

      _streams[i] = stream.copyWith(
        currentVolume: targetVol,
        percentage: targetPct,
        isMuted: targetVol <= stream.minVolume,
      );
    }

    _recalculateMasterPercentage();
    notifyListeners();

    return await _repository.applyStreamVolumes(streamVolumeMap);
  }

  Future<void> muteAll() async {
    await _repository.muteAll(_streams);

    _masterPercentage = 0;
    for (int i = 0; i < _streams.length; i++) {
      final stream = _streams[i];
      if (stream.isSupported) {
        _streams[i] = stream.copyWith(
          currentVolume: stream.minVolume,
          percentage: 0,
          isMuted: true,
        );
      }
    }
    _hasSavedSnapshot = true;
    notifyListeners();
  }

  Future<void> restoreAll() async {
    final ok = await _repository.restoreAll();
    if (ok) {
      _hasSavedSnapshot = false;
      final refreshed = await _repository.fetchStreams();
      _streams = refreshed;
      _recalculateMasterPercentage();
      notifyListeners();
    }
  }

  Future<void> resetDefaults() async {
    await _repository.resetDefaults();
    _hasSavedSnapshot = false;
    final refreshed = await _repository.fetchStreams();
    _streams = refreshed;
    _recalculateMasterPercentage();
    notifyListeners();
  }

  void _recalculateMasterPercentage() {
    final supported = _streams.filterSupported();
    if (supported.isEmpty) {
      _masterPercentage = 0;
      return;
    }
    final avg = supported.map((s) => s.percentage).reduce((a, b) => a + b) /
        supported.length;
    _masterPercentage = avg.round().clamp(0, 100);
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _externalBannerTimer?.cancel();
    _throttledMasterTimer?.cancel();
    for (final timer in _throttledStreamTimers.values) {
      timer.cancel();
    }
    _throttledStreamTimers.clear();
    super.dispose();
  }
}

extension VolumeStreamListFilter on List<VolumeStream> {
  List<VolumeStream> filterSupported() =>
      where((s) => s.isSupported).toList();
}
