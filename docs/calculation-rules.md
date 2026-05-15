# docs/calculation-rules.md - NataSaku Calculation Rules

## Purpose

This document defines the financial calculation rules for NataSaku.

All calculation logic must live in the domain layer and must be covered by unit tests.

Money must use `Long`.

## Core Formula

```text
Dana Fleksibel = Total Penghasilan - Total Pengeluaran Tetap - Target Tabungan
Jatah Harian Dasar = Dana Fleksibel / Jumlah Hari Periode
```

## Total Income

```kotlin
totalIncome = incomeSources.sumOf { it.amount }
```

Rules:

- Include all income sources for active period.
- Amount must be `Long`.

## Total Fixed Expense

```kotlin
totalFixedExpense = fixedExpenses.sumOf { it.amount }
```

Rules:

- Empty category input counts as Rp0.
- Fixed expenses belong to one period.
- Custom categories are included.

## Total Saving Target

```kotlin
totalSavingTarget = savingTargets.sumOf { it.allocatedAmountThisPeriod }
```

Rules:

- If user skips saving target, this is 0.
- MVP may use one target.

## Flexible Fund

```kotlin
flexibleFund = totalIncome - totalFixedExpense - totalSavingTarget
```

Rules:

- If flexibleFund < 0, show warning.
- Daily allowance should not become negative in UI.
- Use `maxOf(0, flexibleFund)` for allowance base if needed.

Recommended copy:

> Pengeluaran tetap dan tabungan lebih besar dari penghasilan. Kamu bisa menyesuaikan nominal agar jatah harian tersedia.

## Period Day Count

Inclusive day count:

```kotlin
numberOfDays = ChronoUnit.DAYS.between(startDate, endDate).toInt() + 1
```

Examples:

- 1 May to 1 May = 1 day.
- 1 May to 31 May = 31 days.

## Base Daily Allowance

```kotlin
baseDailyAllowance = maxOf(0, flexibleFund) / numberOfDays
```

Rules:

- Round down.
- Remainder can stay as free balance or final month remainder.
- Never display negative daily allowance.

## Final Daily Allowance

```kotlin
finalDailyAllowance = baseDailyAllowance + adjustmentAmount
```

Rules:

- adjustmentAmount can be positive or negative.
- If finalDailyAllowance < 0, display Rp0 and explain in Budget screen.

## Spent Today

```kotlin
spentToday = transactions
    .filter { it.date == today && it.deletedAt == null }
    .sumOf { it.amount }
```

Rules:

- Include only active transactions.
- Include only active period transactions.
- If transaction is edited/deleted, recalculate.

## Remaining Today

```kotlin
remainingToday = finalDailyAllowance - spentToday
```

Rules:

- Positive = user still has daily balance.
- Zero = exactly used daily allowance.
- Negative = exceeded daily allowance.

## Daily Status

Avoid integer truncation by comparing multiplication:

```kotlin
spentToday * 100 <= finalDailyAllowance * 70
```

Rules:

- SAFE: spentToday <= 70% of finalDailyAllowance.
- WARNING: spentToday > 70% and <= 100%.
- OVER_BUDGET: spentToday > 100%.

Special cases:

- finalDailyAllowance == 0 and spentToday == 0 -> SAFE.
- finalDailyAllowance == 0 and spentToday > 0 -> OVER_BUDGET.

## Overbudget Amount

```kotlin
overbudgetAmount = spentToday - finalDailyAllowance
```

Rules:

- If overbudgetAmount <= 0, no overbudget.
- If overbudgetAmount > 0, show Warning Overbudget Dialog.

## Remaining Days for Adjustment

```kotlin
remainingDays = daysBetween(today.plusDays(1), periodEndDate) + 1
```

Rules:

- If today is period end date, remainingDays = 0.
- If remainingDays <= 0, no future adjustment.
- If remainingDays > 0, spread overbudget across remaining days.

## Adjustment Per Day

```kotlin
adjustmentPerDay = overbudgetAmount / remainingDays
```

Rules:

- Round down.
- Remainder must not disappear.
- Adjustment reduces future daily allowance.

## Leftover Amount

```kotlin
leftoverAmount = finalDailyAllowance - spentToday
```

Rules:

- If leftoverAmount <= 0, no leftover allocation.
- If leftoverAmount > 0 and not yet allocated, show leftover flow or apply default preference.

## Leftover Allocation Types

### ADD_TO_TOMORROW

```text
tomorrowAdjustment += leftoverAmount
```

### ADD_TO_SAVING

```text
savingTarget.currentAmount += leftoverAmount
create SavingAllocation(source = DAILY_LEFTOVER)
```

If no saving target:

- Show message or route user to create target.
- Do not crash.

### AUTO_SPLIT

```kotlin
toSaving = leftoverAmount / 2
toTomorrow = leftoverAmount - toSaving
```

Rules:

- If odd amount, give remainder to tomorrow.
- If no saving target, put saving portion into free balance or ask user.

### FREE_BALANCE

```text
freeBalance += leftoverAmount
```

## Monthly Report Metrics

### Total Expense

```kotlin
totalExpense = transactionsInPeriod.sumOf { it.amount }
```

### Remaining End of Month

```kotlin
remainingEndOfMonth = totalIncome - totalFixedExpense - totalSaving - totalExpense
```

### Biggest Category

Group transactions by category and pick highest total.

### Most Expensive Day

Group transactions by date and pick highest daily total.

### Most Frugal Day

Recommended:

- Include all days in the selected period.
- Days with no transaction count as Rp0.
- Pick earliest date if tie.

### Overbudget Days

Count daily snapshots with status `OVER_BUDGET`.

### Average Daily Spending

```kotlin
averageDailySpending = totalExpense / numberOfDays
```

## Unit Test Requirements

- flexible fund normal.
- flexible fund negative.
- period one day.
- daily allowance rounding.
- zero allowance and zero spent.
- zero allowance and positive spent.
- safe boundary at 70%.
- warning boundary above 70%.
- overbudget above 100%.
- overbudget adjustment with remaining days.
- overbudget adjustment last day.
- leftover add to tomorrow.
- leftover add to saving.
- leftover auto split odd amount.
- monthly report biggest category.
- monthly report average spending.
