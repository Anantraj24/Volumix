import 'package:flutter/material.dart';
import 'app_colors.dart';

class AudioStreamTypes {
  AudioStreamTypes._();

  static const int voiceCall = 0;
  static const int system = 1;
  static const int ring = 2;
  static const int music = 3;
  static const int alarm = 4;
  static const int notification = 5;

  static String getStreamName(int streamType) {
    switch (streamType) {
      case music:
        return 'Media';
      case ring:
        return 'Ring';
      case notification:
        return 'Notification';
      case alarm:
        return 'Alarm';
      case voiceCall:
        return 'Call';
      case system:
        return 'System';
      default:
        return 'Stream $streamType';
    }
  }

  static String getStreamDescription(int streamType) {
    switch (streamType) {
      case music:
        return 'Spotify, YouTube, Games';
      case ring:
        return 'Calls & Alerts';
      case notification:
        return 'App & System Alerts';
      case alarm:
        return 'Wake & Timers';
      case voiceCall:
        return 'In-call Voice';
      case system:
        return 'Touch & Feedback';
      default:
        return 'Audio Level';
    }
  }

  static IconData getStreamIcon(int streamType, {bool isMuted = false}) {
    if (isMuted) {
      switch (streamType) {
        case voiceCall:
          return Icons.phone_disabled_rounded;
        case notification:
        case ring:
          return Icons.notifications_off_rounded;
        case alarm:
          return Icons.alarm_off_rounded;
        case music:
        default:
          return Icons.volume_off_rounded;
      }
    }

    switch (streamType) {
      case music:
        return Icons.music_note_rounded;
      case ring:
        return Icons.notifications_active_rounded;
      case notification:
        return Icons.notifications_rounded;
      case alarm:
        return Icons.alarm_rounded;
      case voiceCall:
        return Icons.phone_in_talk_rounded;
      case system:
        return Icons.tune_rounded;
      default:
        return Icons.volume_up_rounded;
    }
  }

  static Color getStreamPrimaryColor(int streamType) {
    switch (streamType) {
      case music:
        return AppColors.azureLight;
      case ring:
        return AppColors.cyan;
      case notification:
        return AppColors.cyanDim;
      case alarm:
        return AppColors.violetContainer;
      case voiceCall:
        return AppColors.onSurfaceVariant;
      case system:
        return AppColors.outline;
      default:
        return AppColors.cyan;
    }
  }

  static LinearGradient getStreamSliderGradient(int streamType) {
    switch (streamType) {
      case music:
        return AppColors.mediaSliderGradient;
      case ring:
        return AppColors.ringSliderGradient;
      case notification:
        return AppColors.ringSliderGradient;
      case alarm:
        return AppColors.alarmSliderGradient;
      case voiceCall:
      case system:
      default:
        return AppColors.quickSliderGradient;
    }
  }
}
