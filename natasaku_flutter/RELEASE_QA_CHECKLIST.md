# NataSaku Release QA Checklist

## Install
- [ ] APK installs successfully on device.
- [ ] App launches successfully after install.
- [ ] App version shown is `0.1.1` (`versionCode` 2).
- [ ] Upgrade from previous APK works (same signature).
- [ ] Reinstall behavior documented when signature changes.

## Core Flutter App
- [ ] Launch/splash flow works.
- [ ] First-run onboarding/setup flow works.
- [ ] Main navigation tabs/routes work.
- [ ] Main budgeting flow works (period setup -> dashboard updates).
- [ ] Transaction create/edit/delete flow works.
- [ ] Settings page works.
- [ ] Empty states render correctly.
- [ ] Error handling states render correctly.
- [ ] Offline behavior does not crash app.
- [ ] Data persists after app restart.

## Production Cleanup Validation
- [ ] No mock/demo data visible in production runtime.
- [ ] No debug/development menu visible.
- [ ] No fake statistics or seeded sample profiles visible.
- [ ] No test-only shortcut routes visible.
- [ ] No debug banner in release APK.

## Android Widgets
- [ ] Widgets appear in widget picker.
- [ ] 8 widget variants are available.
- [ ] Widget resize behavior is stable.
- [ ] Widget actions trigger expected quick-tools behavior.
- [ ] Widget refresh works after app data updates.
- [ ] Empty/no-period widget state does not crash.

## Persistent Notification / Quick Tools
- [ ] Persistent quick-tools notification appears when enabled.
- [ ] Notification remains ongoing.
- [ ] Notification channel is present.
- [ ] Notification actions work (`+10k`, `+50k`, `Cek`).
- [ ] Notification can be disabled from app setting.
- [ ] Android 13+ notification permission flow is safe.
- [ ] Denied permission does not crash app.

## Device Coverage
- [ ] Android 8+
- [ ] Android 12+
- [ ] Android 13+
- [ ] Android 14/15 (if available)
- [ ] Small phone
- [ ] Large phone
- [ ] Tablet (if supported)
- [ ] Light mode
- [ ] Dark mode

## Runtime Validation Notes
- In this environment, `adb` is unavailable and no Android device is connected.
- Device-level checks above must be executed manually on QA devices.
