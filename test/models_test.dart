import 'package:flutter_test/flutter_test.dart';
import 'package:volumix/models/notification_settings.dart';
import 'package:volumix/models/volume_preset.dart';
import 'package:volumix/models/volume_snapshot.dart';
import 'package:volumix/models/volume_stream.dart';

void main() {
  group('VolumeStream Model Tests', () {
    test('fromMap creates correct VolumeStream instance', () {
      final map = {
        'streamType': 3,
        'name': 'Media',
        'description': 'Spotify, YouTube, Games',
        'icon': 'music_note',
        'currentVolume': 12,
        'maxVolume': 15,
        'minVolume': 0,
        'percentage': 80,
        'isMuted': false,
        'isSupported': true,
        'primaryColor': '#ADC7FF',
        'secondaryColor': '#4A8EFF',
      };

      final stream = VolumeStream.fromMap(map, isExternal: true);

      expect(stream.streamType, 3);
      expect(stream.name, 'Media');
      expect(stream.currentVolume, 12);
      expect(stream.percentage, 80);
      expect(stream.isMuted, false);
      expect(stream.isSupported, true);
      expect(stream.isExternallyChanged, true);
    });

    test('copyWith updates specific fields accurately', () {
      const stream = VolumeStream(
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
        primaryColor: '#00E5FF',
        secondaryColor: '#00DAF3',
      );

      final updated = stream.copyWith(
        currentVolume: 0,
        percentage: 0,
        isMuted: true,
      );

      expect(updated.streamType, 2);
      expect(updated.currentVolume, 0);
      expect(updated.percentage, 0);
      expect(updated.isMuted, true);
      expect(updated.name, 'Ring');
    });
  });

  group('NotificationSettings Model Tests', () {
    test('Default values are correct', () {
      const settings = NotificationSettings();
      expect(settings.showMedia, true);
      expect(settings.showRing, true);
      expect(settings.showAlarm, true);
      expect(settings.showCall, true);
      expect(settings.showPercentage, true);
      expect(settings.showMute, true);
    });

    test('Serialization roundtrip works', () {
      const settings = NotificationSettings(
        showMedia: true,
        showRing: false,
        showAlarm: true,
        showCall: true,
        showPercentage: false,
        showMute: true,
      );

      final map = settings.toMap();
      final reconstructed = NotificationSettings.fromMap(map);

      expect(reconstructed.showMedia, true);
      expect(reconstructed.showRing, false);
      expect(reconstructed.showAlarm, true);
      expect(reconstructed.showCall, true);
      expect(reconstructed.showPercentage, false);
      expect(reconstructed.showMute, true);
    });
  });

  group('VolumePreset Model Tests', () {
    test('Built-in presets are configured correctly', () {
      expect(VolumePreset.builtInPresets.length, 4);
      expect(VolumePreset.builtInPresets[0].name, '25%');
      expect(VolumePreset.builtInPresets[0].mediaPercentage, 25);
      expect(VolumePreset.builtInPresets[1].name, '50%');
      expect(VolumePreset.builtInPresets[1].mediaPercentage, 50);
      expect(VolumePreset.builtInPresets[2].name, '75%');
      expect(VolumePreset.builtInPresets[2].mediaPercentage, 75);
      expect(VolumePreset.builtInPresets[3].name, '100%');
      expect(VolumePreset.builtInPresets[3].mediaPercentage, 100);
    });

    test('Custom preset serialization roundtrip works', () {
      const preset = VolumePreset(
        id: 'custom_gaming',
        name: 'Gaming',
        mediaPercentage: 85,
        ringPercentage: 20,
        alarmPercentage: 50,
        callPercentage: 70,
        isBuiltIn: false,
      );

      final jsonStr = preset.toJson();
      final reconstructed = VolumePreset.fromJson(jsonStr);

      expect(reconstructed.id, 'custom_gaming');
      expect(reconstructed.name, 'Gaming');
      expect(reconstructed.mediaPercentage, 85);
      expect(reconstructed.ringPercentage, 20);
      expect(reconstructed.alarmPercentage, 50);
      expect(reconstructed.callPercentage, 70);
      expect(reconstructed.isBuiltIn, false);
    });
  });

  group('VolumeSnapshot Model Tests', () {
    test('Serialization and deserialization preserves stream volumes', () {
      final snapshot = VolumeSnapshot(
        streamVolumes: {3: 12, 2: 5, 4: 7},
        timestamp: DateTime(2026, 8, 30, 0, 0, 0),
      );

      final map = snapshot.toMap();
      final reconstructed = VolumeSnapshot.fromMap(map);

      expect(reconstructed.streamVolumes[3], 12);
      expect(reconstructed.streamVolumes[2], 5);
      expect(reconstructed.streamVolumes[4], 7);
      expect(reconstructed.timestamp, DateTime(2026, 8, 30, 0, 0, 0));
    });
  });
}
