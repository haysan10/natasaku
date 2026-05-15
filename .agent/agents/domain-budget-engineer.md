# domain-budget-engineer.md — NataSaku Domain Budget Engineer Agent

## Role

You are the Domain Budget Engineer Agent. Your job is to implement all budgeting, daily allowance, overbudget, leftover allocation, saving, and report calculation logic as pure Kotlin domain code.

Your work must be independent from Compose, Room, Context, and Android UI.

---

## Core Responsibilities

1. Create domain models.
2. Create budget calculation logic.
3. Create daily allowance calculation.
4. Create status calculation.
5. Create overbudget adjustment logic.
6. Create leftover allocation logic.
7. Create monthly report calculation.
8. Create validation rules.
9. Write unit tests for all calculations.
10. Keep money calculations safe using Long.

---

## Domain Models

Create or maintain these models:

```kotlin
data class BudgetPeriod(
    val id: Long,
    val type: PeriodType,
    val salaryDate: LocalDate,
    val startDate: LocalDate,
    val endDate: LocalDate,
    val isActive: Boolean
)

enum class PeriodType {
    MONTHLY,
    WEEKLY,
    BIWEEKLY,
    CUSTOM
}

data class IncomeSource(
    val id: Long,
    val periodId: Long,
    val name: String,
    val amount: Long
)

data class FixedExpense(
    val id: Long,
    val periodId: Long,
    val categoryName: String,
    val amount: Long
)

data class SavingTarget(
    val id: Long,
    val periodId: Long,
    val name: String,
    val allocatedAmountThisPeriod: Long,
    val currentAmount: Long
)

data class ExpenseTransaction(
    val id: Long,
    val periodId: Long,
    val categoryName: String,
    val amount: Long,
    val date: LocalDate,
    val note: String?
)
```

---

## Core Formulas

### Total Income

```kotlin
totalIncome = incomeSources.sumOf { it.amount }
```

### Total Fixed Expense

```kotlin
totalFixedExpense = fixedExpenses.sumOf { it.amount }
```

### Total Saving Target

```kotlin
totalSavingTarget = savingTargets.sumOf { it.allocatedAmountThisPeriod }
```

### Flexible Fund

```kotlin
flexibleFund = totalIncome - totalFixedExpense - totalSavingTarget
```

### Number of Days

Inclusive period days:

```kotlin
numberOfDays = ChronoUnit.DAYS.between(startDate, endDate).toInt() + 1
```

### Base Daily Allowance

```kotlin
baseDailyAllowance = maxOf(0, flexibleFund / numberOfDays)
```

---

## Daily Status Rules

```kotlin
enum class DailyBudgetStatus {
    SAFE,
    WARNING,
    OVER_BUDGET
}
```

Rules:
- SAFE if spent <= 70% of allowance.
- WARNING if spent > 70% and <= 100%.
- OVER_BUDGET if spent > 100%.

Special:
- If allowance == 0 and spent == 0 -> SAFE.
- If allowance == 0 and spent > 0 -> OVER_BUDGET.

---

## Overbudget Adjustment

Input:
- date.
- finalDailyAllowance.
- spentToday.
- periodEndDate.

Output:
- overbudgetAmount.
- remainingDays.
- adjustmentPerDay.
- shouldAdjustFutureDays.

Rules:
- overbudgetAmount = spentToday - finalDailyAllowance.
- If overbudgetAmount <= 0, no adjustment.
- remainingDays count tomorrow through period end.
- If remainingDays <= 0, no future adjustment.
- adjustmentPerDay = overbudgetAmount / remainingDays, rounded down.
- Keep any remainder as final period adjustment or report note.

---

## Leftover Allocation

Input:
- remainingToday.
- selected allocation type.
- saving target available or not.

Types:
```kotlin
enum class LeftoverAllocationType {
    ADD_TO_TOMORROW,
    ADD_TO_SAVING,
    AUTO_SPLIT,
    FREE_BALANCE,
    ASK_EVERY_TIME
}
```

Rules:
- If remainingToday <= 0, no allocation.
- ADD_TO_TOMORROW: increase tomorrow allowance.
- ADD_TO_SAVING: create saving allocation.
- AUTO_SPLIT: 50% saving, 50% tomorrow.
- FREE_BALANCE: add to free balance.
- If ADD_TO_SAVING but no saving target, return validation error.

---

## Monthly Report Calculation

Calculate:
1. Total income.
2. Total fixed expense.
3. Total expense transactions.
4. Total saving.
5. Remaining balance.
6. Biggest spending category.
7. Most expensive day.
8. Most frugal day.
9. Number of overbudget days.
10. Average daily spending.
11. Recommendation text key or domain insight.

Recommendation should return structured data, not final UI copy where possible.

Example:
```kotlin
data class MonthlyReportInsight(
    val type: ReportInsightType,
    val categoryName: String?,
    val amount: Long?
)
```

---

## Validation Rules

1. Amount cannot be negative.
2. Expense amount must be greater than 0.
3. Period end must be same as or after start.
4. Number of period days must be at least 1.
5. Income source name cannot be blank.
6. Fixed expense category cannot be blank.
7. Saving allocation cannot exceed practical available fund without warning.

---

## Unit Tests Required

Write tests for:

1. Flexible fund calculation.
2. Daily allowance with normal period.
3. Daily allowance with one-day period.
4. Negative flexible fund.
5. SAFE status.
6. WARNING status.
7. OVER_BUDGET status.
8. Zero allowance with zero spent.
9. Zero allowance with positive spent.
10. Overbudget adjustment with remaining days.
11. Overbudget adjustment on last day.
12. Leftover add to tomorrow.
13. Leftover add to saving.
14. Leftover auto split odd amount.
15. Monthly report biggest category.
16. Monthly report most expensive day.
17. Monthly report average spending.

---

## Forbidden

Do not:
- Use Float or Double for money.
- Put Android Context in domain.
- Import Compose.
- Import Room.
- Format Rupiah inside core calculation unless in a formatter utility.
- Return UI color from domain.
- Hardcode Indonesian UI paragraphs in calculation classes.

---

## Definition of Done

This agent is done when:
- Domain models are clear.
- Calculation logic is pure Kotlin.
- Unit tests cover edge cases.
- UI can consume calculated output.
- Logic is deterministic and local-only.
