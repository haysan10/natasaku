# NataSaku

NataSaku adalah aplikasi budgeting **Flutter** (offline-first) untuk membantu pengguna mengelola pemasukan, pengeluaran, tabungan, dan laporan bulanan dengan alur yang sederhana.

## Fokus Stack

Repository ini sekarang difokuskan ke **Flutter only**.  
Kode Kotlin Android native lama sudah dihapus dari root project.

## Fitur Utama

- Setup periode budget dan preferensi pengguna
- Dashboard ringkas kondisi keuangan
- Catat transaksi harian
- Budgeting engine + status overbudget
- Savings tracker
- Laporan dan export
- Build APK Android

## Struktur Repository

- `natasaku_flutter/` - source code utama aplikasi Flutter
- `downloads/` - APK siap unduh
- `.github/workflows/` - CI build APK

## Menjalankan Project

```bash
cd natasaku_flutter
flutter pub get
flutter run
```

## Build APK

```bash
cd natasaku_flutter
flutter build apk --release
```

APK hasil build lokal:

`natasaku_flutter/build/app/outputs/flutter-apk/app-release.apk`

## Download APK

- [downloads/natasaku-latest.apk](./downloads/natasaku-latest.apk)
- Panduan instalasi: [natasaku_flutter/DISTRIBUTION_APK.md](./natasaku_flutter/DISTRIBUTION_APK.md)

## Continuous Integration

Workflow GitHub Actions:

- `.github/workflows/flutter-android-apk.yml`

Workflow ini build APK Flutter secara otomatis pada push ke `main` dan juga bisa dijalankan manual.

## Kontribusi

Silakan baca [CONTRIBUTING.md](./CONTRIBUTING.md), [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md), dan [SECURITY.md](./SECURITY.md) sebelum membuat PR.

## License

Project ini menggunakan lisensi MIT. Lihat [LICENSE](./LICENSE).
