import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:volumix/models/notification_settings.dart';
import 'package:volumix/models/volume_snapshot.dart';
import 'package:volumix/models/volume_stream.dart';
import 'package:volumix/repositories/volume_repository.dart';
import 'package:volumix/services/preferences_service.dart';
import 'package:volumix/services/volume_platform_service.dart';
import 'package:volumix/state/volume_controller.dart';

class FakeVolumePlatformService extends Fake implements VolumePlatformService {
  final _eventsController = StreamController<VolumeUpdateEvent>.broadcast();

  List<VolumeStream> mockStreams = [
    const VolumeStream(
      streamType: 3,
      name: 'Media',
      description: 'Spotify, YouTube, Games',
      icon: 'music_note',
      currentVolume: 12,
      maxVolume: 15,
      minVolume: 0,
      percentage: 80,
      isMuted: false,
      isSupported: true,
      primaryColor: '#ADC7FF',
      secondaryColor: '#4A8EFF',
    ),
    const VolumeStream(
      streamType: 2,
      name: 'Ring',
      description: 'Calls & Alerts',
      icon: 'notifications_active',
      currentVolume: 4,
      maxVolume: 7,
      minVolume: 0,
      percentage: 57,
      isMuted: false,
      isSupported: true,
      primaryColor: '#C3F5FF',
      secondaryColor: '#00E5FF',
    ),
  ];

  int mockMaster = 68;
  bool mockHasSnapshot = false;

  @override
  Stream<VolumeUpdateEvent> get volumeEvents => _eventsController.stream;

  @override
  Future<List<VolumeStream>> getStreams() async => mockStreams;

  @override
  Future<int> getMasterPercentage() async => mockMaster;

  @override
  Future<bool> setVolume(int streamType, int volume) async {
    final idx = mockStreams.indexWhere((s) => s.streamType == streamType);
    if (idx != -1) {
      final s = mockStreams[idx];
      mockStreams[idx] = s.copyWith(currentVolume: volume);
    }
    return true;
  }

  @override
  Future<bool> setMasterVolume(int percentage) async {
    mockMaster = percentage;
    return true;
  }

  @override
  Future<bool> setStreamMute(int streamType, bool mute) async => true;

  @override
  Future<bool> muteAll() async {
    mockHasSnapshot = true;
    for (int i = 0; i < mockStreams.length; i++) {
      mockStreams[i] = mockStreams[i].copyWith(currentVolume: 0, percentage: 0, isMuted: true);
    }
    return true;
  }

  @override
  Future<bool> restoreAll() async {
    mockHasSnapshot = false;
    return true;
  }

  @override
  Future<bool> hasSavedSnapshot() async => mockHasSnapshot;

  @override
  Future<bool> resetDefaults() async => true;

  @override
  Future<bool> isNotificationPermissionGranted() async => true;

  @override
  Future<void> requestNotificationPermission() async {}

  @override
  Future<void> setPersistentNotificationEnabled(bool enabled) async {}

  @override
  Future<void> updateNotificationControls(NotificationSettings settings) async {}

  @override
  Future<bool> isDndAccessGranted() async => true;

  @override
  Future<void> openDndSettings() async {}
}

class FakePreferencesService extends Fake implements PreferencesService {
  VolumeSnapshot? _snapshot;
  bool _amoled = true;

  @override
  bool get isAmoledMode => _amoled;

  @override
  Future<void> setAmoledMode(bool value) async => _amoled = value;

  @override
  bool get isPersistentNotificationEnabled => true;

  @override
  Future<void> setPersistentNotificationEnabled(bool value) async {}

  @override
  bool get isFirstRunCompleted => true;

  @override
  Future<void> setFirstRunCompleted(bool value) async {}

  @override
  NotificationSettings getNotificationSettings() => const NotificationSettings();

  @override
  VolumeSnapshot? getSavedSnapshot() => _snapshot;

  @override
  Future<void> saveSnapshot(VolumeSnapshot snapshot) async => _snapshot = snapshot;

  @override
  Future<void> clearSnapshot() async => _snapshot = null;
}

void main() {
  late FakeVolumePlatformService platformService;
  late FakePreferencesService preferencesService;
  late VolumeRepository repository;
  late VolumeController controller;

  setUp(() {
    platformService = FakeVolumePlatformService();
    preferencesService = FakePreferencesService();
    repository = VolumeRepository(
      platformService: platformService,
      preferencesService: preferencesService,
    );
    controller = VolumeController(repository);
  });

  test('VolumeController initializes streams and master percentage', () async {
    await controller.init();

    expect(controller.isLoading, false);
    expect(controller.streams.length, 2);
    expect(controller.masterPercentage, 68);
    expect(controller.streams.first.name, 'Media');
  });

  test('setStreamVolume updates stream volume optimistically and recalculates master', () async {
    await controller.init();

    await controller.setStreamVolume(3, 15);

    expect(controller.streams.first.currentVolume, 15);
    expect(controller.streams.first.percentage, 100);
  });

  test('muteAll mutes all supported streams and sets hasSavedSnapshot', () async {
    await controller.init();

    await controller.muteAll();

    expect(controller.isAllMuted, true);
    expect(controller.masterPercentage, 0);
    expect(controller.hasSavedSnapshot, true);
  });
}
