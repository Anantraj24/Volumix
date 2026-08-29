import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_settings.dart';
import '../models/volume_snapshot.dart';

class PreferencesService {
  static const String keyAmoled = 'volumix_pref_amoled';
  static const String keyPersistentNotif = 'persistent_notification_enabled';
  static const String keyFirstRun = 'volumix_pref_first_run_completed';
  static const String keyNotificationSettings = 'volumix_pref_notification_settings';
  static const String keySavedSnapshot = 'saved_volume_snapshot';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  bool get isAmoledMode => _prefs.getBool(keyAmoled) ?? true;
  Future<void> setAmoledMode(bool value) async {
    await _prefs.setBool(keyAmoled, value);
  }

  bool get isPersistentNotificationEnabled =>
      _prefs.getBool(keyPersistentNotif) ?? true;
  Future<void> setPersistentNotificationEnabled(bool value) async {
    await _prefs.setBool(keyPersistentNotif, value);
  }

  bool get isFirstRunCompleted => _prefs.getBool(keyFirstRun) ?? false;
  Future<void> setFirstRunCompleted(bool value) async {
    await _prefs.setBool(keyFirstRun, value);
  }

  NotificationSettings getNotificationSettings() {
    final jsonStr = _prefs.getString(keyNotificationSettings);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const NotificationSettings();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return NotificationSettings.fromMap(map);
    } catch (_) {
      return const NotificationSettings();
    }
  }

  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final jsonStr = jsonEncode(settings.toMap());
    await _prefs.setString(keyNotificationSettings, jsonStr);
  }

  VolumeSnapshot? getSavedSnapshot() {
    final jsonStr = _prefs.getString(keySavedSnapshot);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return VolumeSnapshot.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSnapshot(VolumeSnapshot snapshot) async {
    final jsonStr = jsonEncode(snapshot.toMap());
    await _prefs.setString(keySavedSnapshot, jsonStr);
  }

  Future<void> clearSnapshot() async {
    await _prefs.remove(keySavedSnapshot);
  }
}
