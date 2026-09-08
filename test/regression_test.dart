import 'package:flutter_test/flutter_test.dart';
import 'package:volumix/models/volume_preset.dart';
import 'package:volumix/repositories/volume_repository.dart';
import 'package:volumix/state/volume_controller.dart';
import 'package:volumix/models/volume_stream.dart';
import 'volume_controller_test.dart';

void main() {
  group('VolumeController Master Percentage Consistency', () {
    // Regression test for Bug #6: _recalculateMasterPercentage averages all
    // streams but native side uses only priority streams (Media/Ring/Notif/Alarm).
    // Call (0) and System (1) must be excluded for consistency.
    test('excludes Call and System streams from master percentage average', () async {
      final platformService = FakeVolumePlatformService();
      platformService.mockStreams = [
        // Priority stream: Media 100%
        const VolumeStream(
          streamType: 3,
          name: 'Media',
          description: 'Spotify, YouTube, Games',
          icon: 'music_note',
          currentVolume: 15,
          maxVolume: 15,
          minVolume: 0,
          percentage: 100,
          isMuted: false,
          isSupported: true,
          primaryColor: '#ADC7FF',
          secondaryColor: '#4A8EFF',
        ),
        // Priority stream: Ring 0%
        const VolumeStream(
          streamType: 2,
          name: 'Ring',
          description: 'Calls & Alerts',
          icon: 'notifications_active',
          currentVolume: 0,
          maxVolume: 7,
          minVolume: 0,
          percentage: 0,
          isMuted: true,
          isSupported: true,
          primaryColor: '#C3F5FF',
          secondaryColor: '#00E5FF',
        ),
        // Non-priority: Call 100% - should be EXCLUDED
        const VolumeStream(
          streamType: 0,
          name: 'Call',
          description: 'In-call Voice',
          icon: 'phone_in_talk',
          currentVolume: 5,
          maxVolume: 5,
          minVolume: 0,
          percentage: 100,
          isMuted: false,
          isSupported: true,
          primaryColor: '#BAC9CC',
          secondaryColor: '#849396',
        ),
        // Non-priority: System 100% - should be EXCLUDED
        const VolumeStream(
          streamType: 1,
          name: 'System',
          description: 'Touch & Feedback',
          icon: 'tune',
          currentVolume: 7,
          maxVolume: 7,
          minVolume: 0,
          percentage: 100,
          isMuted: false,
          isSupported: true,
          primaryColor: '#849396',
          secondaryColor: '#BAC9CC',
        ),
      ];
      platformService.mockMaster = 50;

      final repository = VolumeRepository(
        platformService: platformService,
        preferencesService: FakePreferencesService(),
      );
      final controller = VolumeController(repository);
      await controller.init();

      // Media=100%, Ring=0% → average of priority streams = 50%.
      // If Call/System were incorrectly included, average would be 75%.
      expect(controller.masterPercentage, 50);
    });
  });

  group('VolumeController adjustStreamVolume', () {
    // Regression test for Bug #4: adjustStreamVolume must call the native API
    // to advance by actual hardware step, not a hardcoded 5% increment.
    test('adjustStreamVolume delegates to platform and updates stream by hardware step', () async {
      final platformService = FakeVolumePlatformService();
      platformService.mockStreams = [
        const VolumeStream(
          streamType: 3,
          name: 'Media',
          description: 'Spotify, YouTube, Games',
          icon: 'music_note',
          currentVolume: 10,
          maxVolume: 15,
          minVolume: 0,
          percentage: 67,
          isMuted: false,
          isSupported: true,
          primaryColor: '#ADC7FF',
          secondaryColor: '#4A8EFF',
        ),
      ];

      final repository = VolumeRepository(
        platformService: platformService,
        preferencesService: FakePreferencesService(),
      );
      final controller = VolumeController(repository);
      await controller.init();

      // Before: percentage is 67% (10/15)
      expect(controller.streams.first.percentage, 67);

      // Adjust +1 step
      await controller.adjustStreamVolume(3, 1);

      // The fake's adjustStreamVolume increments currentVolume by 1 (max=15),
      // so volume becomes 11, percentage = 11/15 ≈ 73%
      expect(controller.streams.first.currentVolume, 11);

      // Adjust -1 step
      await controller.adjustStreamVolume(3, -1);
      expect(controller.streams.first.currentVolume, 10);
    });
  });

  group('toggleStreamMute unmute restore logic', () {
    // Regression test for Bug #5/Snapshot restore:
    // unmute must restore to a value > minVolume, and must account for minVolume offset.
    test('unmute restores to a volume above minVolume', () async {
      final platformService = FakeVolumePlatformService();
      // Voice call has minVolume 1
      platformService.mockStreams = [
        const VolumeStream(
          streamType: 0,
          name: 'Call',
          description: 'In-call Voice',
          icon: 'phone_in_talk',
          currentVolume: 1,
          maxVolume: 5,
          minVolume: 1,
          percentage: 0,
          isMuted: true,
          isSupported: true,
          primaryColor: '#BAC9CC',
          secondaryColor: '#849396',
        ),
      ];

      final repository = VolumeRepository(
        platformService: platformService,
        preferencesService: FakePreferencesService(),
      );
      final controller = VolumeController(repository);
      await controller.init();

      await controller.toggleStreamMute(0);

      // Restore should be above minVolume (1)
      expect(controller.streams.first.currentVolume, greaterThan(1));
      expect(controller.streams.first.isMuted, false);
    });
  });

  group('VolumePreset built-in protection', () {
    test('built-in presets cannot be modified', () {
      final preset = VolumePreset.builtInPresets[0];
      expect(preset.isBuiltIn, true);
      expect(preset.id, 'builtin_25');
    });
  });

  group('VolumeRepository restoreAll resilience', () {
    // Regression test for Bug #8: if the native snapshot is lost (e.g. process
    // killed between the Dart-side and native snapshot writes), restoreAll must
    // still restore the user's saved volumes from the Dart-side snapshot rather
    // than falling back to system defaults and clearing the valid snapshot.
    test('restores from Dart-side snapshot when native snapshot is missing', () async {
      final platformService = FakeVolumePlatformService();
      final preferencesService = FakePreferencesService();
      final repository = VolumeRepository(
        platformService: platformService,
        preferencesService: preferencesService,
      );

      // Mute from a known state: Media=12, Ring=4
      await repository.muteAll([
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
      ]);

      // Dart-side snapshot must exist now.
      expect(preferencesService.getSavedSnapshot(), isNotNull);
      // Simulate a process kill that lost the native side snapshot only.
      expect(platformService.mockHasSnapshot, true);
      platformService.mockHasSnapshot = false;

      // Restore should apply the Dart-side snapshot volumes.
      final ok = await repository.restoreAll();
      expect(ok, true);

      // Both snapshots must be cleared and volumes restored.
      expect(preferencesService.getSavedSnapshot(), isNull);
      expect(await platformService.hasSavedSnapshot(), false);
      expect(platformService.mockStreams
          .firstWhere((s) => s.streamType == 3).currentVolume, 12);
      expect(platformService.mockStreams
          .firstWhere((s) => s.streamType == 2).currentVolume, 4);
    });
  });
}
