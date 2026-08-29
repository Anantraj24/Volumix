# Volumix

**Volumix** is a modern, high-performance, and completely offline Android system-volume controller engineered with **Flutter**, **Material 3**, and native **Kotlin Android APIs** (`AudioManager`, `ContentObserver`, and `RemoteViews` persistent foreground notifications).

Designed based on the Stitch AMOLED dark visual system (Design ID: `13554949887483774509`).

---

## Key Features

- **Master Volume Control**: Centralized tactile circular volume dial with live percentage feedback and multi-stream scaling.
- **Granular Stream Management**: Independent controls for all Android audio streams:
  - 🎵 **Media**: Spotify, YouTube, Games (`STREAM_MUSIC`)
  - 🔔 **Ring**: Phone calls & alerts (`STREAM_RING`)
  - 💬 **Notification**: Messages & system notifications (`STREAM_NOTIFICATION`)
  - ⏰ **Alarm**: Timers & wake alarms (`STREAM_ALARM`)
  - 📞 **Voice Call**: In-call volume (`STREAM_VOICE_CALL`)
  - 🎛️ **System**: Keypress and touch feedback (`STREAM_SYSTEM`)
- **Real-Time Hardware Synchronization**: Bidirectional synchronization with physical hardware buttons, Bluetooth headsets, and external system volume panels via native `ContentObserver` and `VOLUME_CHANGED_ACTION` broadcast receivers.
- **Mute All & Restore All**: Smart snapshot capture that saves pre-mute volume levels to local storage and restores them with a single tap.
- **Persistent Notification Controls**: Ongoing notification widget with custom `RemoteViews` featuring quick minus, plus, and mute actions that operate even when Flutter is closed or the device is locked.
- **Customizable Notification Streams**: Settings to choose which streams and control toggles appear in the notification drawer.
- **AMOLED Pure Black Mode**: True `#000000` dark theme engineered to maximize battery efficiency on OLED displays.
- **100% Offline & Private**: Zero network dependencies, zero telemetry, zero analytics. All operations are performed locally on the device hardware.

---

## Screenshots & Design System

Volumix adheres strictly to the Stitch Design System:
- **AMOLED Minimalism**: Pure black void (`#000000`) and subtle `#121212` tactile card containers with 1px `#1F1F1F` borders.
- **Electric Cyan Accents**: Vibrant `#00E5FF` active states, cyan glow rings, and progress arcs.
- **Dual Typography**: **Inter** for primary UI elements and neutral typography; **Geist** monospaced font styling for precise numerical percentages and badges.
- **Ultra-Rounded Geometry**: Pill buttons (`rounded-full`), 16dp / 24dp / 28dp card radii, and 48dp+ accessibility-compliant touch targets.

---

## Architecture & Technology Stack

```
Flutter UI (Material 3)
   │
   ▼
State Management (ChangeNotifier / Reactive Controllers)
   │
   ▼
VolumeRepository (Local Cache + Platform Interface)
   │
   ├── MethodChannel: com.anant.volumix/volume_methods
   └── EventChannel:  com.anant.volumix/volume_events
   │
   ▼
Native Android Layer (Kotlin)
   │
   ├── VolumeManager (AudioManager wrapper)
   ├── VolumeObserver (ContentObserver & BroadcastReceiver)
   ├── VolumeNotificationService (Ongoing RemoteViews Notification)
   └── NotificationActionReceiver (Background PendingIntent Handler)
   │
   ▼
Android Audio HAL & Audio System
```

### Technology Matrix
- **UI Framework**: Flutter (Dart 3.x)
- **Native Platform**: Android (Kotlin, Android SDK API 24–34)
- **Audio Interface**: `android.media.AudioManager`
- **Inter-Process Communication**: Flutter Platform Channels (`MethodChannel` & `EventChannel`)
- **Persistence**: `SharedPreferences` (local snapshot storage & user preferences)

---

## Project Structure

```
Volumix/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/anant/volumix/
│   │   │   │   ├── MainActivity.kt               # FlutterActivity entry point
│   │   │   │   ├── VolumeManager.kt              # Android AudioManager engine
│   │   │   │   ├── VolumeObserver.kt             # Real-time hardware volume listener
│   │   │   │   ├── VolumeNotificationService.kt  # Persistent Android notification
│   │   │   │   ├── NotificationActionReceiver.kt # Background action receiver
│   │   │   │   ├── BootReceiver.kt               # Boot completed receiver
│   │   │   │   └── VolumePlatformChannel.kt      # Platform Channel glue code
│   │   │   ├── res/
│   │   │   │   ├── layout/                       # Collapsed & Expanded notification layouts
│   │   │   │   ├── drawable/                     # Vector drawables & background shapes
│   │   │   │   └── values/                       # Colors & Strings
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle.kts
│   └── build.gradle.kts
├── lib/
│   ├── core/
│   │   └── constants/
│   │       ├── app_colors.dart                   # Stitch color tokens
│   │       ├── app_typography.dart               # Typography tokens
│   │       ├── app_spacing.dart                  # Spacing & corner radii
│   │       └── audio_stream_types.dart           # Stream definitions & gradients
│   ├── models/
│   │   ├── volume_stream.dart                    # Stream model
│   │   ├── notification_settings.dart            # Notification toggle model
│   │   ├── app_settings.dart                     # Theme & feature settings
│   │   └── volume_snapshot.dart                  # Snapshot data model
│   ├── repositories/
│   │   └── volume_repository.dart                # Repository coordination layer
│   ├── services/
│   │   ├── preferences_service.dart              # SharedPreferences client
│   │   └── volume_platform_service.dart          # MethodChannel & EventChannel client
│   ├── state/
│   │   ├── volume_controller.dart                # Volume state & actions
│   │   └── settings_controller.dart              # Settings & permissions state
│   ├── theme/
│   │   └── app_theme.dart                        # Dark & AMOLED ThemeData
│   ├── widgets/
│   │   ├── master_volume_dial.dart               # Circular master dial painter & gestures
│   │   ├── tactile_stream_card.dart              # Granular stream card widget
│   │   ├── tactile_slider.dart                   # Custom tactile gradient slider
│   │   ├── quick_action_buttons.dart             # Mute All & Restore All pills
│   │   ├── bottom_nav_bar.dart                   # Stitch bottom navigation bar
│   │   ├── status_banner.dart                    # DND & External change indicators
│   │   └── reset_confirm_dialog.dart             # Reset confirmation modal
│   ├── screens/
│   │   ├── main_navigation_scaffold.dart         # Main navigation host
│   │   ├── home_screen.dart                      # Home dashboard
│   │   ├── quick_controls_screen.dart            # Quick controls screen
│   │   ├── settings_screen.dart                  # Settings screen
│   │   ├── notification_controls_screen.dart     # Notification customization screen
│   │   ├── permission_setup_screen.dart          # First-run onboarding screen
│   │   └── about_screen.dart                     # About & Legal screen
│   └── main.dart                                 # App bootstrap & theme injection
├── test/
│   ├── models_test.dart                          # Unit tests for models
│   ├── volume_controller_test.dart               # State controller unit tests
│   └── widget_test.dart                          # UI & Widget integration tests
└── pubspec.yaml
```

---

## Android Permissions & Capabilities

| Permission | Purpose |
|------------|---------|
| `android.permission.POST_NOTIFICATIONS` | Required on Android 13+ (API 33+) to display the persistent volume notification. |
| `android.permission.ACCESS_NOTIFICATION_POLICY` | Required to adjust ring or alarm volumes while Do Not Disturb is active. |
| `android.permission.FOREGROUND_SERVICE` | Keeps the persistent control notification active and responsive in the background. |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Restores persistent notification controls after a device reboot (if enabled). |

---

## Supported Android Versions & Limitations

- **Minimum SDK**: Android 7.0 / API 24 (Nougat)
- **Target SDK**: Android 14 / API 34 (Upside Down Cake)
- **Known Android Limitations**:
  - Certain device manufacturers (OEMs) couple the Ring and Notification volume streams together in software; adjusting one may automatically update the other depending on device firmware settings.
  - Modifying the Ring stream during active Do Not Disturb (DND) mode requires granting Notification Policy Access via Android Settings. Volumix detects this state and displays a warning banner with direct navigation to the system settings page.
  - `STREAM_VOICE_CALL` is restricted by Android when no cellular or VoIP call is in progress on select devices.

---

## Build & Installation Instructions

### Prerequisites
- Flutter SDK (version 3.24.0 or higher)
- Android SDK (API 24 to 34)
- Java Development Kit (JDK 17)

### 1. Clone the repository
```bash
git clone https://github.com/Anantraj24/volumix.git
cd volumix
```

### 2. Fetch dependencies
```bash
flutter pub get
```

### 3. Run analyzer & tests
```bash
flutter analyze
flutter test
```

### 4. Run the app on a connected Android device or emulator
```bash
flutter run
```

### 5. Build Debug APK
```bash
flutter build apk --debug
```

The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-debug.apk`

---

## License

This project is licensed under the Apache 2.0 License.
