# Volumix Bug Report

**Project**: Volumix 1.0.0 (com.anant.volumix)
**Testing date**: 2026-09-08
**Method**: Static analysis (`flutter analyze`), automated widget/unit tests (`flutter test`), code review of Dart + Kotlin layers, debug APK build verification.

---

## Summary

| Severity | Count |
|----------|-------|
| High | 4 |
| Medium | 4 |
| Low | 3 |
| **Total** | **11** |

All 11 bugs found were fixed. Verification: `flutter analyze` → 0 issues, `flutter test` → 22/22 pass, `flutter build apk --debug` → clean build.

---

## Bug 1 — Version mismatch in About screen  (HIGH, UI)
- **File**: `lib/screens/about_screen.dart:187`
- **Symptom**: Settings → About → "Open Licenses" `showLicensePage` displayed application version **"2.4.1"** instead of the actual **"1.0.0"**.
- **Root cause**: `applicationVersion` passed to `showLicensePage` was hardcoded/mismatched with `pubspec.yaml` (`1.0.0+1`).
- **Fix**: Changed to `1.0.0` to match `pubspec.yaml` and the About screen subtitle.
- **Regression test**: N/A (visual). Covered by code review.

## Bug 2 — Dead code: `_buildMiniStreamPreview`  (LOW, code quality)
- **File**: `lib/screens/notification_controls_screen.dart`
- **Symptom**: Large unused private method (mini stream preview renderer) inflated the file (~30 lines of dead code).
- **Root cause**: Leftover from a prior UI iteration.
- **Fix**: Removed the method entirely.
- **Verified by**: `flutter analyze` (no unused-element warnings after removal).

## Bug 3 — Unused import  (LOW, code quality)
- **File**: `lib/widgets/bottom_nav_bar.dart:2`
- **Symptom**: `import 'package:flutter/services.dart'` unused.
- **Root cause**: Imported during a refactor, never used.
- **Fix**: Removed the import.
- **Verified by**: `flutter analyze` clean.

## Bug 4 — `adjustStreamVolume` used a hardcoded 5% step  (HIGH, functional)
- **File**: `lib/state/volume_controller.dart` `adjustStreamVolume`
- **Symptom**: The +/− buttons on stream cards stepped volume by a hardcoded **5%** instead of the device's actual hardware volume step (e.g., 1 unit / ~6–7% on a 15-step slider). Repeated presses visually jumped and could not reach exact max volume.
- **Root cause**: Controller computed `pct ± 5` and converted, ignoring `AudioManager.adjustStreamVolume`'s native step and flags.
- **Fix**: Delegate directly to `repository.adjustStreamVolume(streamType, direction)` → `VolumeManager.adjustStreamVolume` (uses `ADJUST_RAISE`/`ADJUST_LOWER` with the hardware-defined step), then refresh streams from the platform.
- **Regression test**: `regression_test.dart` — "adjustStreamVolume delegates to platform and updates stream by hardware step".

## Bug 5 — Native `setStreamMute` reset volume to 50% on unmute  (HIGH, functional)
- **File**: `android/.../VolumeManager.kt` `setStreamMute`
- **Symptom**: Tapping a stream's mute button in-app set the volume to minVolume, then the native `setStreamMute(streamType, false)` **overwrote the restore volume with 50%** on the next unmute. The controller's explicit restore value was ignored and the slider snapped to 50% regardless of the prior level.
- **Root cause**: The `mute == false` branch in native `setStreamMute` did `setVolume(streamType, 50% actual)` directly.
- **Fix**: Removed the volume-set in the unmute branch; unmute now only performs `ADJUST_UNMUTE`, letting the controller's `setStreamVolume(restoreVol)` win.
- **Regression test**: covered by "unmute restores to a volume above minVolume" (`regression_test.dart`).

## Bug 6 — Master percentage averaged unsupported/background streams  (MEDIUM, functional)
- **File**: `lib/state/volume_controller.dart` `_recalculateMasterPercentage`
- **Symptom**: The master dial/percentage averaged **all** supported streams including **Call** and **System**, so adjusting unrelated streams shifted the master reading; also inconsistent with the native `VolumeManager.getMasterPercentage()` which uses only Media/Ring/Notification/Alarm.
- **Root cause**: Controller used `filterSupported()` without the priority-stream filter the native side uses.
- **Fix**: Match native behavior — average only priority streams {3, 2, 5, 4} (Media, Ring, Notification, Alarm), falling back to all supported if none match.
- **Regression test**: "excludes Call and System streams from master percentage average".

## Bug 7 — Missing System stream in fallback defaults  (MEDIUM, robustness)
- **File**: `lib/services/volume_platform_service.dart` `_defaultStreams`
- **Symptom**: On platforms/channels where `getStreams` fails, the offline fallback listed 5 streams but omitted the System stream (streamType 1) that native `STREAM_CONFIGS` includes.
- **Root cause**: `_defaultStreams` had Media/Ring/Notif/Alarm/Call only.
- **Fix**: Added the System stream (streamType 1).
- **Verified by**: code review.

## Bug 8 — Unmute restore volume ignored minVolume offset  (MEDIUM, functional)
- **File**: `lib/state/volume_controller.dart` `toggleStreamMute`
- **Symptom**: On devices/streams where `minVolume > 0`, the unmute restore computed `maxVolume * 0.5` — **below the usable range** — so the stream restored to the minimum (still displayed as muted) instead of ~50%. The fraction also didn't span the true range.
- **Root cause**: Formula `maxVolume * 0.5` ignored `minVolume`.
- **Fix**: `restoreVol = minVolume + round(range * 0.5)`, clamped to `[minVolume+1, maxVolume]`.
- **Regression test**: "unmute restores to a volume above minVolume".

## Bug 9 — `restoreAll` could clear a valid Dart snapshot (data loss)  (HIGH, data integrity)
- **File**: `lib/repositories/volume_repository.dart` `restoreAll`
- **Symptom**: If the app process was killed between the Dart-side snapshot save (`PreferencesService.saveSnapshot`) and the native-side save (MethodChannel `muteAll`), or the native snapshot was otherwise lost, tapping **Restore All** fell through to native `restoreAll()` → native found no snapshot → ran `resetDefaults()` → returned `true` → the repository then cleared the still-valid **Dart-side** snapshot. The user's saved volumes were replaced with system defaults and unrecoverable.
- **Root cause**: The repository trusted the native snapshot as the only source of truth during restore, but the Dart-side snapshot is written first and is the more durable one.
- **Fix**: In `restoreAll`, if a Dart-side snapshot exists and the native does not, apply the Dart snapshot volumes directly (`applyStreamVolumes`) and clear the Dart snapshot; the native path is used otherwise (skip the default-reset fallback when a valid Dart snapshot is present).
- **Regression test**: "restores from Dart-side snapshot when native snapshot is missing" (`regression_test.dart`).

## Bug 10 — Native `toggleStreamMute` restore ignored minVolume  (MEDIUM, functional)
- **File**: `android/.../VolumeManager.kt` `toggleStreamMute`
- **Symptom**: The notification-bar mute buttons call the *native* `toggleStreamMute`, whose unmute-restore computed `(maxVol - minVol) * 0.5` **without adding minVol** — on streams with `minVol > 0` it restored to ~30% of the range and disagreed with the Dart-side behavior (Bug 8's fix). Tabletop devices restored to different levels depending on whether the button was tapped in-app vs. in the notification.
- **Root cause**: Inconsistent restore formula between Dart and Kotlin.
- **Fix**: `restoreVol = (minVol + (maxVol - minVol) * 0.5).toInt().coerceIn(minVol + 1, maxVol)` — matches the controller.
- **Regression test**: N/A (native logic; verified by build + code review).

## Bug 11 — "Show Mute Button" notification toggle had no effect  (MEDIUM, functional)
- **File**: `android/.../VolumeNotificationService.kt` `buildNotification`
- **Symptom**: Settings → Notification Controls → "Show Mute Button" (off) updated `PREF_NOTIF_MUTE_BTN` but the persistent notification still rendered every stream's mute button. Toggle was dead.
- **Root cause**: `buildNotification` read `showMedia/showRing/showAlarm/showCall/showPercent` but never read `PREF_NOTIF_MUTE_BTN`; mute buttons were always attached to the RemoteViews.
- **Fix**: Read `showMute` and set `View.VISIBLE`/`View.GONE` on `notif_btn_media_mute` (collapsed) and `notif_exp_{media,ring,alarm,call}_mute` (expanded).
- **Regression test**: N/A (native reality binding; verified by build + code review).

---

## Non-fixed observations
- **`MasterVolumeDial` widget is unused** in all screens (design decision; kept for future use).
- **First-run permission race**: the "Enable Notification" button calls `requestNotificationPermission()` (async dialog) then immediately starts the foreground service. On Android 13+, the FGS may start before the POST_NOTIFICATIONS decision; the native service catches the resulting `SecurityException` (logged), the toggle stays enabled, and the notification appears once permission is subsequently granted. Suggested follow-up: start the service from the `onRequestPermissionsResult` callback.
- **JVM OOM crash logs** (`hs_err_pid*.log` from Gradle on a memory-constrained host) were removed from the repository.

## Verification after fixes
```
flutter analyze ................. 0 issues
flutter test .................... 22/22 passed
flutter build apk --debug ....... built successfully
```