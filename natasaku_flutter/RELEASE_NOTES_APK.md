# NataSaku APK Release Notes

- App: `NataSaku`
- Release date: `2026-05-12`
- Version: `0.1.1+2`
- Package: `com.natasaku.app`

## Summary
This release prepares NataSaku for manual Android APK distribution (outside Play Store/App Store), with production cleanup, Android release signing integration, and release packaging validation.

## Production Cleanup Completed
- Removed production-visible debug/development section from Settings.
- Removed production mock-data generator entry point.
- Removed unused mock data service from runtime codebase.
- Replaced demo-only immediate reminder notification behavior with scheduled daily reminder logic.
- Removed obsolete/unused Android widget drawable resources.
- Removed source `.DS_Store` files from project paths.

## Android Integration Status
- Android home-screen widgets remain enabled and declared.
- Persistent quick-tools notification remains enabled and configurable.
- MethodChannel bridge (`com.natasaku.quick_tools`) remains active.
- Boot receiver and quick action receiver declarations validated in manifest.

## Known Limitations
- `flutter analyze` still reports existing non-blocking lints/warnings (mostly deprecated `withOpacity` usage and unused declarations).
- Existing widget tests fail due stale text expectations not aligned with current UI copy (pre-existing test drift).
- Device runtime validation could not be executed in this environment (`adb` command unavailable; no Android device connected).
- Standalone `apksigner --print-certs` verification could not run due missing local Java runtime.

## Installation Note
Use `build/app/outputs/flutter-apk/app-release.apk` and follow `DISTRIBUTION_APK.md` for sideload instructions.

## Support / Troubleshooting
If install fails, check unknown-source permission, package signature conflicts, and Android version compatibility as documented in `DISTRIBUTION_APK.md`.
