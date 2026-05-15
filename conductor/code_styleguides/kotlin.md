# conductor/code_styleguides/kotlin.md — Kotlin Style Guide for NataSaku

## General Principles

1. Prefer clarity over cleverness.
2. Keep business logic pure and testable.
3. Use immutable data where possible.
4. Use `Long` for money.
5. Avoid `Double` and `Float` for currency.
6. Use sealed interfaces/classes for state and events.
7. Keep functions small.
8. Use explicit names.
9. Avoid nullable types unless needed.
10. Avoid hidden side effects.

---

## Naming

Classes:
```kotlin
BudgetCalculator
GetHomeDashboardUseCase
ExpenseTransactionRepository
```

Functions:
```kotlin
calculateDailyAllowance()
getActivePeriod()
addExpenseTransaction()
```

Variables:
```kotlin
totalIncome
fixedExpenseAmount
remainingToday
```

Constants:
```kotlin
const val DEFAULT_CURRENCY_CODE = "IDR"
```

---

## Money

Use:
```kotlin
val amount: Long
```

Do not use:
```kotlin
val amount: Double
val amount: Float
```

Formatting should be done separately:
```kotlin
interface MoneyFormatter {
    fun format(amount: Long): String
}
```

---

## Result Handling

Prefer typed result for operations that can fail:

```kotlin
sealed interface AppResult<out T> {
    data class Success<T>(val data: T) : AppResult<T>
    data class Error(
        val message: String,
        val cause: Throwable? = null
    ) : AppResult<Nothing>
}
```

Domain validation can use:

```kotlin
sealed interface ValidationResult {
    data object Valid : ValidationResult
    data class Invalid(val reason: ValidationError) : ValidationResult
}
```

---

## Coroutines

Rules:
1. Suspend functions for one-shot operations.
2. Flow for observable data.
3. Do not block main thread.
4. Use Dispatchers.IO for database and file operations.
5. ViewModel should use `viewModelScope`.

---

## Domain Layer

Domain must not import:
- android.*
- androidx.compose.*
- androidx.room.*
- DataStore.
- Context.

Domain may import:
- java.time.*
- kotlinx.coroutines.flow.Flow.
- Kotlin standard library.

---

## Data Layer

Data layer maps entities to domain models.

Good:
```kotlin
fun ExpenseTransactionEntity.toDomain(): ExpenseTransaction
```

Bad:
- Passing `ExpenseTransactionEntity` directly to UI.

---

## Validation

Validation should be explicit:

```kotlin
fun validateAmount(amount: Long): ValidationResult {
    return if (amount > 0) ValidationResult.Valid
    else ValidationResult.Invalid(ValidationError.InvalidAmount)
}
```

---

## Testing

Write tests for:
- Calculation.
- Validation.
- Mapping.
- Use cases.
- DAO behavior.

Use descriptive test names:

```kotlin
@Test
fun dailyAllowance_returnsZero_whenFlexibleFundIsNegative()
```

---

## Anti-Patterns

Avoid:
- God ViewModel.
- Logic-heavy Composable.
- Entity used as UiState.
- Magic numbers.
- Hardcoded currency strings everywhere.
- Catching all exceptions silently.
- Swallowing restore errors.
- Using current date directly inside calculation without injection when testing.

---

## Date Handling

Inject clock/date provider when needed:

```kotlin
interface DateProvider {
    fun today(): LocalDate
    fun now(): Instant
}
```

This makes tests deterministic.

---

## Definition of Good Kotlin Code

Good Kotlin code in this project is:
- readable,
- testable,
- layered,
- null-safe,
- deterministic,
- offline-first,
- free from unnecessary abstractions.
