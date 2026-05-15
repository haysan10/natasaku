# NataSaku Design Spec
Date: 2026-05-11
Topic: Fix jatah harian, unify report/export data source, and add in-app notification diagnostics

## 1. Latar Belakang
Ditemukan tiga masalah utama pada aplikasi:
1. Jatah harian tidak berkurang walau transaksi pengeluaran valid sudah tersimpan.
2. Export CSV/PDF bisa terunduh tetapi isi kosong.
3. Belum ada cara mengecek fungsi notifikasi langsung dari dalam aplikasi.

Data validasi dari user:
- Periode aktif setup: 24 April 2026 - 25 Mei 2026.
- Transaksi pengeluaran dibuat pada 11 Mei 2026 sebesar Rp22.000 dan Rp50.000.
- Pengeluaran Bulan Ini bertambah (berarti data tersimpan), tetapi Jatah Harian tetap sama.
- CSV dan PDF terunduh tetapi kosong.

## 2. Tujuan
1. Menjadikan kalkulasi dashboard, laporan, dan export konsisten dari satu sumber data.
2. Memastikan jatah harian langsung menurun saat pengeluaran bertambah di periode aktif.
3. Memastikan CSV/PDF terisi sesuai data tampil.
4. Menambahkan fitur diagnosis notifikasi di tab Setup.

## 3. Prinsip Solusi
- Single Source of Truth untuk kalkulasi finansial.
- Tidak mengubah storage key secara breaking.
- Perubahan incremental pada file yang ada (`index.html`, bridge native, receiver) tanpa rewrite arsitektur.

## 4. Desain Arsitektur

### 4.1 Fungsi inti baru: `buildFinanceSnapshot()`
Fungsi menghasilkan satu objek snapshot untuk dipakai lintas fitur.

Struktur output:
- `dashboard`
  - `periodStart`, `periodEnd`
  - `dailyBudgetBase`
  - `totalExpensesInPeriod`
  - `remainingFlexible`
  - `remainingDays`
  - `dailyAllowance`
  - `todayExpense`, `todayIncome`
- `report`
  - `monthTransactions`
  - `filteredTransactions`
  - `summary` (`totalIncome`, `totalExpense`, `remainingBalance`, `estimatedSavings`, dll)
  - `categoryBreakdown`, `filteredCategoryBreakdown`
  - `dailyGroups`
  - `insights`
- `export`
  - `rows`
  - `totalRows`
  - `totalAmount`
  - `fileMonthLabel`
- `reminderCheck`
  - `permissionStatus`
  - `hasExpenseToday`
  - `withinReminderHour`
  - `muted`
  - `eligible`
  - `reasons[]`

### 4.2 Konsumen snapshot
- `renderDashboard()` membaca `snapshot.dashboard`.
- `renderReport()` membaca `snapshot.report`.
- `downloadCSVReport()` dan `downloadPDFReport()` membaca `snapshot.export`.
- Simulasi reminder membaca `snapshot.reminderCheck` + evaluasi native.

## 5. Perbaikan Bug Jatah Harian
Masalah target:
- Dashboard tetap menunjukkan angka lama meski transaksi pengeluaran baru tersimpan.

Perbaikan:
1. Hitung ulang jatah harian hanya dari transaksi `Jenis === Pengeluaran` dalam periode aktif.
2. Setelah `add/edit/delete` transaksi, regenerate snapshot lalu rerender dashboard/report/saving dari data yang sama.
3. Pastikan `dailyAllowance = (dailyBudgetBase - totalExpensesInPeriod) / remainingDays`.
4. Tambah guard perhitungan tanggal supaya memakai normalisasi lokal yang konsisten.

## 6. Perbaikan Export Kosong (CSV/PDF)

### 6.1 CSV
- Bangun row dari `snapshot.export.rows`.
- Validasi sebelum export:
  - `totalRows > 0`
  - `totalAmount > 0`
- Jika tidak valid, tampilkan pesan: `Data laporan kosong untuk periode/filter ini.`

### 6.2 PDF
- Data isi PDF juga diambil dari `snapshot.export.rows` + `snapshot.report.summary`.
- Validasi sama seperti CSV sebelum generate.
- Untuk native export: kirim payload PDF yang sudah terisi data dari snapshot.

## 7. Fitur Diagnostik Notifikasi (Tab Setup)

### 7.1 UI baru di Setup
Section: `Pengingat & Diagnostik Notifikasi`
- Status izin notifikasi.
- Jam reminder aktif.
- Tombol `Tes Cepat Notifikasi`.
- Tombol `Simulasi Reminder Asli`.
- Area hasil simulasi (`Lolos/Gagal + alasan`).

### 7.2 Native bridge baru
Tambahan API pada `NataSakuNative`:
- `sendTestNotificationNow()`
  - Mengirim notifikasi uji saat tombol ditekan.
- `runReminderSimulation(snapshotJson)`
  - Menjalankan evaluasi rule reminder aktual dan mengembalikan JSON hasil.

### 7.3 Rule simulasi
- Cek permission notifikasi.
- Cek apakah sudah ada pengeluaran hari ini.
- Cek jam saat ini terhadap reminder hours.
- Cek status mute/snooze.
- Return `eligible` + daftar `reasons`.

## 8. Dampak Data & Kompatibilitas
- Tidak mengganti storage key.
- Tidak menghapus data lama.
- Normalisasi transaksi tetap dipakai.
- Perubahan bersifat kompatibel dengan data existing localStorage.

## 9. Rencana Validasi

### 9.1 Repro bug utama
- Setup periode: 2026-04-24 s/d 2026-05-25.
- Tambah pengeluaran tanggal 2026-05-11: Rp22.000 dan Rp50.000.
- Verifikasi:
  - Pengeluaran Bulan Ini naik Rp72.000.
  - Jatah Harian turun setelah simpan transaksi.

### 9.2 Validasi export
- CSV terunduh dan berisi header + data transaksi.
- PDF terunduh dan berisi ringkasan + rincian transaksi.
- Nilai total di file = nilai total di layar.

### 9.3 Validasi notifikasi
- Tes cepat menghasilkan notifikasi langsung.
- Simulasi menampilkan status + alasan sesuai kondisi aktual.

### 9.4 Build checks
- `./gradlew :app:assembleDebug`
- `./gradlew :app:assembleRelease`

## 10. Risiko & Mitigasi
- Risiko mismatch waktu lokal/UTC pada filter tanggal.
  - Mitigasi: semua perhitungan tanggal lewat helper normalisasi yang sama.
- Risiko UI report menampilkan data berbeda dari export.
  - Mitigasi: report + export membaca snapshot yang sama.

## 11. Scope Implementasi
Termasuk:
- Refactor kalkulasi ke snapshot tunggal.
- Perbaikan jatah harian.
- Perbaikan export kosong.
- Fitur diagnostik notifikasi di Setup.

Tidak termasuk:
- Migrasi arsitektur besar (native full UI/Compose).
- Perubahan struktur storage yang breaking.
