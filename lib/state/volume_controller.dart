import 'dart:async';
import 'package:flutter/foundation.dart';
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

  Future<void> setStreamVolume(int streamType, int targetVolume) async {
    final index = _streams.indexWhere((s) => s.streamType == streamType);
    if (index == -1) return;

    final stream = _streams[index];
    final clamped = targetVolume.clamp(stream.minVolume, stream.maxVolume);
    final range = stream.maxVolume - stream.minVolume;
    final pct = range > 0
        ? (((clamped - stream.minVolume) / range) * 100).round().clamp(0, 100)
        : 0;

    // Optimistic UI update
    _streams[index] = stream.copyWith(
      currentVolume: clamped,
      percentage: pct,
      isMuted: clamped <= stream.minVolume,
    );
    _recalculateMasterPercentage();
    notifyListeners();

    await _repository.setVolume(streamType, clamped);
  }

  Future<void> adjustStreamVolume(int streamType, int direction) async {
    final index = _streams.indexWhere((s) => s.streamType == streamType);
    if (index == -1) return;

    final stream = _streams[index];
    final step = (stream.maxVolume * 0.05).ceil().clamp(1, stream.maxVolume);
    final newVol = direction > 0
        ? (stream.currentVolume + step).clamp(stream.minVolume, stream.maxVolume)
        : (stream.currentVolume - step).clamp(stream.minVolume, stream.maxVolume);

    await setStreamVolume(streamType, newVol);
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

  Future<void> setMasterVolume(int percentage) async {
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

    await _repository.setMasterVolume(clampedPct);
  }

  Future<void> muteAll() async {
    // Snapshot current state
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
    super.dispose();
  }
}

extension VolumeStreamListFilter on List<VolumeStream> {
  List<VolumeStream> filterSupported() =>
      where((s) => s.isSupported).toList();
}
