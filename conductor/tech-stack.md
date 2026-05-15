# conductor/tech-stack.md — NataSaku Technical Context

## Platform

NataSaku is an Android native application.

Target:
- Android native.
- Kotlin.
- Jetpack Compose.
- Material Design 3.
- Offline-first.
- Local data only.

---

## Required Technology

### Language

- Kotlin.

### UI

- Jetpack Compose.
- Material Design 3.
- Navigation Compose.

### Architecture

- MVVM.
- Clean Architecture ringan.
- Repository pattern.
- Use case pattern.
- StateFlow-based UI state.

### Local Storage

- Room for structured financial data.
- DataStore Preferences for settings.
- Local file system for PDF, CSV, and backup files.

### Async

- Kotlin Coroutines.
- Flow / StateFlow.

### Testing

- JUnit.
- Kotlin test.
- Room testing.
- ViewModel tests.
- Compose UI tests.
- Optional: Turbine for Flow tests.
- Optional: MockK for mocks.

---

## Forbidden Technology

Do not add:

- Firebase.
- Supabase.
- Appwrite.
- Backend API.
- Retrofit for remote services.
- Login SDK.
- Google Sign-In.
- Bank API.
- Payment SDK.
- Analytics SDK.
- Ads SDK.
- Cloud storage SDK.
- Remote config.
- Push notification server.

Local notification is allowed if implemented with Android local APIs.

---

## Recommended Package Structure

```text
com.natasaku.app/
  NataSakuApp.kt
  MainActivity.kt

  core/
    money/
    date/
    result/
    ui/
    util/

  data/
    local/
      database/
      dao/
      entity/
      mapper/
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
```

---

## Layer Rules

### Presentation

Can use:
- Compose.
- ViewModel.
- Android resources.
- Navigation.
- UiState and UiEvent.
- Domain use cases.

Cannot use:
- Room DAO directly.
- Entity classes directly.
- Business formulas directly in Composable.
- File export implementation details.

### Domain

Can use:
- Pure Kotlin.
- LocalDate / Instant.
- Repository interfaces.
- Use cases.
- Calculators.
- Validation.

Cannot use:
- Android Context.
- Compose.
- Room.
- DataStore.
- FileProvider.
- Android resources.

### Data

Can use:
- Room.
- DAO.
- Entity.
- Mapper.
- DataStore.
- File APIs.
- Repository implementations.

Cannot use:
- Compose UI.
- Screen navigation.
- UI copy decisions beyond technical errors.

---

## Money Rules

- Store all Rupiah amounts as `Long`.
- Do not use `Float` or `Double` for money.
- Format money only at UI/presentation boundary.
- Calculation should use integer math and explicit rounding rules.

---

## Date Rules

- Use `java.time.LocalDate` for dates.
- Use `Instant` for createdAt/updatedAt timestamps.
- Store LocalDate in Room using ISO string converter.
- Store Instant using epoch millis or ISO string converter.
- Period day count is inclusive:
  ```kotlin
  ChronoUnit.DAYS.between(startDate, endDate).toInt() + 1
  ```

---

## Room Requirements

Database must include:
- BudgetPeriodEntity.
- IncomeSourceEntity.
- FixedExpenseEntity.
- ExpenseTransactionEntity.
- SavingTargetEntity.
- SavingAllocationEntity.
- DailyBudgetSnapshotEntity.

Indexes:
- periodId.
- date.
- periodId + date.
- deletedAt for transactions.
- isActive for budget period.

---

## DataStore Requirements

Preferences:
- currencyCode.
- themeMode.
- defaultLeftoverAllocation.
- dailyReminderEnabled.
- dailyReminderTime.
- onboardingCompleted.
- activePeriodId.

Defaults:
- currencyCode = IDR.
- themeMode = SYSTEM.
- defaultLeftoverAllocation = ASK_EVERY_TIME.
- dailyReminderEnabled = false.
- onboardingCompleted = false.
- activePeriodId = null.

---

## Export Requirements

CSV:
- Local file.
- UTF-8.
- Proper escaping.
- No deleted transactions.
- Filename: `NataSaku_Transaksi_YYYY_MM.csv`

PDF:
- Local file.
- Clean professional report.
- Filename: `NataSaku_Laporan_YYYY_MM.pdf`

Backup:
- JSON local file.
- Filename: `NataSaku_Backup_YYYY_MM_DD.json`
- Include app name and schemaVersion.

---

## Performance Rules

- Do not block main thread.
- Export and backup run on Dispatchers.IO.
- Use LazyColumn for lists.
- Use Flow for reactive local data.
- Avoid recalculating reports on every recomposition.
- Keep dashboard queries optimized.

---

## Security and Privacy

- No internet requirement.
- No server.
- No account.
- No analytics.
- No cloud.
- Do not log sensitive financial data.
- Share files only after explicit user action.

---

## Dependency Decision Rule

Before adding any dependency:

1. Check if AndroidX or Kotlin standard library already solves it.
2. Confirm it does not require internet/backend.
3. Confirm it does not collect data.
4. Add rationale to this file if dependency is significant.
5. Add tests or usage documentation if needed.
