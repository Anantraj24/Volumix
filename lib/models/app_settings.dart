import 'notification_settings.dart';

class AppSettings {
  final bool isAmoledMode;
  final bool isPersistentNotificationEnabled;
  final bool isFirstRunCompleted;
  final bool hasDndAccess;
  final NotificationSettings notificationSettings;

  const AppSettings({
    this.isAmoledMode = true,
    this.isPersistentNotificationEnabled = true,
    this.isFirstRunCompleted = false,
    this.hasDndAccess = true,
    this.notificationSettings = const NotificationSettings(),
  });

  AppSettings copyWith({
    bool? isAmoledMode,
    bool? isPersistentNotificationEnabled,
    bool? isFirstRunCompleted,
    bool? hasDndAccess,
    NotificationSettings? notificationSettings,
  }) {
    return AppSettings(
      isAmoledMode: isAmoledMode ?? this.isAmoledMode,
      isPersistentNotificationEnabled:
          isPersistentNotificationEnabled ?? this.isPersistentNotificationEnabled,
      isFirstRunCompleted: isFirstRunCompleted ?? this.isFirstRunCompleted,
      hasDndAccess: hasDndAccess ?? this.hasDndAccess,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}
