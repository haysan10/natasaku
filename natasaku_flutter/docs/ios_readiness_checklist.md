# iOS Readiness Checklist (Batch 4-5)

## Scope

Dokumen ini memastikan fitur Batch 4-5 (Kalender Uang, Auto-Celengan, Reminder, Backup/Restore) siap dibawa ke iOS tanpa refactor besar.

## Checklist

- [x] Tidak ada pemanggilan API Android-only di layer UI.
- [x] Seluruh storage menggunakan `shared_preferences` (cross-platform).
- [x] Backup file menggunakan `path_provider` documents directory (Android/iOS compatible).
- [x] Routing fitur baru terdaftar di app router.
- [x] Reminder logic dipisahkan dalam service (`notifications_service.dart`) agar native iOS notification integration bisa ditambahkan terpisah.
- [x] Quick Action disediakan sebagai fallback in-app jika native notification action belum diaktifkan.

## Saat mulai iOS implementation

1. Install Xcode full + CocoaPods.
2. Uji backup path pada iOS simulator (`NSDocumentDirectory`).
3. Integrasikan local notification iOS di `NotificationsService`.
4. Tambahkan iOS permission/capability notifikasi jika reminder native diaktifkan.
5. Regression test flow:
   - Setup periode
   - Quick Add transaksi
   - Daily Closing + Auto-Celengan
   - Export backup dan restore backup
   - Kalender Uang
