# Test Script Harian E2E (Founder/QA)

## Skenario 1 - First Setup sampai Dashboard

1. Buka app baru.
2. Masuk `Setup Periode`.
3. Isi:
   - Dana fleksibel: `1500000`
   - Tanggal mulai: `2026-05-01`
   - Tanggal selesai: `2026-05-30`
   - Mode: `Normal`
4. Tap `Simpan Setup`.
5. Verifikasi:
   - Dashboard tampil.
   - Card `Jatah kamu hari ini` muncul.
   - `Status Hari Ini` dan `Status Dana Periode` muncul.

Expected:
- Tidak ada error/crash.
- Nilai jatah harian terbentuk.

## Skenario 2 - Quick Add + Update Real-time

1. Di Dashboard, tap `Quick Add -`.
2. Isi nominal `25000`, simpan.
3. Tap `Quick Add +`.
4. Isi nominal `200000`, simpan.
5. Pull-to-refresh dashboard.

Expected:
- Pengeluaran hari ini dan pemasukan hari ini berubah sesuai input.
- Dana fleksibel tersisa ikut berubah.
- Tidak ada angka invalid.

## Skenario 3 - Saya Lupa Catat

1. Tap `Saya Lupa Catat`.
2. Isi nominal `80000`.
3. Pilih tanggal kemarin.
4. Simpan.
5. Buka tab `Transaksi`.

Expected:
- Transaksi muncul dengan tanggal lampau.
- Tidak mengganggu transaksi hari ini.

## Skenario 4 - Cek Sebelum Beli (Simulasi)

1. Dari Dashboard tap `Cek Sebelum Beli`.
2. Isi nominal rencana `150000`.
3. Simulasikan.

Expected:
- Muncul card `Hasil Cek Sebelum Beli`.
- Ada keputusan (`Boleh belanja` atau `Sebaiknya tunda`).
- Ada prediksi jatah besok, prediksi sisa akhir periode, rekomendasi.

## Skenario 5 - Mode Budget & Mode Penggunaan

1. Tap `Ganti Mode Budget`, pilih `Hemat`.
2. Cek nilai jatah harian.
3. Ganti ke `Krisis`, cek lagi.
4. Tap `Ganti Mode Input`, pilih `Dibimbing`.
5. Tutup app lalu buka lagi.

Expected:
- Jatah harian menyesuaikan mode.
- Mode tetap tersimpan setelah reopen app.

## Skenario 6 - Daily Closing + Auto-Celengan

1. Buka tab `Tabungan`, pastikan `Auto-Celengan` aktif.
2. Kembali ke Dashboard, masuk `Daily Closing`.
3. Simpan daily closing.
4. Kembali ke tab `Tabungan`.

Expected:
- Jika carry-over positif: saldo Auto-Celengan bertambah.
- Riwayat alokasi tabungan bertambah 1 entri.

## Skenario 7 - Laporan + Kalender Uang

1. Buka tab `Laporan`.
2. Cek metrik:
   - Total pemasukan
   - Total pengeluaran
   - Rata-rata pengeluaran
3. Tap `Kalender Uang`.
4. Pilih beberapa tanggal yang ada transaksi.

Expected:
- Nilai metrik konsisten dengan transaksi.
- Kalender menampilkan ringkasan per tanggal.

## Skenario 8 - Reminder & Quick Action

1. Dari Dashboard tap `Reminder & Quick Action`.
2. Aktifkan reminder.
3. Ganti jam reminder.
4. Gunakan quick action in-app ke Beranda/Transaksi/Daily Closing.

Expected:
- Setting reminder tersimpan.
- Navigasi quick action bekerja.

## Skenario 9 - Backup & Restore

1. Buka tab `Laporan`.
2. Tap `Export Backup`.
3. Catat pesan status backup berhasil.
4. Tambahkan 1 transaksi baru.
5. Tap `Restore Backup`.
6. Reload laporan/transaksi.

Expected:
- File backup terbentuk.
- Restore berhasil.
- Data kembali ke snapshot backup terakhir.

## Skenario 10 - Persistence & Force Close

1. Setelah data cukup, tutup paksa app.
2. Buka ulang app.
3. Cek dashboard, transaksi, tabungan, laporan.

Expected:
- Data tetap ada.
- Tidak ada reset tak terduga.
- Tidak muncul NaN/Infinity/null rusak.

## Defect Logging Format

- `ID`: BUG-###
- `Area`: Dashboard / Setup / Transaction / Closing / Saving / Report / Reminder / Backup
- `Severity`: P0 / P1 / P2 / P3
- `Steps to Reproduce`: langkah singkat
- `Expected`: hasil yang diharapkan
- `Actual`: hasil aktual
- `Device`: model + Android version
- `Build`: versi app
