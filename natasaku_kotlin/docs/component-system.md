# docs/component-system.md - NataSaku Component System

## Purpose

This document defines reusable UI components for NataSaku. Components should be implemented in Jetpack Compose using Material Design 3.

## Component Principles

1. Reusable.
2. Theme-based.
3. Accessible.
4. Previewable.
5. Stateless where possible.
6. Works in light and dark mode.
7. Uses Indonesian labels.
8. Avoids business logic.

## NataPrimaryButton

Purpose:
- Main action button.

Use for:
- Mulai Atur Budget.
- Lanjut.
- Simpan.
- Download PDF.
- Export CSV.

Props:

```kotlin
@Composable
fun NataPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false
)
```

Style:
- Height: 52dp.
- Radius: 16dp.
- Background: primary.
- Text: onPrimary, Label Large.
- Full width on setup screens.

## NataSecondaryButton

Purpose:
- Secondary action.

Use for:
- Lewati Dulu.
- Lihat Detail.
- Buka File.
- Bagikan File.

## MoneyText

Purpose:
- Consistent money display.

Props:

```kotlin
@Composable
fun MoneyText(
    amount: Long,
    modifier: Modifier = Modifier,
    style: MoneyTextStyle = MoneyTextStyle.Large,
    color: Color = MaterialTheme.colorScheme.onSurface
)
```

Rules:
- Format as Rupiah.
- No decimal.
- Negative values should be handled intentionally.

## FinanceSummaryCard

Purpose:
- Show financial summary.

Use for:
- Daily allowance.
- Total income.
- Fixed expenses.
- Saving target.
- Monthly report metrics.

Props:

```kotlin
@Composable
fun FinanceSummaryCard(
    title: String,
    amount: Long,
    subtitle: String? = null,
    status: DailyBudgetStatus? = null,
    progress: Float? = null,
    onClick: (() -> Unit)? = null
)
```

## DailyAllowanceHeroCard

Purpose:
- Main card on Home Dashboard.

Content:
- Label: “Jatah kamu hari ini”.
- Amount.
- Status chip.
- Spent today.
- Remaining today.
- Insight.

Requirements:
- Most prominent dashboard component.
- Must be readable within 3 seconds.
- Use calm visual status.

## StatusChip

Purpose:
- Show budget status.

Labels:
- SAFE -> Aman.
- WARNING -> Waspada.
- OVER_BUDGET -> Melewati Batas.

Accessibility:
- Must include text label.
- Do not rely on color only.

## CategoryChip

Purpose:
- Select/filter categories.

Use:
- Add Expense category picker.
- Transaction History filter.

Rules:
- Minimum touch target 48dp.
- Selected state visually clear.
- Text must remain readable.

## CategoryInputCard

Purpose:
- Setup fixed expense input.

Content:
- Icon.
- Category name.
- Money input.
- Optional remove button for custom category.

## TransactionRow

Purpose:
- Show transaction in history.

Content:
- Category icon.
- Category name.
- Note or fallback text.
- Date/time if needed.
- Amount.
- Edit/delete affordance.

Accessibility:
- Row should announce category, amount, date, note.
- Edit/delete icon buttons need contentDescription.

## EmptyState

Purpose:
- Show friendly empty state.

Props:

```kotlin
@Composable
fun EmptyState(
    title: String,
    description: String,
    modifier: Modifier = Modifier,
    actionText: String? = null,
    onAction: (() -> Unit)? = null
)
```

## AddExpenseBottomSheet

Purpose:
- Fast transaction input.

Required fields:
- Nominal.
- Kategori.
- Tanggal.
- Catatan.
- Simpan button.

Rules:
- Nominal autofocus.
- Numeric keyboard.
- Date defaults to today.
- Note optional.
- Save button visible.
- Can be completed in about 10 seconds.

## WarningOverbudgetDialog

Purpose:
- Friendly warning.

Content:
- Title.
- Overbudget amount.
- Explanation.
- CTA.
- Secondary action.

## LeftoverAllocationDialog

Purpose:
- Choose leftover allocation.

Options:
- Tambah ke jatah besok.
- Masukkan ke tabungan.
- Bagi otomatis.
- Simpan sebagai saldo bebas.

## ReportMetricCard

Purpose:
- Show a single report metric.

Examples:
- Total penghasilan.
- Total pengeluaran.
- Total tabungan.
- Sisa akhir bulan.
- Rata-rata harian.

## SettingsRow

Purpose:
- Settings list item.

Content:
- Icon.
- Title.
- Subtitle/current value.
- Trailing chevron/switch.

## Component Preview Requirement

Create previews for:
- Buttons.
- MoneyText.
- FinanceSummaryCard.
- StatusChip states.
- DailyAllowanceHeroCard.
- TransactionRow.
- EmptyState.
- AddExpenseBottomSheet.
- WarningOverbudgetDialog.
- LeftoverAllocationDialog.
- ReportMetricCard.
- SettingsRow.
