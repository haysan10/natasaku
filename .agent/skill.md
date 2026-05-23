# .agent/skill.md — NataSaku Antigravity Agent Skill

## 1. Identitas Project

**Nama aplikasi:** NataSaku  
**Platform:** Android Native  
**Bahasa utama:** Kotlin  
**UI:** Jetpack Compose  
**Design system:** Material Design 3  
**Storage:** Offline-first, local data only  
**Database:** Room  
**Preferences:** DataStore  
**Arsitektur:** MVVM + Clean Architecture ringan  
**Target produk:** aplikasi budgeting penghasilan pribadi berbasis Android offline.

NataSaku membantu user mengatur penghasilan menjadi:
- pengeluaran tetap,
- target tabungan,
- jatah harian otomatis,
- pencatatan pengeluaran,
- warning overbudget,
- alokasi sisa jatah harian,
- laporan bulanan,
- export PDF dan CSV,
- backup dan restore lokal.

---

## 2. Prinsip Utama Semua Agent

Semua agent wajib mematuhi aturan berikut:

1. Jangan menambahkan login.
2. Jangan menambahkan backend.
3. Jangan menambahkan cloud sync.
4. Jangan menambahkan integrasi bank.
5. Jangan menambahkan payment gateway.
6. Jangan menambahkan analytics online.
7. Jangan menambahkan ads.
8. Jangan membutuhkan internet untuk fitur inti.
9. Semua data user harus disimpan lokal.
10. Gunakan Kotlin dan Jetpack Compose.
11. Gunakan Material Design 3.
12. Gunakan Room untuk data utama.
13. Gunakan DataStore untuk preferences.
14. Gunakan bahasa UI Indonesia.
15. Copywriting harus ramah dan tidak menghakimi.
16. Jangan memakai kata seperti “boros”, “gagal”, “salah”, atau “tidak disiplin”.
17. Gunakan token warna dan typography, jangan hardcode warna di banyak tempat.
18. Pisahkan business logic dari UI.
19. Semua calculation harus bisa diuji unit test.
20. Semua fitur penting harus support light mode dan dark mode.
21. Semua interactive component minimal 48dp touch target.
22. Semua icon button wajib punya contentDescription.
23. Jangan membuat dashboard terlalu penuh.
24. Prioritaskan fitur MVP sebelum polish lanjutan.
25. Jangan mengubah product direction tanpa alasan kuat.

---

## 3. Brand Direction

**Nama:** NataSaku  
**Makna:** menata saku, mengatur uang pribadi dengan tenang.  
**Tagline:** Atur uang bulanan, nikmati hidup harian.

### Personality

- Helpful.
- Calm.
- Friendly.
- Professional.
- Tidak menghakimi.
- Seperti manager keuangan pribadi yang ramah.

### UX Tone

Gunakan:
- “Jatah kamu hari ini”
- “Pengeluaranmu masih terkendali”
- “Jatah hari ini terlewati”
- “Budget akan disesuaikan”
- “Kamu masih punya sisa”
- “Mulai dari nominal kecil juga tidak apa-apa”

Hindari:
- “Kamu boros”
- “Budget gagal”
- “Kamu salah”
- “Tidak disiplin”
- “Pengeluaran buruk”

---

## 4. Visual System

### Light Mode Colors

| Token | Hex |
|---|---|
| primary | #0F9F8C |
| primaryDark | #08786A |
| primarySoft | #DDF7F1 |
| secondaryMint | #7EDDC8 |
| background | #FAFBF7 |
| surface | #FFFFFF |
| surfaceVariant | #F1F5F3 |
| textPrimary | #1D2523 |
| textSecondary | #66736F |
| border | #DDE7E3 |
| success | #2EAD6B |
| warning | #F59E3D |
| error | #E85D5D |
| errorSoft | #FDECEC |
| info | #4A90E2 |

### Dark Mode Colors

| Token | Hex |
|---|---|
| background | #0F1514 |
| surface | #17201E |
| surfaceVariant | #20302D |
| primary | #7EE5D3 |
| primaryContainer | #114D45 |
| textPrimary | #EEF7F4 |
| textSecondary | #A8BBB5 |
| border | #2E403B |
| success | #7DDC9D |
| warning | #F4B96A |
| error | #FF8A8A |

### Typography

Gunakan Roboto atau system font Android.

Recommended scale:
- Display Small: 32sp, Bold.
- Headline Medium: 28sp, Bold.
- Headline Small: 24sp, Bold.
- Title Large: 22sp, SemiBold.
- Title Medium: 16sp, SemiBold.
- Body Large: 16sp, Regular.
- Body Medium: 14sp, Regular.
- Label Large: 14sp, SemiBold.
- Label Medium: 12sp, Medium.

### Spacing

- Screen horizontal padding: 20dp.
- Section spacing: 24dp.
- Card padding: 16–20dp.
- Card radius: 20–28dp.
- Button radius: 16dp.
- Bottom sheet radius: 28dp top corners.
- FAB size: 56dp.
- Minimum touch target: 48dp.

---

## 5. Architecture Rule

Gunakan struktur berikut:

```text
app/
  data/
    local/
      dao/
      entity/
      database/
      datastore/
    repository/
    export/
    backup/
  domain/
    model/
    repository/
    usecase/
    calculator/
  presentation/
    navigation/
    theme/
    component/
    screen/
      splash/
      onboarding/
      setup/
      home/
      transaction/
      budget/
      saving/
      report/
      settings/
  util/
```

### Dependency Rules

1. `presentation` boleh bergantung ke `domain`.
2. `domain` tidak boleh bergantung ke Android UI.
3. `domain` tidak boleh tahu Room, Compose, atau Context.
4. `data` mengimplementasikan repository interface dari `domain`.
5. Calculation berada di `domain/calculator`.
6. Export PDF/CSV berada di `data/export` atau `domain` interface + `data` implementation.
7. Backup/restore berada di `data/backup`.
8. Compose screen hanya consume `UiState` dan send `UiEvent`.

---

## 6. Core Calculation Rules

### Flexible Fund

```text
flexibleFund = totalIncome - totalFixedExpense - totalSavingTarget
```

### Base Daily Allowance

```text
numberOfDays = daysBetween(startDate, endDate) + 1
baseDailyAllowance = flexibleFund / numberOfDays
```

### Daily Status

```text
usageRatio = spentToday / finalDailyAllowance
```

Rules:
- SAFE jika usageRatio <= 0.70.
- WARNING jika usageRatio > 0.70 dan <= 1.00.
- OVER_BUDGET jika usageRatio > 1.00.

Jika finalDailyAllowance == 0:
- spentToday == 0 berarti SAFE.
- spentToday > 0 berarti OVER_BUDGET.

### Overbudget Adjustment

```text
overbudgetAmount = spentToday - finalDailyAllowance
remainingDays = tomorrow until period end
adjustmentPerDay = overbudgetAmount / remainingDays
```

Jika remainingDays <= 0:
- Jangan adjust future allowance.
- Catat sebagai report insight.

### Leftover Allocation

Jika remainingToday > 0, user dapat memilih:
- Tambah ke jatah besok.
- Masukkan ke tabungan.
- Bagi otomatis.
- Simpan sebagai saldo bebas.

Default auto split:
- 50% ke tabungan.
- 50% ke jatah besok.

---

## 7. Required Screens

Semua agent harus mengacu pada daftar screen berikut:

1. Splash Screen.
2. Welcome Screen.
3. Onboarding Benefit Screens.
4. Setup Periode Gajian.
5. Setup Penghasilan.
6. Setup Pengeluaran Tetap.
7. Setup Target Tabungan.
8. Review Budget.
9. Home Dashboard.
10. Add Expense Bottom Sheet.
11. Warning Overbudget Dialog.
12. Leftover Allocation Dialog.
13. Transaction History Screen.
14. Budget Screen.
15. Saving Screen.
16. Monthly Report Screen.
17. Export Success Screen.
18. Settings Screen.

---

## 8. Main Navigation

First-time flow:

```text
Splash
→ Welcome
→ Onboarding
→ Setup Period
→ Setup Income
→ Setup Fixed Expense
→ Setup Saving Target
→ Review Budget
→ Home
```

Main app bottom navigation:
- Beranda.
- Transaksi.
- Budget.
- Tabungan.
- Laporan.

Settings:
- Diakses dari top app bar atau overflow menu.

---

## 9. Agent Team

Gunakan agent berikut untuk membangun project:

1. `product-manager.md`
2. `android-architect.md`
3. `domain-budget-engineer.md`
4. `room-database-engineer.md`
5. `compose-ui-engineer.md`
6. `design-system-engineer.md`
7. `navigation-flow-engineer.md`
8. `export-backup-engineer.md`
9. `qa-test-engineer.md`
10. `accessibility-reviewer.md`
11. `copywriting-ux-reviewer.md`
12. `integration-lead.md`

Masing-masing agent memiliki file detail di `.agent/agents/`.

---

## 10. Coordination Protocol

### Before starting work

Setiap agent harus:
1. Membaca `.agent/skill.md`.
2. Membaca file agent masing-masing.
3. Mengidentifikasi scope pekerjaannya.
4. Menulis rencana singkat.
5. Menentukan file yang akan dibuat/diubah.
6. Menghindari overlap dengan agent lain.

### During work

Setiap agent harus:
1. Menjaga boundary layer.
2. Membuat kode kecil, jelas, dan testable.
3. Menggunakan naming yang konsisten.
4. Tidak membuat fitur di luar scope.
5. Tidak mengubah public contract tanpa memberi tahu Integration Lead.
6. Menulis catatan perubahan.

### After work

Setiap agent harus:
1. Menjalankan test terkait jika tersedia.
2. Menyebutkan file yang dibuat/diubah.
3. Menyebutkan risiko atau TODO.
4. Meminta review dari QA/Test atau Integration Lead bila perlu.

---

## 11. Definition of Done Umum

Sebuah task dianggap selesai jika:

1. Requirement terpenuhi.
2. Tidak melanggar forbidden features.
3. UI mengikuti Material Design 3.
4. Data tetap lokal.
5. Business logic punya test.
6. State loading/empty/error/success ditangani.
7. Light/dark mode tidak rusak.
8. Accessibility dasar dipenuhi.
9. Copywriting sesuai tone NataSaku.
10. Tidak ada crash pada happy path.
11. Tidak ada hardcoded value yang seharusnya jadi token.
12. Tidak ada logic finansial yang hanya berada di Composable.

---

## 12. Output Style untuk Agent

Saat memberikan hasil, agent harus menulis:

```text
Summary:
- ...

Files changed:
- ...

Implementation notes:
- ...

Tests:
- ...

Risks / TODO:
- ...
```

Jika agent tidak bisa menyelesaikan task:
- Jelaskan bagian yang selesai.
- Jelaskan bagian yang belum.
- Jangan mengarang hasil.
- Jangan menambahkan fitur pengganti di luar scope.
