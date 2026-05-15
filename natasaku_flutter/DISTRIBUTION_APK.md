# NataSaku APK Distribution Guide

## Build Artifact
- APK path: `build/app/outputs/flutter-apk/app-release.apk`
- APK size: `59,808,861 bytes` (~57 MB)
- Version: `0.1.1+2`
- Android `versionName`: `0.1.1`
- Android `versionCode`: `2`
- Package name: `com.natasaku.app`
- Min Android SDK: `24` (Android 7.0)
- Target SDK: `36`

## Signing Status
- Release signing configuration is enabled from existing `../../keystore.properties`.
- APK build completed successfully in release mode.
- Note: local `apksigner --print-certs` verification could not be executed in this environment because standalone Java runtime is unavailable.

## Install (Sideload) Steps
1. Transfer `app-release.apk` to Android device.
2. On Android, open Settings and allow **Install unknown apps** for the app used to open APK (Files, browser, chat app, etc).
3. Open APK file and tap **Install**.
4. Launch NataSaku and verify first-run/setup flow.

## Enable "Install Unknown Apps"
- Android 8+:
  1. Settings -> Apps -> Special app access -> Install unknown apps.
  2. Select source app (Files/Browser/etc).
  3. Enable **Allow from this source**.

## Update from Previous APK
- If previous APK is signed with the same key, install new APK directly (upgrade in place).
- If signature differs, Android will block install with package signature conflict.

## Signature Change Warning
- If app signature changes, uninstalling old app may be required before install.
- Uninstalling can remove local app data unless user has backup.

## Troubleshooting
- **App not installed**:
  - Check storage space.
  - Confirm unknown-source install is enabled.
  - Confirm APK is not corrupted (re-transfer file).
- **Blocked by Play Protect**:
  - Verify APK came from trusted distributor.
  - User may need to manually allow installation after warning.
- **Package conflicts / signature mismatch**:
  - Existing app may be signed with different key.
  - Uninstall old app first (backup data before uninstall).
- **Unknown sources disabled**:
  - Re-enable per-source permission as above.
- **Incompatible Android version**:
  - Device must run Android 7.0+ (SDK 24+).

## Security Notes
- Distribute APK only through trusted channels.
- Do not modify APK after signing.
- Verify source authenticity before installing.
