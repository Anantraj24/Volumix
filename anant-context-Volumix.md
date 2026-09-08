# Volumix — Project Context (AI-Optimized)

## Overview
Offline Android system-volume controller. Flutter UI + Kotlin native bridge. Zero network, zero telemetry.

## Stack
- **Flutter 3.41.9** / Dart 3.11.5 / Material 3
- **Kotlin 2.1.0** / Android SDK 24–36 / Gradle 8.14.5
- **State**: ChangeNotifier + ListenableBuilder (no external deps)
- **Storage**: shared_preferences (^2.5.4)
- **Bridge**: MethodChannel + EventChannel

## Architecture (Layered Clean)
```
Screens (lib/screens/) → State (lib/state/) → Repository (lib/repositories/) → Services (lib/services/) → PlatformChannel → Kotlin Native
```
- `VolumeController` — central volume state, 35ms coalescing throttle
- `PresetsController` — CRUD for custom presets
- `SettingsController` — AMOLED, notifications, DND, first-run
- `VolumeRepository` — single source of truth bridging platform + prefs
- `VolumePlatformService` — MethodChannel/EventChannel wrapper
- `PreferencesService` — SharedPreferences cache

## Files (36 Dart + 7 Kotlin)
### Screens (8)
| File | Purpose |
|------|---------|
| `main_navigation_scaffold.dart` | IndexedStack 4-tab nav + first-run gate |
| `home_screen.dart` | Volume streams, quick presets, mute/restore, reset |
| `presets_screen.dart` | Built-in grid + custom CRUD (create/edit/delete) |
| `quick_controls_screen.dart` | Compact stream sliders + presets |
| `settings_screen.dart` | Notification toggle, AMOLED, presets, about, reset |
| `notification_controls_screen.dart` | Toggle which streams appear in notification |
| `permission_setup_screen.dart` | First-run onboarding for notification permission |
| `about_screen.dart` | App info, privacy dialog, licenses |

### Widgets (7)
| File | Purpose |
|------|---------|
| `tactile_stream_card.dart` | Full stream card with slider, ±buttons, mute |
| `tactile_slider.dart` | Custom CustomPainter slider with gradient fill |
| `master_volume_dial.dart` | Arc-based circular dial (currently unused in screens) |
| `quick_action_buttons.dart` | Mute All / Restore All row |
| `status_banner.dart` | DND warning + external change indicator |
| `reset_confirm_dialog.dart` | Confirmation dialog for reset |
| `bottom_nav_bar.dart` | 4-tab bottom navigation |

### State (3)
- `volume_controller.dart` — streams, master%, mute/restore, throttling
- `presets_controller.dart` — built-in + custom presets CRUD
- `settings_controller.dart` — AMOLED, notification, DND, first-run

### Models (5)
- `volume_stream.dart` — immutable stream model with fromMap/toMap/copyWith
- `volume_preset.dart` — preset with 4 built-in (25/50/75/100%), equality/hashCode
- `volume_snapshot.dart` — mute snapshot for restore
- `notification_settings.dart` — 6 toggles for notification streams
- `app_settings.dart` — composite settings wrapper

### Services (2)
- `volume_platform_service.dart` — MethodChannel/EventChannel bridge + fallback defaults
- `preferences_service.dart` — SharedPreferences CRUD wrapper

### Constants (4)
- `audio_stream_types.dart` — stream IDs, icons, colors, gradients
- `app_colors.dart` — full palette (AMOLED + dark + accent)
- `app_typography.dart` — text styles
- `app_spacing.dart` — spacing/radius constants

### Kotlin (7)
- `VolumePlatformChannel.kt` — MethodChannel/EventChannel handler
- `VolumeManager.kt` — AudioManager wrapper (6 streams, mute, master, snapshot)
- `VolumeObserver.kt` — ContentObserver + BroadcastReceiver, 50ms debounce
- `VolumeNotificationService.kt` — ForegroundService with RemoteViews
- `NotificationActionReceiver.kt` — PendingIntent handler for notification buttons
- `BootReceiver.kt` — BOOT_COMPLETED restore
- `MainActivity.kt` — FlutterActivity entry point

## Features
1. **6-Stream Volume Control** — Media/Ring/Notif/Alarm/Call/System
2. **Master Volume Dial** — proportional scaling across streams
3. **Real-Time Hardware Sync** — ContentObserver + EventChannel, 50ms debounce
4. **Mute All / Restore All** — snapshot to SharedPreferences, restore on tap
5. **Persistent Notification** — ForegroundService + RemoteViews with ±/mute per stream
6. **Custom Presets** — CRUD with bottom sheet form
7. **AMOLED Pure Black** — #000000 theme toggle
8. **DND Integration** — detects missing permission, shows fix banner
9. **First-Run Onboarding** — permission setup screen

## Commands
```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

## Existing Tests (22 passing)
- `models_test.dart` — VolumeStream, NotificationSettings, VolumePreset, VolumeSnapshot serialization
- `presets_test.dart` — PresetsController CRUD + apply
- `volume_controller_test.dart` — VolumeController init, setVolume, applyPreset, muteAll
- `widget_test.dart` — VolumixApp renders HomeScreen with all key elements
- `regression_test.dart` — master-% exclusion, hardware-step adjust, min-volume restore, preset protection, restoreAll resilience

## Known Issues (found during analysis)
### Fixed (10 bugs)
1. **Version mismatch**: about_screen.dart showLicensePage:187 showed "2.4.1" instead of "1.0.0" → FIXED
2. **Unused method**: `_buildMiniStreamPreview` in notification_controls_screen.dart → FIXED (removed)
3. **Unused import**: `package:flutter/services.dart` in bottom_nav_bar.dart → FIXED (removed)
4. **Hardcoded 5% step**: `adjustStreamVolume` used 5% instead of hardware step → FIXED (delegates to native)
5. **Native unmute reset**: `VolumeManager.setStreamMute` reset volume to 50% on unmute, conflicting with controller restore → FIXED (removed else branch)
6. **Master % over-averaging**: `_recalculateMasterPercentage` averaged ALL streams incl. Call/System → FIXED (priority streams {3,2,5,4} only)
7. **Missing System stream**: `_defaultStreams` fallback lacked streamType 1 → FIXED (added)
8. **Unmute restore formula**: did not offset by minVolume (restored below usable range) → FIXED (minVolume + range*0.5, clamped to minVolume+1)
9. **restoreAll data-loss edge case**: Dart-side snapshot lost when native snapshot missing (process kill between saves) → FIXED (Dart snapshot applied directly as authoritative source)
10. **Native toggleStreamMute minVolume offset**: Kotlin `toggleStreamMute` restore ignored minVolume → FIXED (consistent with controller)
11. **Show Mute Button toggle ignored**: `PREF_NOTIF_MUTE_BTN` written but never read by notification builder → FIXED (honored in collapsed + expanded RemoteViews)

### Open / Notes
- **`MasterVolumeDial` unused**: widget exists but no screen renders it (design decision)
- **First-run permission race**: Enable button requests POST_NOTIFICATIONS then immediately starts FGS before user responds on Android 13+; SecurityException caught in service, toggle persists — notification appears after permission is later granted/retoggle

## Database/API
- No database, no REST/GraphQL API
- All persistence via SharedPreferences (JSON serialization)
- All hardware access via native AudioManager through MethodChannel

## Auth
- None (100% offline utility app)

## Dependencies
- flutter (SDK)
- cupertino_icons: ^1.0.8
- shared_preferences: ^2.5.4
- dev: flutter_test, flutter_lints: ^6.0.0
