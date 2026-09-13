# Volumix

A lightweight, high-performance volume manager for Android built with Flutter and native Kotlin (`AudioManager`, `ContentObserver`, and `RemoteViews`).

Volumix gives you granular, real-time control over every Android audio stream with instant slider response, customizable profiles, and a persistent notification control center that works even when the screen is locked.

---

## Features

- **Individual Stream Control**: Independent control for all audio streams:
  - Media (`STREAM_MUSIC`)
  - Ringtone (`STREAM_RING`)
  - Notifications (`STREAM_NOTIFICATION`)
  - Alarm (`STREAM_ALARM`)
  - Voice Call (`STREAM_VOICE_CALL`)
  - System (`STREAM_SYSTEM`)
- **Instant Response**: Sliders follow your touch immediately with zero lag or frame drops.
- **Hardware Sync**: Real-time bidirectional sync with physical volume rockers, Bluetooth devices, and system volume changes.
- **Volume Presets**: Switch instantly between pre-configured modes (Default, Media, Meeting, Silent) or create custom profiles.
- **Persistent Notification Widget**: Control volume streams directly from your notification drawer with quick +/- and mute buttons.
- **One-Tap Mute & Restore**: Snapshot engine saves your exact volume levels before muting and restores them with a single tap.
- **AMOLED Dark Mode**: True `#000000` pitch black theme optimized for OLED battery efficiency.
- **100% Offline & Private**: Zero network permissions, no telemetry, no tracking. Everything runs locally on your device.

---

## Tech Stack

- **Frontend**: Flutter (Dart 3)
- **Native Android**: Kotlin, Android SDK (API 24 - 36)
- **Audio APIs**: `android.media.AudioManager`, `ContentObserver`
- **UI Architecture**: ValueNotifier granular rebuilds, custom Canvas tactile sliders

---

## Getting Started

### Prerequisites

- Flutter SDK `>= 3.24.0`
- Android Studio (Koala / Ladybug or newer)
- JDK 17
- Android SDK (API 24 to 36)

### Running the App

```bash
# Clone the repository
git clone https://github.com/Anantraj24/volumix.git
cd volumix

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Building Release APK

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

### Opening in Android Studio

1. Open Android Studio.
2. Select **Open** and choose the `Volumix` root directory (or the `android/` directory).
3. Ensure Gradle JVM is configured to **JDK 17** in **Settings > Build, Execution, Deployment > Build Tools > Gradle**.
4. Sync Gradle and run.

---

## Permissions

| Permission | Purpose |
|------------|---------|
| `POST_NOTIFICATIONS` | Displays the persistent volume notification drawer controls (Android 13+). |
| `ACCESS_NOTIFICATION_POLICY` | Allows adjusting stream volumes when Do Not Disturb is enabled. |
| `FOREGROUND_SERVICE` | Keeps notification controls responsive in the background. |
| `RECEIVE_BOOT_COMPLETED` | Restores notification controls after reboot (if enabled in settings). |

---

## License

Apache License 2.0. See [LICENSE](LICENSE) for details.
