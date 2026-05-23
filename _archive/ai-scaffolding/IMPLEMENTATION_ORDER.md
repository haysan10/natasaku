# IMPLEMENTATION_ORDER.md - NataSaku Build Order

## Purpose

Dokumen ini menentukan urutan implementasi terbaik untuk membangun NataSaku secara bertahap, minim konflik, dan mudah diuji.

Ikuti urutan ini kecuali ada alasan teknis yang kuat.

---

## Overview

Recommended order:

1. Project Foundation.
2. Design System.
3. Budget Calculation.
4. Local Database.
5. Setup Flow.
6. Home Dashboard.
7. Transaction History.
8. Saving and Leftover.
9. Monthly Report Export.
10. Settings Backup Restore.
11. QA Accessibility Polish.

---

## Phase 1 - Project Foundation

Track:
- `conductor/tracks/001-project-foundation/`

Goal:
- Membuat dasar project Android.

Deliverables:
- Kotlin Android project.
- Jetpack Compose enabled.
- Material 3 dependency.
- Navigation shell.
- Package structure.
- Placeholder screens.
- Basic test setup.

Definition of Done:
- Project builds.
- MainActivity launches Compose.
- NavHost exists.
- No forbidden dependencies.

---

## Phase 2 - Design System

Track:
- `conductor/tracks/002-design-system/`

Goal:
- Membuat fondasi visual NataSaku.

Deliverables:
- Light theme.
- Dark theme.
- Color tokens.
- Typography.
- Shapes.
- Dimensions.
- Shared components:
  - NataPrimaryButton.
  - NataSecondaryButton.
  - MoneyText.
  - FinanceSummaryCard.
  - StatusChip.
  - EmptyState.

Definition of Done:
- Theme works.
- Previews available.
- Light/dark mode supported.
- UI components do not hardcode random colors.

---

## Phase 3 - Budget Calculation

Track:
- `conductor/tracks/004-budget-calculation/`

Goal:
- Membuat semua business logic finansial di domain layer.

Deliverables:
- Domain models.
- BudgetCalculator.
- DailyBudgetCalculator.
- OverbudgetCalculator.
- LeftoverAllocationCalculator.
- MonthlyReportCalculator.
- Unit tests.

Definition of Done:
- Money uses `Long`.
- No Android dependency in domain.
- Unit tests cover edge cases.
- Daily allowance and status calculations are deterministic.

Why before database:
- Calculation rules should be clear before persistence and UI consume them.

---

## Phase 4 - Local Database

Track:
- `conductor/tracks/003-local-database/`

Goal:
- Membuat penyimpanan lokal.

Deliverables:
- Room entities.
- DAO.
- Database.
- Type converters.
- Repository implementations.
- DataStore preferences.
- DAO tests.

Definition of Done:
- Active period can be stored.
- Transactions can be inserted/read/updated/deleted.
- Preferences persist.
- Entities are mapped to domain models.

---

## Phase 5 - Setup Flow

Track:
- `conductor/tracks/005-setup-flow/`

Goal:
- User bisa membuat budget pertama.

Screens:
1. Welcome.
2. Onboarding.
3. Setup Period.
4. Setup Income.
5. Setup Fixed Expense.
6. Setup Saving Target.
7. Review Budget.

Deliverables:
- Setup ViewModel.
- Form validation.
- Persist active budget.
- Review calculation integration.
- Navigation from setup to Home.

Definition of Done:
- New user can complete setup.
- Budget saved locally.
- Home opens after setup.
- No login/account flow.

---

## Phase 6 - Home Dashboard

Track:
- `conductor/tracks/006-home-dashboard/`

Goal:
- User bisa melihat jatah hari ini dan mencatat pengeluaran.

Deliverables:
- HomeDashboardScreen.
- HomeViewModel.
- DailyAllowanceHeroCard.
- AddExpenseBottomSheet.
- WarningOverbudgetDialog.
- Dashboard local data integration.

Definition of Done:
- Daily allowance shown.
- Add expense saves.
- Dashboard updates.
- Overbudget warning appears.
- Add expense can be completed quickly.

---

## Phase 7 - Transaction History

Track:
- `conductor/tracks/007-transaction-history/`

Goal:
- User bisa melihat dan mengelola transaksi.

Deliverables:
- TransactionHistoryScreen.
- Search.
- Category filter.
- Group by date.
- Edit transaction.
- Delete transaction.
- Recalculation after changes.

Definition of Done:
- History accurate.
- Filter total accurate.
- Edit/delete updates dashboard/report.
- Empty state works.

---

## Phase 8 - Saving and Leftover

Track:
- `conductor/tracks/008-saving-and-leftover/`

Goal:
- User bisa melihat tabungan dan mengalokasikan sisa jatah.

Deliverables:
- SavingScreen.
- Saving progress.
- Allocation history.
- LeftoverAllocationDialog.
- Allocation persistence.

Definition of Done:
- Saving progress correct.
- Leftover allocation works.
- No duplicate allocation for same date.
- No crash if no saving target.

---

## Phase 9 - Monthly Report Export

Track:
- `conductor/tracks/009-monthly-report-export/`

Goal:
- User bisa melihat laporan bulanan dan export file.

Deliverables:
- MonthlyReportScreen.
- Monthly report metrics.
- Recommendation.
- CSV exporter.
- PDF exporter.
- ExportSuccessScreen.
- Share/open file.

Definition of Done:
- Metrics correct.
- CSV valid.
- PDF created.
- Export success works.
- No cloud upload.

---

## Phase 10 - Settings Backup Restore

Track:
- `conductor/tracks/010-settings-backup-restore/`

Goal:
- User bisa mengatur preferensi dan menjaga data lokal.

Deliverables:
- SettingsScreen.
- Theme setting.
- Currency setting.
- Default leftover setting.
- Daily reminder setting.
- Backup JSON.
- Restore JSON validation.

Definition of Done:
- Settings persist.
- Backup file generated.
- Restore valid file works.
- Invalid restore handled.
- No cloud backup.

---

## Phase 11 - QA Accessibility Polish

Track:
- `conductor/tracks/011-qa-accessibility-polish/`

Goal:
- Menyiapkan MVP untuk rilis.

Deliverables:
- Unit test pass.
- DAO test pass.
- UI test for critical flows.
- Manual QA.
- Accessibility review.
- Copywriting review.
- Dark mode review.
- Release checklist.

Definition of Done:
- No P0/P1 blocker.
- No wrong money calculation.
- Offline flow works.
- App ready for MVP.

---

## Rules for Moving to Next Phase

Do not move to next phase if:

1. Current phase does not build.
2. P0 bug remains.
3. Forbidden feature was introduced.
4. Calculation logic has no tests.
5. Data layer exposes entity to UI.
6. UI depends directly on Room DAO.
7. App requires internet.

---

## Recommended First Antigravity Command

```text
Start with Phase 1 Project Foundation. Read IMPLEMENTATION_ORDER.md and conductor/tracks/001-project-foundation/spec.md and plan.md. Implement only Track 001. Do not start other tracks yet.
```
