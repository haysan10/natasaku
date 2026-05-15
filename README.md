<p align="center">
  <img src="./natasaku_flutter/assets/branding/logo-natasaku-splash.png" width="140" alt="NataSaku logo">
</p>

<h1 align="center">NataSaku</h1>

<p align="center">
  Aplikasi budgeting Flutter yang membantu pengguna menjawab satu pertanyaan penting:
  <br>
  <strong>hari ini aman belanja berapa?</strong>
</p>

<p align="center">
  <a href="https://github.com/haysan10/natasaku/raw/main/downloads/natasaku-latest.apk">
    <img alt="Download APK" src="https://img.shields.io/badge/Download-APK-2EA44F?style=for-the-badge&logo=android&logoColor=white">
  </a>
  <a href="https://github.com/haysan10/natasaku/actions/workflows/flutter-android-apk.yml">
    <img alt="Build Flutter APK" src="https://github.com/haysan10/natasaku/actions/workflows/flutter-android-apk.yml/badge.svg">
  </a>
  <a href="./LICENSE">
    <img alt="License MIT" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
</p>

---

## Download Aplikasi

Pengguna Android bisa langsung mengunduh APK terbaru dari README ini:

[Download NataSaku APK](https://github.com/haysan10/natasaku/raw/main/downloads/natasaku-latest.apk)

Detail distribusi:

| Item | Nilai |
| --- | --- |
| Platform | Android |
| Version | `0.1.1+2` |
| Package | `com.natasaku.app` |
| Minimum Android | Android 7.0 / SDK 24 |
| File APK | [`downloads/natasaku-latest.apk`](./downloads/natasaku-latest.apk) |

Panduan instalasi lengkap tersedia di [DISTRIBUTION_APK.md](./natasaku_flutter/DISTRIBUTION_APK.md).

## Tentang Project

NataSaku adalah aplikasi keuangan pribadi yang bekerja secara offline. Aplikasi ini membantu pengguna membagi pemasukan menjadi kebutuhan tetap, target tabungan, dan jatah harian yang lebih mudah diikuti.

Prinsip produk:

- Offline-first, tanpa akun dan tanpa backend.
- Data keuangan tetap berada di perangkat pengguna.
- Fokus pada keputusan harian, bukan laporan yang rumit.
- Copywriting ramah, tidak menghakimi, dan mudah dipahami.

## Fitur Utama

- Setup periode budget dan preferensi awal.
- Dashboard kondisi keuangan harian.
- Catat transaksi pengeluaran.
- Budgeting engine untuk menghitung jatah aman harian.
- Status overbudget dan rekomendasi pemulihan.
- Savings tracker untuk target tabungan.
- Laporan bulanan, kalender uang, dan export.
- Notifikasi dan quick tools Android.

## Tampilan Project

NataSaku memakai identitas visual sederhana dengan logo dompet dan warna yang tenang. Tampilan aplikasi berfokus pada dashboard, pencatatan cepat, laporan, dan tabungan.

<p align="center">
  <img src="./natasaku_flutter/assets/branding/logo-natasaku-mark.png" width="96" alt="NataSaku app mark">
</p>

## Bedah Project

### 1. Masalah yang Diselesaikan

Banyak aplikasi finance terlalu berat untuk kebutuhan harian. NataSaku mengambil pendekatan lebih sederhana: setelah pengguna memasukkan pemasukan, pengeluaran tetap, dan target tabungan, aplikasi menghitung batas belanja harian yang realistis.

Formula utama:

```text
Dana fleksibel = total pemasukan - pengeluaran tetap - target tabungan
Jatah harian   = dana fleksibel / sisa hari periode
```

### 2. Flow Utama Pengguna

```text
Launch -> Setup Budget -> Dashboard -> Catat Transaksi -> Review Harian -> Laporan
```

Flow ini menjaga pengalaman tetap pendek. Pengguna tidak dipaksa memahami istilah finansial yang kompleks sebelum bisa mulai mencatat.

### 3. Arsitektur Flutter

Source code utama ada di folder [`natasaku_flutter/`](./natasaku_flutter).

| Folder | Peran |
| --- | --- |
| `lib/app/` | Entry app, routing, dan theme |
| `lib/core/` | Constant, error, service umum, formatter |
| `lib/data/` | Model, local storage, dan repository |
| `lib/features/` | Halaman dan modul fitur aplikasi |
| `lib/shared/` | Widget, extension, dan komponen reusable |
| `test/` | Unit test dan widget test |
| `android/` | Host Android untuk aplikasi Flutter |
| `ios/` | Host iOS untuk kesiapan multi-platform |

### 4. Modul Fitur

| Modul | Isi |
| --- | --- |
| `budgeting` | Perhitungan jatah harian, status budget, dan rekomendasi |
| `dashboard` | Ringkasan kondisi uang hari ini |
| `transactions` | Pencatatan transaksi harian |
| `daily_closing` | Review dan penutupan hari |
| `reports` | Laporan, kalender uang, dan informasi periode |
| `savings` | Target dan tracking tabungan |
| `notifications` | Reminder dan notifikasi |
| `settings` | Preferensi, backup, dan pengaturan aplikasi |

### 5. Keputusan Teknis

- Flutter dipakai sebagai stack utama aplikasi.
- `shared_preferences` digunakan untuk penyimpanan lokal ringan.
- `pdf` dan `open_filex` mendukung export dan pembukaan file laporan.
- `flutter_local_notifications` mendukung reminder di perangkat.
- CI GitHub Actions tersedia untuk build APK Android.

## Menjalankan Project

Pastikan Flutter SDK sudah terpasang, lalu jalankan:

```bash
cd natasaku_flutter
flutter pub get
flutter run
```

## Menjalankan Test

```bash
cd natasaku_flutter
flutter test
```

## Build APK Lokal

```bash
cd natasaku_flutter
flutter build apk --release
```

Output build:

```text
natasaku_flutter/build/app/outputs/flutter-apk/app-release.apk
```

## GitHub Actions

Build otomatis tersedia di:

[`Build Flutter APK`](https://github.com/haysan10/natasaku/actions/workflows/flutter-android-apk.yml)

Workflow ini bisa berjalan saat ada push ke `main` atau dijalankan manual dari tab Actions.

## Status Project

NataSaku berada pada tahap pengembangan awal menuju rilis open-source yang lebih matang. Fokus saat ini:

- Merapikan dokumentasi publik.
- Menstabilkan test suite.
- Menambah screenshot aplikasi resmi.
- Menyiapkan distribusi APK via GitHub Releases.

## Kontribusi

Kontribusi sangat terbuka. Sebelum membuat pull request, baca:

- [CONTRIBUTING.md](./CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)
- [SECURITY.md](./SECURITY.md)

Contoh kontribusi yang cocok:

- Memperbaiki bug UI.
- Menambah test untuk budgeting engine.
- Merapikan copywriting aplikasi.
- Menambah screenshot dokumentasi.
- Memperbaiki aksesibilitas.

## License

NataSaku dirilis dengan lisensi MIT. Lihat [LICENSE](./LICENSE).
