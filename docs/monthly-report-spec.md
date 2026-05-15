# docs/monthly-report-spec.md - NataSaku Monthly Report Specification

## Purpose

Monthly Report helps users understand their financial behavior for the period in a calm, professional, and useful way.

The report should feel like a friendly personal finance manager summary.

## Required Metrics

1. Total penghasilan.
2. Total pengeluaran.
3. Total tabungan.
4. Sisa akhir bulan.
5. Kategori terbesar.
6. Hari paling boros.
7. Hari paling hemat.
8. Jumlah hari overbudget.
9. Rata-rata pengeluaran harian.
10. Rekomendasi bulan depan.

## Input Data

Use local data only:

- BudgetPeriod.
- IncomeSource.
- FixedExpense.
- SavingTarget.
- SavingAllocation.
- ExpenseTransaction.
- DailyBudgetSnapshot.

Exclude:

- Soft deleted transactions.
- Transactions outside selected period.

## Metric Definitions

### Total Penghasilan

```text
sum(incomeSources.amount)
```

### Total Pengeluaran

```text
sum(activeTransactions.amount)
```

### Total Tabungan

Recommended MVP:
- Show planned saving target.
- Show actual saving collected if available.

### Sisa Akhir Bulan

```text
totalIncome - totalFixedExpense - totalSaving - totalExpense
```

### Kategori Terbesar

Group active transactions by category and pick highest total.

### Hari Paling Boros

Group active transactions by date and pick highest daily total.

### Hari Paling Hemat

Recommended:
- Include all days in the selected period.
- Days with no transaction count as Rp0.
- Pick lowest total.
- If tied, pick earliest date.

### Jumlah Hari Overbudget

Use DailyBudgetSnapshot where status is `OVER_BUDGET`.

### Rata-Rata Pengeluaran Harian

```text
totalExpense / numberOfDays
```

Round down.

## Recommendation Rules

Recommendations must be:
- Helpful.
- Specific.
- Non-judgmental.
- Short.
- Based on report data.

### Biggest Category

> Bulan ini, pengeluaran terbesar ada di kategori {category}. Untuk bulan depan, kamu bisa memberi batas khusus agar jatah harian lebih stabil.

### Many Overbudget Days

> Ada beberapa hari saat jatah harian terlewati. Kamu bisa mencoba menambah buffer kecil untuk pengeluaran harian bulan depan.

### Good Saving Progress

> Tabungan bulan ini sudah berjalan. Pertahankan alokasi kecil yang konsisten agar target lebih mudah tercapai.

### No Transactions

> Laporan akan lebih lengkap setelah kamu mulai mencatat pengeluaran harian.

### Remaining Positive

> Masih ada sisa dana di akhir periode. Kamu bisa menyimpannya sebagai saldo bebas atau menambahkannya ke tabungan.

### Remaining Negative

> Pengeluaran periode ini lebih tinggi dari rencana. Kamu bisa menyesuaikan jatah harian atau mengecek kategori terbesar untuk bulan depan.

Avoid:
- Kamu boros.
- Kamu gagal.
- Pengeluaranmu buruk.

## Report Layout

Recommended sections:

1. Header.
2. Summary.
3. Spending Insights.
4. Budget Health.
5. Recommendation.
6. Export Actions.

## Empty State

Title:
> Laporan belum tersedia

Description:
> Laporan akan tersedia setelah ada transaksi dalam periode ini.

CTA:
> Catat Pengeluaran
