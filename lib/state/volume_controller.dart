import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/volume_preset.dart';
import '../models/volume_stream.dart';
import '../repositories/volume_repository.dart';

class MuteSnapshotState {
  final bool isAllMuted;
  final bool hasSavedSnapshot;

  const MuteSnapshotState({
    required this.isAllMuted,
    required this.hasSavedSnapshot,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuteSnapshotState &&
          runtimeType == other.runtimeType &&
          isAllMuted == other.isAllMuted &&
          hasSavedSnapshot == other.hasSavedSnapshot;

  @override
  int get hashCode => Object.hash(isAllMuted, hasSavedSnapshot);
}

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

  // Granular state notifiers for zero full-screen rebuilds
  final Map<int, ValueNotifier<VolumeStream>> _streamNotifiers = {};
  late final ValueNotifier<MuteSnapshotState> muteSnapshotNotifier =
      ValueNotifier<MuteSnapshotState>(
    MuteSnapshotState(
      isAllMuted: isAllMuted,
      hasSavedSnapshot: _hasSavedSnapshot,
    ),
  );

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

  ValueListenable<VolumeStream> getStreamNotifier(VolumeStream stream) {
    var notifier = _streamNotifiers[stream.streamType];
    if (notifier == null) {
      notifier = ValueNotifier<VolumeStream>(stream);
      _streamNotifiers[stream.streamType] = notifier;
    }
    return notifier;
  }

  void _updateStreamNotifier(VolumeStream stream) {
    final notifier = _streamNotifiers[stream.streamType];
    if (notifier != null) {
      if (notifier.value != stream) {
        notifier.value = stream;
      }
    } else {
      _streamNotifiers[stream.streamType] = ValueNotifier<VolumeStream>(stream);
    }
  }

  void _updateMuteSnapshotNotifier() {
    final state = MuteSnapshotState(
      isAllMuted: isAllMuted,
      hasSavedSnapshot: _hasSavedSnapshot,
    );
    if (muteSnapshotNotifier.value != state) {
      muteSnapshotNotifier.value = state;
    }
  }

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
      for (final s in initialStreams) {
        _updateStreamNotifier(s);
      }
      _masterPercentage = master;
      _hasSavedSnapshot = hasSnap;
      _updateMuteSnapshotNotifier();
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
        for (final s in event.streams) {
          _updateStreamNotifier(s);
        }
      }

      if (event.isExternal) {
        _showExternalBanner('Hardware Volume Button / External System');
      }

      _updateMuteSnapshotNotifier();
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

    // Immediate in-memory update with exact 1% percentage
    final updatedStream = stream.copyWith(
      currentVolume: targetVolume,
      percentage: clampedPct,
      isMuted: clampedPct == 0 || targetVolume <= stream.minVolume,
    );
    _streams[index] = updatedStream;
    _updateStreamNotifier(updatedStream);
    _recalculateMasterPercentage();
    _updateMuteSnapshotNotifier();

    if (isDragging) {
      // Coalesce native platform call during continuous dragging
      _pendingStreamVolumes[streamType] = targetVolume;
      if (_throttledStreamTimers[streamType] == null ||
          !_throttledStreamTimers[streamType]!.isActive) {
        _throttledStreamTimers[streamType] =
            Timer(const Duration(milliseconds: 40), () async {
          final pending = _pendingStreamVolumes.remove(streamType);
          if (pending != null) {
            await _repository.setVolume(streamType, pending);
          }
        });
      }
    } else {
      // Direct update and notify listeners on drag end/tap
      _throttledStreamTimers[streamType]?.cancel();
      _pendingStreamVolumes.remove(streamType);
      notifyListeners();
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
    final updatedStream = stream.copyWith(
      currentVolume: clamped,
      percentage: pct,
      isMuted: clamped <= stream.minVolume,
    );
    _streams[index] = updatedStream;
    _updateStreamNotifier(updatedStream);
    _recalculateMasterPercentage();
    _updateMuteSnapshotNotifier();
    notifyListeners();

    if (isDragging) {
      // Coalesce native platform call during continuous dragging
      _pendingStreamVolumes[streamType] = clamped;
      if (_throttledStreamTimers[streamType] == null ||
          !_throttledStreamTimers[streamType]!.isActive) {
        _throttledStreamTimers[streamType] =
            Timer(const Duration(milliseconds: 40), () async {
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

    await _repository.adjustStreamVolume(streamType, direction);
    final refreshed = await _repository.fetchStreams();
    _streams = refreshed;
    for (final s in refreshed) {
      _updateStreamNotifier(s);
    }
    _recalculateMasterPercentage();
    _updateMuteSnapshotNotifier();
    notifyListeners();
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
      final range = stream.maxVolume - stream.minVolume;
      final restoreVol = (stream.minVolume + (range * 0.5).round())
          .clamp(stream.minVolume + 1, stream.maxVolume);
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
          final updated = stream.copyWith(
            currentVolume: target,
            percentage: clampedPct,
            isMuted: clampedPct == 0,
          );
          _streams[i] = updated;
          _updateStreamNotifier(updated);
        }
      }
    }
    _updateMuteSnapshotNotifier();
    notifyListeners();

    if (isDragging) {
      _pendingMasterPercentage = clampedPct;
      if (_throttledMasterTimer == null || !_throttledMasterTimer!.isActive) {
        _throttledMasterTimer = Timer(const Duration(milliseconds: 40), () async {
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

      final updated = stream.copyWith(
        currentVolume: targetVol,
        percentage: targetPct,
        isMuted: targetVol <= stream.minVolume,
      );
      _streams[i] = updated;
      _updateStreamNotifier(updated);
    }

    _recalculateMasterPercentage();
    _updateMuteSnapshotNotifier();
    notifyListeners();

    return await _repository.applyStreamVolumes(streamVolumeMap);
  }

  Future<void> muteAll() async {
    await _repository.muteAll(_streams);

    _masterPercentage = 0;
    for (int i = 0; i < _streams.length; i++) {
      final stream = _streams[i];
      if (stream.isSupported) {
        final updated = stream.copyWith(
          currentVolume: stream.minVolume,
          percentage: 0,
          isMuted: true,
        );
        _streams[i] = updated;
        _updateStreamNotifier(updated);
      }
    }
    _hasSavedSnapshot = true;
    _updateMuteSnapshotNotifier();
    notifyListeners();
  }

  Future<void> restoreAll() async {
    final ok = await _repository.restoreAll();
    if (ok) {
      _hasSavedSnapshot = false;
      final refreshed = await _repository.fetchStreams();
      _streams = refreshed;
      for (final s in refreshed) {
        _updateStreamNotifier(s);
      }
      _recalculateMasterPercentage();
      _updateMuteSnapshotNotifier();
      notifyListeners();
    }
  }

  Future<void> resetDefaults() async {
    await _repository.resetDefaults();
    _hasSavedSnapshot = false;
    final refreshed = await _repository.fetchStreams();
    _streams = refreshed;
    for (final s in refreshed) {
      _updateStreamNotifier(s);
    }
    _recalculateMasterPercentage();
    _updateMuteSnapshotNotifier();
    notifyListeners();
  }

  void _recalculateMasterPercentage() {
    final supported = _streams.filterSupported();
    if (supported.isEmpty) {
      _masterPercentage = 0;
      return;
    }

    const priorityTypes = {3, 2, 5, 4};
    final priorityStreams = supported.where((s) => priorityTypes.contains(s.streamType)).toList();
    final targetList = priorityStreams.isNotEmpty ? priorityStreams : supported;
    final avg = targetList.map((s) => s.percentage).reduce((a, b) => a + b) /
        targetList.length;
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
    for (final notifier in _streamNotifiers.values) {
      notifier.dispose();
    }
    _streamNotifiers.clear();
    muteSnapshotNotifier.dispose();
    super.dispose();
  }
}

extension VolumeStreamListFilter on List<VolumeStream> {
  List<VolumeStream> filterSupported() =>
      where((s) => s.isSupported).toList();
}
