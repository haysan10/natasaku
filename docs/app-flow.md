# docs/app-flow.md - NataSaku App Flow

## Overview

NataSaku has two main modes:

1. First-time setup mode.
2. Daily usage mode.

The app must work fully offline.

## First-Time User Flow

```text
Splash
-> Welcome
-> Onboarding Benefit 1
-> Onboarding Benefit 2
-> Onboarding Benefit 3
-> Setup Periode Gajian
-> Setup Penghasilan
-> Setup Pengeluaran Tetap
-> Setup Target Tabungan
-> Review Budget
-> Home Dashboard
```

## Flow Rules

1. If `onboardingCompleted == false`, user goes to Welcome.
2. If onboarding is complete but no active period exists, user goes to Setup Periode.
3. If active period exists, user goes to Home Dashboard.
4. After Review Budget is completed, setup back stack should be cleared.
5. User must never be asked to log in.

## Returning User Flow

```text
Splash
-> Local data check
-> Home Dashboard
```

Fallback:

```text
Splash
-> Setup Periode Gajian
```

## Daily Expense Flow

```text
Home Dashboard
-> Tap FAB Tambah Pengeluaran
-> Add Expense Bottom Sheet
-> Isi nominal
-> Pilih kategori
-> Simpan
-> Bottom sheet close
-> Dashboard update
```

If overbudget:

```text
Dashboard update
-> Warning Overbudget Dialog
-> Saya Mengerti / Lihat Detail
```

## Leftover Allocation Flow

Trigger:
- `remainingToday > 0`
- leftover not allocated yet
- default allocation is `ASK_EVERY_TIME`

```text
Home Dashboard
-> Leftover Allocation Dialog
-> Pilih alokasi
-> Simpan alokasi
-> Dashboard/Budget/Saving update
```

Options:
1. Tambah ke jatah besok.
2. Masukkan ke tabungan.
3. Bagi otomatis.
4. Simpan sebagai saldo bebas.

## Transaction History Flow

```text
Bottom Navigation: Transaksi
-> Transaction History
-> Search/filter
-> Tap transaction
-> Edit Transaction
-> Save
-> History update
-> Dashboard/report recalculated
```

Delete flow:

```text
Tap delete
-> Confirmation dialog
-> Confirm
-> Soft delete
-> History update
```

## Budget Detail Flow

```text
Bottom Navigation: Budget
-> Budget Screen
-> See income, fixed expenses, saving, daily allowance, adjustment
-> Edit Budget
```

Rules:
- Editing budget must not silently delete existing transactions.
- Recalculate daily allowance after changes.
- Warn user if changes affect current period.

## Saving Flow

```text
Bottom Navigation: Tabungan
-> Saving Screen
-> View target, progress, collected amount
-> View allocation history
```

If no target:

```text
Saving Screen
-> Empty State
-> Tambah Target
```

## Monthly Report Flow

```text
Bottom Navigation: Laporan
-> Monthly Report Screen
-> View report metrics
-> Download PDF / Export CSV
-> Export Success Screen
-> Share / Open File
```

Rules:
- Report is generated from local database.
- No server call.
- User can export only local files.

## Settings Flow

```text
Top App Bar Settings
-> Settings Screen
-> Change theme / currency / reminder / leftover default
-> Backup / Restore
```

Backup:

```text
Settings
-> Backup Data
-> Generate JSON file
-> Export Success
```

Restore:

```text
Settings
-> Restore Data
-> Pick JSON file
-> Validate
-> Confirmation Dialog
-> Replace local data
-> Recalculate dashboard
```

## Bottom Navigation

Tabs:

1. Beranda.
2. Transaksi.
3. Budget.
4. Tabungan.
5. Laporan.

Settings is not a bottom tab. It is accessed from top app bar or overflow.

## Back Navigation Rules

| Screen | Back Behavior |
|---|---|
| Splash | No back |
| Welcome | Exit app |
| Onboarding | Previous slide or Welcome |
| Setup Period | Previous setup step or onboarding |
| Setup Income | Setup Period |
| Setup Fixed Expense | Setup Income |
| Setup Saving | Setup Fixed Expense |
| Review Budget | Setup Saving |
| Home | Exit app |
| Other bottom tab | Return Home or previous selected tab |
| Bottom Sheet | Dismiss sheet |
| Dialog | Dismiss if safe |
| Settings | Return previous screen |
