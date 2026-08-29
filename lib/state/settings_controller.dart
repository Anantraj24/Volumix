import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/notification_settings.dart';
import '../repositories/volume_repository.dart';

class SettingsController extends ChangeNotifier {
  final VolumeRepository _repository;

  AppSettings _settings = const AppSettings();
  bool _isNotificationPermissionGranted = true;
  bool _hasDndAccess = true;

  SettingsController(this._repository);

  AppSettings get settings => _settings;
  bool get isAmoledMode => _settings.isAmoledMode;
  bool get isPersistentNotificationEnabled =>
      _settings.isPersistentNotificationEnabled;
  bool get isFirstRunCompleted => _settings.isFirstRunCompleted;
  NotificationSettings get notificationSettings =>
      _settings.notificationSettings;
  bool get isNotificationPermissionGranted =>
      _isNotificationPermissionGranted;
  bool get hasDndAccess => _hasDndAccess;

  Future<void> init() async {
    final amoled = _repository.isAmoledMode();
    final firstRun = _repository.isFirstRunCompleted();
    final notifSettings = _repository.getNotificationSettings();
    final notifPerm = await _repository.checkNotificationPermission();
    final dndAccess = await _repository.checkDndAccess();

    _isNotificationPermissionGranted = notifPerm;
    _hasDndAccess = dndAccess;

    _settings = AppSettings(
      isAmoledMode: amoled,
      isPersistentNotificationEnabled: true,
      isFirstRunCompleted: firstRun,
      hasDndAccess: dndAccess,
      notificationSettings: notifSettings,
    );
    notifyListeners();
  }

  Future<void> toggleAmoledMode(bool isAmoled) async {
    _settings = _settings.copyWith(isAmoledMode: isAmoled);
    await _repository.setAmoledMode(isAmoled);
    notifyListeners();
  }

  Future<void> togglePersistentNotification(bool enabled) async {
    _settings = _settings.copyWith(isPersistentNotificationEnabled: enabled);
    await _repository.setPersistentNotificationEnabled(enabled);
    notifyListeners();
  }

  Future<void> updateNotificationSettings(NotificationSettings notifSettings) async {
    _settings = _settings.copyWith(notificationSettings: notifSettings);
    await _repository.updateNotificationControls(notifSettings);
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _isNotificationPermissionGranted =
        await _repository.checkNotificationPermission();
    _hasDndAccess = await _repository.checkDndAccess();
    notifyListeners();
  }

  Future<void> requestNotificationPermission() async {
    await _repository.requestNotificationPermission();
    await Future.delayed(const Duration(milliseconds: 500));
    _isNotificationPermissionGranted =
        await _repository.checkNotificationPermission();
    notifyListeners();
  }

  Future<void> completeFirstRun() async {
    _settings = _settings.copyWith(isFirstRunCompleted: true);
    await _repository.setFirstRunCompleted(true);
    notifyListeners();
  }

  Future<void> openDndSettings() async {
    await _repository.openDndSettings();
  }
}
