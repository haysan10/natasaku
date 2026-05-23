# MVP_CHECKLIST.md - NataSaku MVP Checklist

## Purpose

Checklist ringkas untuk memastikan MVP NataSaku sudah lengkap.

Untuk checklist detail, lihat:

- `docs/testing-checklist.md`
- `docs/release-checklist.md`

---

## 1. Product Guardrails

- [ ] Android native.
- [ ] Kotlin.
- [ ] Jetpack Compose.
- [ ] Material Design 3.
- [ ] Offline-first.
- [ ] Local data only.
- [ ] No login.
- [ ] No backend.
- [ ] No cloud sync.
- [ ] No bank integration.
- [ ] No ads.
- [ ] No analytics SDK.
- [ ] No payment gateway.

---

## 2. Setup Flow MVP

- [ ] Splash Screen.
- [ ] Welcome Screen.
- [ ] Onboarding Benefit Screens.
- [ ] Setup Periode Gajian.
- [ ] Setup Penghasilan.
- [ ] Setup Pengeluaran Tetap.
- [ ] Setup Target Tabungan.
- [ ] Review Budget.
- [ ] Setup saves active budget locally.
- [ ] Setup completion opens Home Dashboard.

---

## 3. Budget Calculation MVP

- [ ] Total penghasilan calculated.
- [ ] Total pengeluaran tetap calculated.
- [ ] Target tabungan calculated.
- [ ] Dana fleksibel calculated.
- [ ] Jumlah hari periode calculated inclusively.
- [ ] Jatah harian calculated.
- [ ] Daily status calculated:
  - Aman.
  - Waspada.
  - Melewati Batas.
- [ ] Overbudget amount calculated.
- [ ] Future adjustment calculated.
- [ ] Leftover amount calculated.
- [ ] Money uses `Long`.
- [ ] Unit tests exist.

---

## 4. Home Dashboard MVP

- [ ] Greeting shown.
- [ ] Active period shown.
- [ ] Jatah hari ini shown prominently.
- [ ] Sudah terpakai shown.
- [ ] Sisa hari ini shown.
- [ ] Status shown with text and color.
- [ ] Monthly progress shown.
- [ ] Category summary shown.
- [ ] Insight shown.
- [ ] FAB opens Add Expense.

---

## 5. Add Expense MVP

- [ ] Bottom sheet opens.
- [ ] Nominal input autofocus.
- [ ] Numeric keyboard.
- [ ] Category selection.
- [ ] Date defaults to today.
- [ ] Note optional.
- [ ] Save button.
- [ ] Validation for invalid amount.
- [ ] Expense saved locally.
- [ ] Dashboard updates after save.
- [ ] Overbudget dialog appears when needed.

---

## 6. Transaction History MVP

- [ ] List transactions.
- [ ] Group by date.
- [ ] Search.
- [ ] Category filter.
- [ ] Total filtered spending.
- [ ] Edit transaction.
- [ ] Delete transaction.
- [ ] Empty state.
- [ ] Recalculation after edit/delete.

---

## 7. Budget Screen MVP

- [ ] Shows active period.
- [ ] Shows income.
- [ ] Shows fixed expenses.
- [ ] Shows saving target.
- [ ] Shows base daily allowance.
- [ ] Shows adjustment.
- [ ] Edit budget entry point.

---

## 8. Saving MVP

- [ ] Saving target shown.
- [ ] Progress bar.
- [ ] Total collected.
- [ ] Allocation history.
- [ ] Empty state if no target.
- [ ] Leftover allocation can add to saving.

---

## 9. Monthly Report MVP

- [ ] Total penghasilan.
- [ ] Total pengeluaran.
- [ ] Total tabungan.
- [ ] Sisa akhir bulan.
- [ ] Kategori terbesar.
- [ ] Hari paling boros.
- [ ] Hari paling hemat.
- [ ] Jumlah hari overbudget.
- [ ] Rata-rata pengeluaran harian.
- [ ] Rekomendasi bulan depan.
- [ ] Empty state.

---

## 10. Export MVP

- [ ] Export CSV.
- [ ] Download PDF.
- [ ] Export Success Screen.
- [ ] File name shown.
- [ ] Share file.
- [ ] Open file.
- [ ] Export error handled.
- [ ] Export runs off main thread.

---

## 11. Settings MVP

- [ ] Currency setting.
- [ ] Theme setting.
- [ ] Default leftover allocation.
- [ ] Daily reminder setting if implemented.
- [ ] Backup data.
- [ ] Restore data.
- [ ] About app.

---

## 12. Backup Restore MVP

- [ ] Backup JSON generated.
- [ ] Backup includes schemaVersion.
- [ ] Backup includes app = NataSaku.
- [ ] Restore validates JSON.
- [ ] Restore validates schema version.
- [ ] Restore confirmation shown.
- [ ] Restore replaces local data safely.
- [ ] Invalid file shows friendly error.
- [ ] No cloud backup.

---

## 13. UI/UX MVP

- [ ] Material Design 3.
- [ ] Card-based layout.
- [ ] Teal/mint primary color.
- [ ] Off-white light background.
- [ ] Dark mode support.
- [ ] Rounded corners.
- [ ] Clear typography.
- [ ] Dashboard not crowded.
- [ ] Add expense fast.
- [ ] Copywriting friendly.
- [ ] No shame-based language.

---

## 14. Accessibility MVP

- [ ] Touch targets at least 48dp.
- [ ] Icon buttons have contentDescription.
- [ ] Inputs have labels.
- [ ] Status has text label.
- [ ] Progress has text summary.
- [ ] Error messages visible.
- [ ] Text scaling acceptable.
- [ ] Dark mode contrast acceptable.

---

## 15. MVP Ready Criteria

MVP is ready when:

- [ ] All P0 flows work.
- [ ] App works offline.
- [ ] No forbidden feature exists.
- [ ] Core calculation tests pass.
- [ ] Add expense is fast.
- [ ] Reports export.
- [ ] Backup and restore work.
- [ ] No critical accessibility issue.
- [ ] No judgmental copy.
- [ ] No known data loss bug.
