# Volumix

**Volumix** is a modern, high-performance, and completely offline Android system-volume controller engineered with **Flutter**, **Material 3**, and native **Kotlin Android APIs** (`AudioManager`, `ContentObserver`, and `RemoteViews` persistent foreground notifications).

- **App Name**: Volumix
- **Package Name**: `com.anant.volumix`
- **Framework**: Flutter (Dart 3.x)
- **Native Platform**: Android (Kotlin 2.1.0, Android SDK API 24–36, Gradle 8.14.5)
- **Repository**: [https://github.com/Anantraj24/volumix.git](https://github.com/Anantraj24/volumix.git)

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

---

## System Requirements

- **Flutter SDK**: `>= 3.24.0` (Dart `>= 3.5.0`)
- **JDK (Java Development Kit)**: **JDK 17** (or compatible JDK 17–21)
- **Android SDK**: Android SDK API 24 (minSdk) to API 36 (compileSdk / targetSdk)
- **Android Studio**: Android Studio Koala / Ladybug or newer with Flutter & Dart plugins installed
- **Gradle**: 8.14.5 (configured via gradle-wrapper)

---

## Android Studio Setup Guide

1. **Open the Project**:
   - Open **Android Studio**.
   - Click **Open** (or `File` > `Open...`).
   - Select the root folder `Volumix` (or the `android/` subfolder if opening as a pure Android project).

2. **Configure JDK in Android Studio**:
   - Go to **File** > **Settings** (or **Preferences** on macOS) > **Build, Execution, Deployment** > **Build Tools** > **Gradle**.
   - Under **Gradle JVM**, ensure **JDK 17** is selected (e.g. Eclipse Adoptium 17, Oracle JDK 17, or Android Studio Embedded JDK 17).
   - Gradle 8.14.5 is compatible with JDK 17–21.

3. **Sync Project with Gradle Files**:
   - Click the **Sync Project with Gradle Files** button (elephant icon with blue arrow) in the top toolbar.

---

## Flutter Development & Build Commands

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Run Code Analysis & Tests
```bash
flutter analyze
flutter test
```

### 3. Run Locally (Emulator / USB Debugging)
```bash
flutter run
```

### 4. Build APK

#### Build Release APK:
```bash
flutter build apk --release
```
**Output Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

#### Build Debug APK:
```bash
flutter build apk --debug
```
**Output Location:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

#### Build App Bundle (AAB for Google Play):
```bash
flutter build appbundle --release
```
**Output Location:**
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Android Permissions

| Permission | Purpose |
|------------|---------|
| `android.permission.POST_NOTIFICATIONS` | Required on Android 13+ (API 33+) to display the persistent volume notification. |
| `android.permission.ACCESS_NOTIFICATION_POLICY` | Required to adjust ring or alarm volumes while Do Not Disturb is active. |
| `android.permission.FOREGROUND_SERVICE` | Keeps the persistent control notification active and responsive in the background. |
| `android.permission.FOREGROUND_SERVICE_SPECIAL_USE` | Declares the persistent audio volume control background service on Android 14+ (API 34+). |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Restores persistent notification controls after a device reboot (if enabled). |

---

## License

This project is licensed under the Apache 2.0 License.
