import 'dart:async';
import 'package:flutter/services.dart';
import '../models/notification_settings.dart';
import '../models/volume_stream.dart';

class VolumeUpdateEvent {
  final bool isExternal;
  final int masterPercentage;
  final bool hasSavedSnapshot;
  final List<VolumeStream> streams;

  const VolumeUpdateEvent({
    required this.isExternal,
    required this.masterPercentage,
    required this.hasSavedSnapshot,
    required this.streams,
  });
}

class VolumePlatformService {
  static const MethodChannel _methodChannel =
      MethodChannel('com.anant.volumix/volume_methods');
  static const EventChannel _eventChannel =
      EventChannel('com.anant.volumix/volume_events');

  Stream<VolumeUpdateEvent>? _eventsStream;

  Stream<VolumeUpdateEvent> get volumeEvents {
    _eventsStream ??= _eventChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        final isExternal = event['isExternal'] as bool? ?? false;
        final masterPercentage = (event['masterPercentage'] as num?)?.toInt() ?? 0;
        final hasSavedSnapshot = event['hasSavedSnapshot'] as bool? ?? false;
        final rawStreams = event['streams'] as List<dynamic>? ?? [];

        final streams = rawStreams.map((item) {
          if (item is Map) {
            return VolumeStream.fromMap(item, isExternal: isExternal);
          }
          return const VolumeStream(
            streamType: 3,
            name: 'Media',
            description: '',
            icon: 'music_note',
            currentVolume: 0,
            maxVolume: 15,
            minVolume: 0,
            percentage: 0,
            isMuted: false,
            isSupported: true,
            primaryColor: '#00E5FF',
            secondaryColor: '#4A8EFF',
          );
        }).toList();

        return VolumeUpdateEvent(
          isExternal: isExternal,
          masterPercentage: masterPercentage,
          hasSavedSnapshot: hasSavedSnapshot,
          streams: streams,
        );
      }
      return const VolumeUpdateEvent(
        isExternal: false,
        masterPercentage: 0,
        hasSavedSnapshot: false,
        streams: [],
      );
    });
    return _eventsStream!;
  }

  static final List<VolumeStream> _defaultStreams = [
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
      primaryColor: '#00E5FF',
      secondaryColor: '#4A8EFF',
    ),
    const VolumeStream(
      streamType: 2,
      name: 'Ring',
      description: 'Calls & Alerts',
      icon: 'notifications_active',
      currentVolume: 5,
      maxVolume: 7,
      minVolume: 0,
      percentage: 71,
      isMuted: false,
      isSupported: true,
      primaryColor: '#00E5FF',
      secondaryColor: '#00DAF3',
    ),
    const VolumeStream(
      streamType: 5,
      name: 'Notification',
      description: 'App & System Alerts',
      icon: 'notifications',
      currentVolume: 5,
      maxVolume: 7,
      minVolume: 0,
      percentage: 71,
      isMuted: false,
      isSupported: true,
      primaryColor: '#00DAF3',
      secondaryColor: '#00626E',
    ),
    const VolumeStream(
      streamType: 4,
      name: 'Alarm',
      description: 'Wake & Timers',
      icon: 'alarm',
      currentVolume: 6,
      maxVolume: 7,
      minVolume: 0,
      percentage: 86,
      isMuted: false,
      isSupported: true,
      primaryColor: '#D6C9FF',
      secondaryColor: '#622BE5',
    ),
    const VolumeStream(
      streamType: 0,
      name: 'Call',
      description: 'In-call Voice',
      icon: 'phone_in_talk',
      currentVolume: 4,
      maxVolume: 5,
      minVolume: 0,
      percentage: 80,
      isMuted: false,
      isSupported: true,
      primaryColor: '#BAC9CC',
      secondaryColor: '#849396',
    ),
  ];

  Future<List<VolumeStream>> getStreams() async {
    try {
      final List<dynamic>? result =
          await _methodChannel.invokeListMethod<dynamic>('getStreams');
      if (result == null || result.isEmpty) return _defaultStreams;

      return result.map((item) {
        if (item is Map) {
          return VolumeStream.fromMap(item);
        }
        return const VolumeStream(
          streamType: 3,
          name: 'Media',
          description: '',
          icon: 'music_note',
          currentVolume: 0,
          maxVolume: 15,
          minVolume: 0,
          percentage: 0,
          isMuted: false,
          isSupported: true,
          primaryColor: '#00E5FF',
          secondaryColor: '#4A8EFF',
        );
      }).toList();
    } catch (_) {
      return _defaultStreams;
    }
  }

  Future<int> getMasterPercentage() async {
    try {
      final int? pct =
          await _methodChannel.invokeMethod<int>('getMasterPercentage');
      return pct ?? 75;
    } catch (_) {
      return 75;
    }
  }

  Future<bool> setVolume(int streamType, int volume) async {
    try {
      final bool? ok = await _methodChannel.invokeMethod<bool>('setVolume', {
        'streamType': streamType,
        'volume': volume,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setMasterVolume(int percentage) async {
    try {
      final bool? ok =
          await _methodChannel.invokeMethod<bool>('setMasterVolume', {
        'percentage': percentage,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> applyStreamVolumes(Map<int, int> streamVolumes) async {
    try {
      final stringKeyMap = streamVolumes.map((k, v) => MapEntry(k.toString(), v));
      final bool? ok = await _methodChannel.invokeMethod<bool>('applyStreamVolumes', {
        'streamVolumes': stringKeyMap,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> adjustStreamVolume(int streamType, int direction) async {
    try {
      final bool? ok =
          await _methodChannel.invokeMethod<bool>('adjustStreamVolume', {
        'streamType': streamType,
        'direction': direction,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setStreamMute(int streamType, bool mute) async {
    try {
      final bool? ok = await _methodChannel.invokeMethod<bool>('setStreamMute', {
        'streamType': streamType,
        'mute': mute,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> muteAll() async {
    try {
      final bool? ok = await _methodChannel.invokeMethod<bool>('muteAll');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> restoreAll() async {
    try {
      final bool? ok = await _methodChannel.invokeMethod<bool>('restoreAll');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasSavedSnapshot() async {
    try {
      final bool? ok =
          await _methodChannel.invokeMethod<bool>('hasSavedSnapshot');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetDefaults() async {
    try {
      final bool? ok = await _methodChannel.invokeMethod<bool>('resetDefaults');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isNotificationPermissionGranted() async {
    try {
      final bool? granted = await _methodChannel
          .invokeMethod<bool>('isNotificationPermissionGranted');
      return granted ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      await _methodChannel.invokeMethod('requestNotificationPermission');
    } catch (_) {}
  }

  Future<void> setPersistentNotificationEnabled(bool enabled) async {
    try {
      await _methodChannel.invokeMethod('setPersistentNotificationEnabled', {
        'enabled': enabled,
      });
    } catch (_) {}
  }

  Future<void> updateNotificationControls(NotificationSettings settings) async {
    try {
      await _methodChannel.invokeMethod(
          'updateNotificationControls', settings.toMap());
    } catch (_) {}
  }

  Future<bool> isDndAccessGranted() async {
    try {
      final bool? granted =
          await _methodChannel.invokeMethod<bool>('isDndAccessGranted');
      return granted ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> openDndSettings() async {
    try {
      await _methodChannel.invokeMethod('openDndSettings');
    } catch (_) {}
  }
}
