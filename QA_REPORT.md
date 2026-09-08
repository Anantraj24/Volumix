# Volumix QA Report

**Build**: Volumix 1.0.0+1 (com.anant.volumix)
**QA date**: 2026-09-08
**Environment**: Flutter 3.41.9 / Dart 3.11.5 · Kotlin 2.1.0 · Android SDK 24–36 · Windows host

---

## 1. Scope & Method

Automated and static verification of the full stack (Dart UI/state/repository + Kotlin native bridge) for the v1.0.0 release:

1. `flutter analyze` — static analysis (lints, dead code, type safety).
2. `flutter test` — unit + widget tests (all five test files).
3. `flutter build apk --debug` — compile verification of Dart + Gradle + Kotlin (regex-validated against error patterns + success line).
4. Manual code review — cross-layer contract check between `MethodChannel`/`EventChannel` call names, argument shapes, snapshot semantics, and the notification RemoteViews.
5. Crash-log sweep — removed stray `hs_err_pid*.log` artifacts from an earlier memory-constrained Gradle run.

### Limitations
- **No physical device / emulator run**: hardware-dependent behaviors (hardware volume step, per-device `minVolume`, FGS on Android 13–15, notification rendering) are verified by code contract + compile, **not** on-device. A device smoke test (Section 6) is recommended before release.

---

## 2. Test Inventory

| ID | File | Tests | Area |
|----|------|-------|------|
| T1 | `test/models_test.dart` | 7 | Model serialization (VolumeStream, NotificationSettings, VolumePreset, VolumeSnapshot) |
| T2 | `test/presets_test.dart` | 5 | PresetsController CRUD + built-in protection + apply |
| T3 | `test/volume_controller_test.dart` | 4 | init, setStreamVolume, applyPreset, muteAll |
| T4 | `test/regression_test.dart` | 5 | Master-% exclusion, hardware-step adjust, min-volume unmute restore, built-in preset protection, restoreAll resilience |
| T5 | `test/widget_test.dart` | 1 | VolumixApp renders HomeScreen (presets bar + streams) |
| | **Total** | **22** | |

## 3. Results

| Check | Result |
|-------|--------|
| `flutter analyze` | **0 issues** |
| `flutter test` (all files) | **22/22 passed** |
| `flutter build apk --debug` | **Success** (no errors/warnings) |
| Test discovery (root `flutter test`) | 22/22 (regression file renamed to `regression_test.dart` so auto-discovery includes it) |

### Notable test fix during QA
The initial regression file was named `regression_tests.dart`, which **does not** match Flutter's `*_test.dart` discovery pattern, so root-level `flutter test` silently skipped it (17 tests). Renamed to `regression_test.dart` → 22 tests discovered and passing. This would have been a false "green" had only the root command been trusted.

## 4. Bugs Found & Fixed (see `BUG_REPORT.md` for details)

| # | Severity | Area | Bug |
|---|----------|------|-----|
| 1 | HIGH | About screen | License page version "2.4.1" vs actual "1.0.0" |
| 2 | LOW | Notification controls | Dead `_buildMiniStreamPreview` method |
| 3 | LOW | Bottom nav | Unused `flutter/services.dart` import |
| 4 | HIGH | Stream cards | Hardcoded 5% adjust step instead of hardware step |
| 5 | HIGH | Native mute | Unmute reset volume to 50%, overriding controller restore |
| 6 | MEDIUM | Master % | Averaged Call/System; inconsistent with native |
| 7 | MEDIUM | Fallback streams | System stream missing in `_defaultStreams` |
| 8 | MEDIUM | Unmute restore | Ignored minVolume offset → restored into dead zone |
| 9 | HIGH | Restore snapshot | Valid Dart snapshot could be wiped + replaced with defaults |
| 10 | MEDIUM | Native toggle mute | Restore ignored minVolume; disagreed with Dart |
| 11 | MEDIUM | Notification | "Show Mute Button" toggle had no effect |

Bugs fixed: **11/11**. No known open functional bugs.

## 5. Quality Assessment

### Code quality
- **Architecture**: Clean layered separation (Screens → State → Repository → Services → Platform → Native) verified consistent.
- **Dart**: 0 analyzer issues; idiomatic `ChangeNotifier` + `ListenableBuilder`; 35ms coalescing throttle for slider drags is sound.
- **Kotlin**: Defensive error handling (`try/catch` around `AudioManager` calls, `SecurityException` handling for FGS); snapshot semantics now consistent between Dart and native.
- **Snapshots & restore**: Made robust against the inter-write process-kill edge case (Bug 9).

### Risks remaining (see BUG_REPORT.md § non-fixed observations)
1. **First-run permission race** on Android 13+: FGS is started before the POST_NOTIFICATIONS callback resolves; currently benign (caught + logged + toggle persists), but the notification may not appear until permission is granted/retoggled.
2. **No device E2E** performed; notification RemoteViews and per-device stream support should be smoke-tested on hardware.

## 6. Recommended Device Smoke Test (before release)

1. Fresh install → onboarding → "Enable Notification" → confirm status-bar controls appear; toggle mute the media row.
2. Tap ± buttons on a stream card → verify one **hardware step** per tap, 0%–100% reachable.
3. Mute a stream, confirm restore goes to ~50% (not dead-zone min).
4. Mute All → kill app from recents → reopen → Restore All → confirm exact pre-mute volumes return.
5. Settings → Notification Controls → disable "Show Mute Button" → verify the notification's mute button disappears (collapsed + expanded).
6. Check master % changes only for Media/Ring/Notif/Alarm.
7. Two-button navigation (gesture) + AMOLED toggle + preset apply.
8. Volume keys while app foreground → external-change banner appears, UI stays in sync.