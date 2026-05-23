# conductor/product.md — NataSaku Product Context

## Product Name

NataSaku

## One-Line Description

NataSaku adalah aplikasi Android offline-first untuk membantu user mengatur penghasilan pribadi menjadi pengeluaran tetap, target tabungan, jatah harian, pencatatan pengeluaran, dan laporan bulanan.

## Tagline

Atur uang bulanan, nikmati hidup harian.

---

## Product Vision

Membuat aplikasi budgeting Android yang terasa seperti manager keuangan pribadi yang ramah: membantu user tahu berapa jatah aman per hari, memberi warning saat melewati budget, dan menghasilkan laporan bulanan yang jelas tanpa membuat user merasa bersalah.

---

## Problem Statement

Banyak orang menerima penghasilan bulanan, mingguan, dua mingguan, atau tidak tetap, tetapi sulit mengetahui berapa uang yang aman digunakan setiap hari setelah membayar pengeluaran tetap dan menyisihkan tabungan.

Aplikasi budgeting sering terlalu rumit, terlalu terasa seperti bank, membutuhkan login, atau menghakimi user saat pengeluaran melebihi rencana.

---

## Solution Approach

NataSaku menyederhanakan budgeting menjadi:

```text
Penghasilan
- Pengeluaran tetap
- Target tabungan
= Dana fleksibel

Dana fleksibel / jumlah hari periode
= Jatah harian
```

User cukup:
1. Mengatur periode gajian.
2. Memasukkan penghasilan.
3. Memasukkan pengeluaran tetap.
4. Memasukkan target tabungan.
5. Melihat jatah harian.
6. Mencatat pengeluaran.
7. Melihat status harian dan laporan bulanan.

---

## Target Users

### 1. Pekerja Gajian

Needs:
- Mengatur gaji bulanan.
- Menyisihkan biaya wajib.
- Tahu jatah aman harian.
- Tidak kehabisan uang sebelum gajian berikutnya.

### 2. Mahasiswa

Needs:
- Mengatur uang bulanan, beasiswa, part-time, atau kiriman keluarga.
- Mencatat makan, kos, transportasi, internet, dan hiburan.
- Menjaga pengeluaran tetap terkendali.

### 3. Freelancer

Needs:
- Mengelola penghasilan tidak tetap.
- Menambah beberapa sumber penghasilan.
- Menggunakan periode custom.
- Melihat dana fleksibel dan jatah harian.

### 4. Pengguna Umum

Needs:
- Mencatat pengeluaran.
- Menabung.
- Melihat laporan bulanan.
- Memahami pola pengeluaran.

---

## Core Features

1. Onboarding.
2. Setup periode gajian.
3. Input penghasilan.
4. Input pengeluaran tetap.
5. Input target tabungan.
6. Review budget.
7. Hitung jatah harian otomatis.
8. Home dashboard.
9. Catat pengeluaran.
10. Warning overbudget.
11. Alokasi sisa jatah harian.
12. Riwayat transaksi.
13. Budget detail.
14. Tabungan.
15. Laporan bulanan.
16. Export PDF.
17. Export CSV.
18. Settings.
19. Backup lokal.
20. Restore lokal.

---

## Main User Flow

### First-Time Flow

```text
Splash
→ Welcome
→ Onboarding Benefit Screens
→ Setup Periode Gajian
→ Setup Penghasilan
→ Setup Pengeluaran Tetap
→ Setup Target Tabungan
→ Review Budget
→ Home Dashboard
```

### Daily Flow

```text
Open App
→ Home Dashboard
→ Lihat jatah hari ini
→ Tambah pengeluaran
→ Dashboard update
→ Jika overbudget, warning muncul
→ Jika ada sisa, user bisa alokasikan
```

### Report Flow

```text
Open Laporan
→ Lihat ringkasan bulanan
→ Download PDF / Export CSV
→ Export Success
→ Share / Open File
```

---

## MVP Scope

### Must Have

1. Splash.
2. Welcome.
3. Onboarding.
4. Setup period.
5. Setup income.
6. Setup fixed expense.
7. Setup saving target.
8. Review budget.
9. Home dashboard.
10. Add expense bottom sheet.
11. Overbudget dialog.
12. Transaction history.
13. Budget screen.
14. Saving screen.
15. Monthly report.
16. Export CSV.
17. Export PDF.
18. Settings.
19. Backup.
20. Restore.

### Should Have

1. Leftover allocation dialog.
2. Daily reminder local notification.
3. Better empty states.
4. Dark mode polish.
5. Report recommendations.

### Could Have Later

1. Advanced charts.
2. Multiple active budget templates.
3. Biometric lock.
4. Import CSV.
5. More report comparison.

---

## Non-Goals

Do not build:

1. Login.
2. Register account.
3. Backend.
4. Cloud sync.
5. Bank integration.
6. E-wallet integration.
7. Payment gateway.
8. Ads.
9. Analytics.
10. Subscription.
11. Social sharing of finance data.
12. Online AI features.

---

## Success Criteria

NataSaku succeeds if:

1. User can finish setup in 3–5 minutes.
2. User can add expense in about 10 seconds.
3. Dashboard answers “hari ini aman atau tidak?” within a few seconds.
4. All core features work offline.
5. Budget calculations are correct and tested.
6. App feels calm, friendly, and professional.
7. Reports export successfully.
8. Backup and restore work safely.
9. UI supports light and dark mode.
10. Accessibility basics are satisfied.

---

## Product Risks

### Risk: Calculation feels confusing

Mitigation:
- Show Review Budget.
- Explain formula simply.
- Put adjustment details in Budget screen.

### Risk: User stops tracking

Mitigation:
- Fast add expense.
- Default date today.
- Category quick chips.
- Minimal required fields.

### Risk: Warning feels judgmental

Mitigation:
- Use friendly copy.
- Avoid shame-based language.
- Use soft red, not aggressive red.

### Risk: Data loss during restore

Mitigation:
- Validate backup schema.
- Ask confirmation.
- MVP restore mode should be replace-only with clear warning.

---

## Product Rule

When uncertain, choose the simpler offline solution that helps user understand daily allowance quickly.
