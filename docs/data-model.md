# docs/data-model.md - NataSaku Data Model

## Overview

NataSaku stores all data locally.

Primary storage:

- Room for structured data.
- DataStore for preferences.
- Local files for PDF, CSV, and backup JSON.

Money values must use `Long`.

Dates:

- Use `LocalDate` for period dates and transaction dates.
- Use `Instant` for createdAt/updatedAt.

## 1. BudgetPeriod

Represents one budgeting period.

```kotlin
data class BudgetPeriod(
    val id: Long,
    val type: PeriodType,
    val salaryDate: LocalDate,
    val startDate: LocalDate,
    val endDate: LocalDate,
    val createdAt: Instant,
    val updatedAt: Instant,
    val isActive: Boolean
)

enum class PeriodType {
    MONTHLY,
    WEEKLY,
    BIWEEKLY,
    CUSTOM
}
```

Validation:

- `startDate <= endDate`.
- Only one active period at a time.
- Period day count must be at least 1.

## 2. IncomeSource

```kotlin
data class IncomeSource(
    val id: Long,
    val periodId: Long,
    val name: String,
    val amount: Long,
    val createdAt: Instant,
    val updatedAt: Instant
)
```

Validation:

- `name` cannot be blank.
- `amount >= 0`.
- Setup requires at least one income source with amount > 0.

## 3. FixedExpense

```kotlin
data class FixedExpense(
    val id: Long,
    val periodId: Long,
    val categoryName: String,
    val amount: Long,
    val isDefaultCategory: Boolean,
    val createdAt: Instant,
    val updatedAt: Instant
)
```

Default categories:

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

Validation:

- `categoryName` cannot be blank.
- `amount >= 0`.

## 4. SavingTarget

```kotlin
data class SavingTarget(
    val id: Long,
    val periodId: Long,
    val name: String,
    val targetAmount: Long?,
    val allocatedAmountThisPeriod: Long,
    val currentAmount: Long,
    val createdAt: Instant,
    val updatedAt: Instant
)
```

Validation:

- `name` can default to "Tabungan".
- `targetAmount` can be null.
- `allocatedAmountThisPeriod >= 0`.
- `currentAmount >= 0`.

## 5. ExpenseTransaction

```kotlin
data class ExpenseTransaction(
    val id: Long,
    val periodId: Long,
    val categoryName: String,
    val amount: Long,
    val date: LocalDate,
    val note: String?,
    val createdAt: Instant,
    val updatedAt: Instant,
    val deletedAt: Instant?
)
```

Validation:

- `amount > 0`.
- `categoryName` cannot be blank.
- `deletedAt == null` means active transaction.
- Soft delete is recommended.

## 6. SavingAllocation

```kotlin
data class SavingAllocation(
    val id: Long,
    val periodId: Long,
    val savingTargetId: Long?,
    val amount: Long,
    val source: SavingAllocationSource,
    val date: LocalDate,
    val note: String?,
    val createdAt: Instant
)

enum class SavingAllocationSource {
    DAILY_LEFTOVER,
    MANUAL,
    AUTO_SPLIT
}
```

Validation:

- `amount > 0`.
- If source uses saving target, `savingTargetId` should exist.

## 7. DailyBudgetSnapshot

```kotlin
data class DailyBudgetSnapshot(
    val id: Long,
    val periodId: Long,
    val date: LocalDate,
    val baseDailyAllowance: Long,
    val adjustmentAmount: Long,
    val finalDailyAllowance: Long,
    val spentAmount: Long,
    val remainingAmount: Long,
    val status: DailyBudgetStatus,
    val createdAt: Instant,
    val updatedAt: Instant
)

enum class DailyBudgetStatus {
    SAFE,
    WARNING,
    OVER_BUDGET
}
```

Usage:

- Dashboard.
- Monthly report.
- Adjustment explanation.
- Overbudget day count.

## 8. UserPreference

Stored in DataStore.

```kotlin
data class UserPreference(
    val currencyCode: String,
    val themeMode: ThemeMode,
    val defaultLeftoverAllocation: LeftoverAllocationType,
    val dailyReminderEnabled: Boolean,
    val dailyReminderTime: LocalTime?,
    val onboardingCompleted: Boolean,
    val activePeriodId: Long?
)

enum class ThemeMode {
    SYSTEM,
    LIGHT,
    DARK
}

enum class LeftoverAllocationType {
    ADD_TO_TOMORROW,
    ADD_TO_SAVING,
    AUTO_SPLIT,
    FREE_BALANCE,
    ASK_EVERY_TIME
}
```

Defaults:

- currencyCode = `IDR`
- themeMode = `SYSTEM`
- defaultLeftoverAllocation = `ASK_EVERY_TIME`
- dailyReminderEnabled = false
- dailyReminderTime = null
- onboardingCompleted = false
- activePeriodId = null

## Recommended Indexes

- `BudgetPeriodEntity(isActive)`
- `BudgetPeriodEntity(startDate, endDate)`
- `IncomeSourceEntity(periodId)`
- `FixedExpenseEntity(periodId)`
- `ExpenseTransactionEntity(periodId, date)`
- `ExpenseTransactionEntity(categoryName)`
- `ExpenseTransactionEntity(deletedAt)`
- `SavingTargetEntity(periodId)`
- `SavingAllocationEntity(periodId, date)`
- `DailyBudgetSnapshotEntity(periodId, date)`

## Relationship Summary

```text
BudgetPeriod 1 -> * IncomeSource
BudgetPeriod 1 -> * FixedExpense
BudgetPeriod 1 -> * ExpenseTransaction
BudgetPeriod 1 -> * SavingTarget
BudgetPeriod 1 -> * SavingAllocation
BudgetPeriod 1 -> * DailyBudgetSnapshot

SavingTarget 1 -> * SavingAllocation
```

## Mapping Rule

Data layer entities must be mapped to domain models.

Good:

```kotlin
ExpenseTransactionEntity.toDomain()
ExpenseTransaction.toEntity()
```

Bad:

- Passing `ExpenseTransactionEntity` directly into Compose UI.
