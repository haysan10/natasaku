# docs/ui-screen-spec.md - NataSaku UI Screen Specification

## Global Screen Rules

All screens must:
- Use Material Design 3.
- Use NataSaku design tokens.
- Support light and dark mode.
- Use Indonesian UI copy.
- Avoid shame-based language.
- Work offline.
- Use accessible touch targets.

## 1. Splash Screen

Purpose:
- Show brand identity and decide initial navigation.

Content:
- Logo NataSaku.
- App name.
- Tagline: “Atur uang bulanan, nikmati hidup harian.”

Behavior:
- Check `onboardingCompleted`.
- Check `activePeriodId`.
- Navigate to Welcome, Setup, or Home.

## 2. Welcome Screen

Purpose:
- Introduce app value.

Content:
- Title: “Selamat datang di NataSaku”
- Subtitle: “Atur gaji, tentukan jatah harian, dan pantau pengeluaranmu dengan lebih tenang.”
- CTA: “Mulai Atur Budget”

Layout:
- Illustration top.
- Headline.
- Subtitle.
- CTA bottom.

## 3. Onboarding Benefit Screens

Purpose:
- Explain 3 core benefits.

Slides:
1. Tahu jatah aman setiap hari.
2. Dapat warning saat melewati budget.
3. Laporan bulanan yang jelas dan bisa diunduh.

Components:
- Horizontal pager.
- Illustration.
- Dots indicator.
- Lanjut button.
- Skip optional.

## 4. Setup Periode Gajian

Purpose:
- Set budget period.

Fields:
- Tanggal gajian.
- Tanggal mulai periode.
- Tanggal akhir periode.
- Tipe periode: Bulanan, Mingguan, Dua mingguan, Custom.

Behavior:
- Period type auto-suggests start/end.
- Custom allows manual date.
- Validate endDate >= startDate.

Error:
> Tanggal akhir perlu setelah tanggal mulai.

## 5. Setup Penghasilan

Purpose:
- Record income sources.

Fields:
- Sumber penghasilan.
- Nominal penghasilan.
- Tambah sumber penghasilan lain.
- Total penghasilan otomatis.

Behavior:
- User can add multiple sources.
- Total updates automatically.
- At least one valid source required.

## 6. Setup Pengeluaran Tetap

Purpose:
- Record fixed expenses.

Categories:
- Kos / kontrakan.
- Makan.
- Transportasi.
- Listrik.
- Internet.
- Cicilan.
- Keluarga.
- Hiburan.
- Kesehatan.
- Lainnya.

Layout:
- List card category.
- Money input per category.
- Add category button.
- Total fixed expense summary.

## 7. Setup Target Tabungan

Purpose:
- Set saving target or skip.

Fields:
- Nama target tabungan.
- Nominal alokasi bulan ini.
- Progress target.
- Lewati dulu.

## 8. Review Budget

Purpose:
- Show budget result before entering app.

Display:
- Total penghasilan.
- Total pengeluaran tetap.
- Target tabungan.
- Dana fleksibel.
- Jatah harian otomatis.

CTA:
> Mulai Gunakan NataSaku

## 9. Home Dashboard

Purpose:
- Answer: “Hari ini aman atau tidak?”

Display:
- Greeting: “Halo, Ini 👋”
- Active period.
- Daily allowance hero card.
- Jatah hari ini.
- Sudah terpakai.
- Sisa hari ini.
- Status.
- Monthly progress.
- Category summary today.
- Insight.
- FAB add expense.

Status copy:
- Safe: “Aman. Pengeluaranmu masih terkendali.”
- Warning: “Waspada. Jatah hari ini hampir terpakai.”
- Overbudget: “Jatah hari ini terlewati. Kita sesuaikan agar budget bulanan tetap aman.”

## 10. Add Expense Bottom Sheet

Purpose:
- Fast transaction entry.

Fields:
- Nominal.
- Kategori.
- Tanggal.
- Catatan.
- Simpan button.

Requirements:
- Nominal autofocus.
- Numeric keyboard.
- Date defaults to today.
- Note optional.
- Save should be possible in about 10 seconds.

## 11. Warning Overbudget Dialog

Purpose:
- Warn user gently.

Trigger:
- `spentToday > finalDailyAllowance`

Copy:
- Title: “Jatah hari ini terlewati”
- Body: “Pengeluaran hari ini melebihi jatah sebesar Rp20.000.”
- Helper: “Agar budget bulanan tetap aman, jatah besok akan disesuaikan.”
- Actions: “Saya Mengerti”, “Lihat Detail”

## 12. Leftover Allocation Dialog

Purpose:
- Let user allocate daily leftover.

Trigger:
- `remainingToday > 0` and not allocated.

Options:
- Tambah ke jatah besok.
- Masukkan ke tabungan.
- Bagi otomatis.
- Simpan sebagai saldo bebas.

## 13. Transaction History Screen

Purpose:
- Review and manage transactions.

Display:
- Search.
- Category filters.
- Total spending for filter result.
- Transactions grouped by date.
- Edit/delete.

Empty:
- Title: “Belum ada transaksi”
- Description: “Pengeluaran yang kamu catat akan muncul di sini.”
- CTA: “Catat Pengeluaran”

## 14. Budget Screen

Purpose:
- Explain current budget structure.

Display:
- Active period.
- Income.
- Fixed expenses.
- Saving target.
- Base daily allowance.
- Today adjustment.
- Edit budget button.

## 15. Saving Screen

Purpose:
- Show saving target progress.

Display:
- Target tabungan.
- Progress bar.
- Total terkumpul.
- Sisa harian that entered saving.
- Allocation history.

## 16. Monthly Report Screen

Purpose:
- Show monthly finance summary.

Display:
- Total penghasilan.
- Total pengeluaran.
- Total tabungan.
- Sisa akhir bulan.
- Kategori terbesar.
- Hari paling boros.
- Hari paling hemat.
- Jumlah hari overbudget.
- Rata-rata pengeluaran harian.
- Rekomendasi bulan depan.

CTA:
- Download PDF.
- Export CSV.

## 17. Export Success Screen

Purpose:
- Confirm export completed.

Display:
- Success icon.
- File berhasil dibuat.
- File name.
- Share button.
- Open file button.

## 18. Settings Screen

Purpose:
- Manage local app preferences.

Items:
- Mata uang.
- Tema.
- Default alokasi sisa harian.
- Pengingat harian.
- Backup data.
- Restore data.
- Tentang aplikasi.
