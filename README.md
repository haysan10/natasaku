# NataSaku

[![Build Status](https://img.shields.io/badge/Build-Verified-success.svg)](#)
[![Download APK](https://img.shields.io/badge/Download-Release%20APK-blue.svg)](_releases/natasaku-v1.0.5-release.apk)

**NataSaku** adalah aplikasi Android offline-first yang dirancang untuk membantu pengguna mengelola keuangan pribadi dengan pendekatan alokasi dana harian yang adaptif dan bebas stres.

> "Atur uang bulanan, nikmati hidup harian."

### Status Project: 🚀 Stable Production (v1.0.5)
Aplikasi telah melalui pengerasan (*hardening*) kode sumber, pembersihan scaffolding AI development, pengujian fungsionalitas asinkronus lokal, dan berhasil dikompilasi ke APK Rilis final dengan SDK target Android 36 (kompatibel hingga Android 7.0+ / API 24).

---

## 1. Core Product Idea
NataSaku menjawab satu pertanyaan mendasar bagi pengguna:
**"Hari ini saya aman belanja berapa?"**

Aplikasi menghitung dana harian secara otomatis berdasarkan formula keuangan:
```text
Dana Fleksibel = Total Penghasilan - Pengeluaran Tetap - Target Tabungan
Jatah Harian = Dana Fleksibel / Sisa Hari Periode
```

Jika pengeluaran harian melebihi jatah harian, aplikasi akan memberikan peringatan bersahabat dan menghitung ulang jatah hari berikutnya secara dinamis.

---

## 2. Fitur Utama
* 📱 **Onboarding & Setup Mudah**: Konfigurasi cepat untuk periode gajian, total income, alokasi tabungan impian, dan daftar pengeluaran tetap.
* 🛠️ **Multi Fixed Expenses**: Kelola daftar tagihan rutin (kos, listrik, cicilan) secara dinamis.
* 📊 **Laporan Finansial Premium**: Laporan eksekutif PDF 4-halaman (grafik kesehatan, tabel pengeluaran kategori, rencana aksi) dan file Excel 3-sheet siap olah (Ringkasan, Transaksi, Data Pivot).
* 💾 **Backup & Restore Lokal**: Ekspor dan impor data dalam format JSON terenkripsi lokal untuk keamanan privasi penuh tanpa cloud/internet.
* 🔊 **Efek Suara Interaktif**: Nada bel ramah saat mencatat transaksi atau mencapai target tabungan.

---

## 3. Tech Stack
* **Core**: Flutter & Dart (Offline-First)
* **State Management**: Flutter Riverpod
* **Local Storage**: `shared_preferences`
* **Local Notifications**: `flutter_local_notifications`
* **File Export**: `pdf`, `excel`, `open_filex`, `share_plus`
* **UI & Animation**: Phosphor Icons, Google Fonts, `flutter_animate`

---

## 4. Cara Menjalankan Project

### Prasyarat
* Flutter SDK `>= 3.10.0`
* Dart SDK `>= 3.0.0`
* Android SDK (minSdk 24, targetSdk 34)

### Langkah Pemasangan
1. Masuk ke direktori aplikasi Flutter:
   ```bash
   cd natasaku_flutter
   ```
2. Ambil paket dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan pengujian:
   ```bash
   flutter test
   ```
4. Jalankan aplikasi di emulator atau perangkat:
   ```bash
   flutter run
   ```

---

## 5. Build Release APK
Untuk mengompilasi APK rilis dengan pembagian arsitektur untuk meminimalkan ukuran file:
```bash
cd natasaku_flutter
flutter build apk --release --split-per-abi
```
File APK rilis final hasil kompilasi siap unduh juga disediakan langsung di folder [`_releases/natasaku-v1.0.5-release.apk`](_releases/natasaku-v1.0.5-release.apk).

---

## 6. Arsip Scaffolding AI
Dokumen perencanaan dan scaffolding pengembangan AI dipindahkan ke [`_archive/ai-scaffolding/`](_archive/ai-scaffolding/) agar root project tetap bersih dan siap untuk rilis produksi.
