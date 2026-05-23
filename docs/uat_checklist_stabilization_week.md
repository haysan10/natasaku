# UAT Checklist - Stabilization Week (Android)

## Tujuan

Memastikan NataSaku stabil, akurat, dan siap masuk release candidate Android internal.

## Lingkup

- Setup periode dan dana fleksibel.
- Dashboard, Quick Add, Cek Sebelum Beli.
- Daily Closing + Auto-Celengan.
- Transaksi, Laporan, Kalender Uang.
- Reminder/Quick Action center.
- Backup/Restore.

## Data Uji Disarankan

- Periode: `2026-05-01` s/d `2026-05-30`
- Dana fleksibel awal: `Rp1.500.000`
- Sampel transaksi:
  - Pengeluaran: `25.000`, `80.000`, `150.000`
  - Pemasukan: `200.000`

## Checklist Fungsional

- [ ] User bisa setup periode dan simpan tanpa crash.
- [ ] Dashboard menampilkan jatah harian, status harian, status periode.
- [ ] Status harian mengikuti aturan threshold (<=70%, >70%-100%, >100%-120%, >120%).
- [ ] Status dana periode terpisah dari status harian.
- [ ] Quick Add pengeluaran tersimpan dan memengaruhi dashboard.
- [ ] Quick Add pemasukan tersimpan dan memengaruhi dashboard.
- [ ] Fitur "Saya Lupa Catat" menyimpan transaksi tanggal lampau.
- [ ] Daily Closing tersimpan.
- [ ] Saat carry-over positif dan Auto-Celengan aktif, saldo tabungan bertambah.
- [ ] Cek Sebelum Beli menampilkan keputusan + prediksi + rekomendasi.
- [ ] Mode Budget (Normal/Hemat/Krisis) memengaruhi jatah harian.
- [ ] Mode Penggunaan (Cepat/Dibimbing/Detail) tersimpan.
- [ ] Laporan sederhana menampilkan metrik dasar.
- [ ] Kalender Uang menampilkan ringkasan sesuai tanggal.
- [ ] Reminder settings (on/off + jam) tersimpan.
- [ ] Export backup berhasil membuat file.
- [ ] Restore backup berhasil memulihkan data.

## Checklist Kualitas Data

- [ ] Tidak ada NaN/Infinity di dashboard, laporan, atau simulasi.
- [ ] Tidak ada double-counting setelah edit alur (quick add -> refresh -> reopen app).
- [ ] Nilai Rupiah selalu konsisten format `Rp`.
- [ ] Data tetap ada setelah app ditutup paksa lalu dibuka ulang.
- [ ] Restore backup tidak membuat data corrupt.

## Checklist UX

- [ ] Copy tidak menghakimi user.
- [ ] Warning selalu diikuti saran aksi.
- [ ] Flow tetap bisa dipakai walau data belum lengkap.
- [ ] Tombol utama mudah ditemukan (Quick Add, Daily Closing, Cek Sebelum Beli).
- [ ] Spacing/warna/kartu konsisten dengan tema NataSaku.

## Checklist Device Matrix (Android)

- [ ] Low-end device (RAM kecil): launch, transaksi, dashboard tetap responsif.
- [ ] Mid-range device: semua flow utama lancar.
- [ ] High-end device: tidak ada regressi UI atau freeze.

## Go / No-Go Criteria

**GO** jika:
- Semua checklist fungsional critical lulus.
- Tidak ada bug P0/P1.
- Data integrity aman (tidak hilang/tidak dobel/tidak corrupt).

**NO-GO** jika:
- Ada crash di flow utama.
- Ada salah hitung jatah/status.
- Backup/restore gagal untuk data nyata.
