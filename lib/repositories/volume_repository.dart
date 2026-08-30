import '../models/notification_settings.dart';
import '../models/volume_preset.dart';
import '../models/volume_snapshot.dart';
import '../models/volume_stream.dart';
import '../services/preferences_service.dart';
import '../services/volume_platform_service.dart';

class VolumeRepository {
  final VolumePlatformService _platformService;
  final PreferencesService _preferencesService;

  VolumeRepository({
    required VolumePlatformService platformService,
    required PreferencesService preferencesService,
  })  : _platformService = platformService,
        _preferencesService = preferencesService;

  Stream<VolumeUpdateEvent> get volumeEventsStream =>
      _platformService.volumeEvents;

  Future<List<VolumeStream>> fetchStreams() async {
    return await _platformService.getStreams();
  }

  Future<int> fetchMasterPercentage() async {
    return await _platformService.getMasterPercentage();
  }

  Future<bool> setVolume(int streamType, int volume) async {
    return await _platformService.setVolume(streamType, volume);
  }

  Future<bool> setMasterVolume(int percentage) async {
    return await _platformService.setMasterVolume(percentage);
  }

  Future<bool> applyStreamVolumes(Map<int, int> streamVolumes) async {
    return await _platformService.applyStreamVolumes(streamVolumes);
  }

  Future<bool> adjustStreamVolume(int streamType, int direction) async {
    return await _platformService.adjustStreamVolume(streamType, direction);
  }

  Future<bool> setStreamMute(int streamType, bool mute) async {
    return await _platformService.setStreamMute(streamType, mute);
  }

  Future<bool> muteAll(List<VolumeStream> currentStreams) async {
    // Snapshot non-zero volumes to preferences
    final map = <int, int>{};
    for (final stream in currentStreams) {
      if (stream.isSupported && stream.currentVolume > 0) {
        map[stream.streamType] = stream.currentVolume;
      }
    }
    if (map.isNotEmpty) {
      await _preferencesService.saveSnapshot(
        VolumeSnapshot(streamVolumes: map, timestamp: DateTime.now()),
      );
    }

    return await _platformService.muteAll();
  }

  Future<bool> restoreAll() async {
    final ok = await _platformService.restoreAll();
    if (ok) {
      await _preferencesService.clearSnapshot();
    }
    return ok;
  }

  Future<bool> hasSavedSnapshot() async {
    final nativeHas = await _platformService.hasSavedSnapshot();
    final prefHas = _preferencesService.getSavedSnapshot() != null;
    return nativeHas || prefHas;
  }

  Future<bool> resetDefaults() async {
    final ok = await _platformService.resetDefaults();
    await _preferencesService.clearSnapshot();
    return ok;
  }

  Future<bool> checkNotificationPermission() async {
    return await _platformService.isNotificationPermissionGranted();
  }

  Future<void> requestNotificationPermission() async {
    await _platformService.requestNotificationPermission();
  }

  Future<void> setPersistentNotificationEnabled(bool enabled) async {
    await _preferencesService.setPersistentNotificationEnabled(enabled);
    await _platformService.setPersistentNotificationEnabled(enabled);
  }

  Future<void> updateNotificationControls(NotificationSettings settings) async {
    await _preferencesService.saveNotificationSettings(settings);
    await _platformService.updateNotificationControls(settings);
  }

  Future<bool> checkDndAccess() async {
    return await _platformService.isDndAccessGranted();
  }

  Future<void> openDndSettings() async {
    await _platformService.openDndSettings();
  }

  bool isAmoledMode() => _preferencesService.isAmoledMode;
  Future<void> setAmoledMode(bool value) =>
      _preferencesService.setAmoledMode(value);

  bool isPersistentNotificationEnabled() =>
      _preferencesService.isPersistentNotificationEnabled;

  bool isFirstRunCompleted() => _preferencesService.isFirstRunCompleted;
  Future<void> setFirstRunCompleted(bool value) =>
      _preferencesService.setFirstRunCompleted(value);

  NotificationSettings getNotificationSettings() =>
      _preferencesService.getNotificationSettings();

  List<VolumePreset> getCustomPresets() =>
      _preferencesService.getCustomPresets();

  Future<void> saveCustomPresets(List<VolumePreset> presets) =>
      _preferencesService.saveCustomPresets(presets);
}
