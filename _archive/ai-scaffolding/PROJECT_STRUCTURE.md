# PROJECT_STRUCTURE.md - Expected NataSaku Android Structure

## Purpose

Dokumen ini mendefinisikan struktur project Android yang diharapkan untuk NataSaku.

Gunakan struktur ini agar agent tidak membuat folder dan layer secara acak.

---

## 1. Root Project Structure

Expected root:

```text
NataSaku/
  README.md
  PROJECT_STRUCTURE.md
  DEVELOPMENT_PROMPT.md
  IMPLEMENTATION_ORDER.md
  MVP_CHECKLIST.md
  DO_NOT_BUILD.md

  .agent/
    skill.md
    agents/

  conductor/
    index.md
    product.md
    product-guidelines.md
    tech-stack.md
    workflow.md
    tracks.md
    code_styleguides/
    tracks/

  docs/
    README.md
    app-flow.md
    data-model.md
    calculation-rules.md
    design-tokens.md
    component-system.md
    ui-screen-spec.md
    copywriting.md
    accessibility-guidelines.md
    microinteractions.md
    monthly-report-spec.md
    export-spec.md
    backup-restore-spec.md
    testing-checklist.md
    release-checklist.md

  app/
    build.gradle.kts
    src/
```

---

## 2. Android Source Structure

Recommended package:

```text
app/src/main/java/com/natasaku/app/
  NataSakuApp.kt
  MainActivity.kt

  core/
    money/
      MoneyFormatter.kt
      RupiahFormatter.kt
    date/
      DateProvider.kt
      SystemDateProvider.kt
      DateFormatter.kt
    result/
      AppResult.kt
      ValidationResult.kt
    ui/
      UiText.kt
    util/

  data/
    local/
      database/
        NataSakuDatabase.kt
        RoomConverters.kt
      dao/
        BudgetPeriodDao.kt
        IncomeSourceDao.kt
        FixedExpenseDao.kt
        ExpenseTransactionDao.kt
        SavingTargetDao.kt
        SavingAllocationDao.kt
        DailyBudgetSnapshotDao.kt
      entity/
        BudgetPeriodEntity.kt
        IncomeSourceEntity.kt
        FixedExpenseEntity.kt
        ExpenseTransactionEntity.kt
        SavingTargetEntity.kt
        SavingAllocationEntity.kt
        DailyBudgetSnapshotEntity.kt
      mapper/
        BudgetMappers.kt
        TransactionMappers.kt
        SavingMappers.kt
    datastore/
      UserPreferenceDataStore.kt
      UserPreferenceKeys.kt
    repository/
      BudgetRepositoryImpl.kt
      TransactionRepositoryImpl.kt
      SavingRepositoryImpl.kt
      ReportRepositoryImpl.kt
      SettingsRepositoryImpl.kt
    export/
      CsvExporter.kt
      PdfReportExporter.kt
      ExportedFile.kt
    backup/
      BackupJsonSerializer.kt
      BackupRepositoryImpl.kt
      RestoreValidator.kt

  domain/
    model/
      BudgetPeriod.kt
      IncomeSource.kt
      FixedExpense.kt
      ExpenseTransaction.kt
      SavingTarget.kt
      SavingAllocation.kt
      DailyBudgetSnapshot.kt
      MonthlyReport.kt
      UserPreference.kt
    repository/
      BudgetRepository.kt
      TransactionRepository.kt
      SavingRepository.kt
      ReportRepository.kt
      SettingsRepository.kt
      BackupRepository.kt
    usecase/
      GetActivePeriodUseCase.kt
      CreateBudgetPeriodUseCase.kt
      CalculateBudgetSummaryUseCase.kt
      GetHomeDashboardUseCase.kt
      AddExpenseTransactionUseCase.kt
      UpdateExpenseTransactionUseCase.kt
      DeleteExpenseTransactionUseCase.kt
      AllocateDailyLeftoverUseCase.kt
      GenerateMonthlyReportUseCase.kt
      ExportReportPdfUseCase.kt
      ExportTransactionsCsvUseCase.kt
      BackupLocalDataUseCase.kt
      RestoreLocalDataUseCase.kt
    calculator/
      BudgetCalculator.kt
      DailyBudgetCalculator.kt
      OverbudgetCalculator.kt
      LeftoverAllocationCalculator.kt
      MonthlyReportCalculator.kt

  presentation/
    navigation/
      Screen.kt
      NataSakuNavHost.kt
      MainBottomNavigation.kt
    theme/
      Color.kt
      Type.kt
      Shape.kt
      Theme.kt
      NataDimens.kt
      StatusColors.kt
    component/
      NataPrimaryButton.kt
      NataSecondaryButton.kt
      MoneyText.kt
      FinanceSummaryCard.kt
      DailyAllowanceHeroCard.kt
      StatusChip.kt
      CategoryChip.kt
      TransactionRow.kt
      EmptyState.kt
      ReportMetricCard.kt
      SettingsRow.kt
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

## 3. Test Structure

```text
app/src/test/java/com/natasaku/app/
  domain/
    calculator/
      BudgetCalculatorTest.kt
      DailyBudgetCalculatorTest.kt
      OverbudgetCalculatorTest.kt
      LeftoverAllocationCalculatorTest.kt
      MonthlyReportCalculatorTest.kt
  data/
    mapper/
      MapperTest.kt
  presentation/
    viewmodel/
      HomeViewModelTest.kt
      SetupBudgetViewModelTest.kt

app/src/androidTest/java/com/natasaku/app/
  data/
    local/
      NataSakuDatabaseTest.kt
      ExpenseTransactionDaoTest.kt
  presentation/
    HomeDashboardScreenTest.kt
    AddExpenseBottomSheetTest.kt
    SetupFlowTest.kt
```

---

## 4. Layer Rules

### Presentation Layer

Can use:

- Compose.
- ViewModel.
- Navigation.
- Android resources.
- Domain use cases.

Cannot use:

- Room DAO directly.
- Room entities directly.
- Business formulas directly.
- File export implementation directly.

### Domain Layer

Can use:

- Pure Kotlin.
- LocalDate.
- Instant.
- Repository interfaces.
- Use cases.
- Calculators.

Cannot use:

- Android Context.
- Compose.
- Room.
- DataStore.
- FileProvider.

### Data Layer

Can use:

- Room.
- DAO.
- Entity.
- DataStore.
- File APIs.
- Repository implementations.

Cannot use:

- Compose UI.
- Navigation.
- UI-only copywriting decisions.

---

## 5. Naming Conventions

Screens:

```kotlin
HomeDashboardScreen
SetupIncomeScreen
MonthlyReportScreen
```

ViewModels:

```kotlin
HomeViewModel
SetupBudgetViewModel
TransactionHistoryViewModel
```

UiState:

```kotlin
HomeUiState
SetupIncomeUiState
MonthlyReportUiState
```

Use cases:

```kotlin
CalculateBudgetSummaryUseCase
AddExpenseTransactionUseCase
GenerateMonthlyReportUseCase
```

Repositories:

```kotlin
BudgetRepository
BudgetRepositoryImpl
```

---

## 6. Dependency Direction

Allowed:

```text
presentation -> domain
data -> domain
app wiring -> presentation/data/domain
```

Not allowed:

```text
domain -> data
domain -> presentation
data -> presentation
presentation -> Room DAO directly
```

---

## 7. Important Implementation Rules

1. Money uses `Long`.
2. Do not use `Double` or `Float` for currency.
3. Use `LocalDate` for transaction and period dates.
4. Use `Instant` for createdAt/updatedAt.
5. Use Room converters for LocalDate and Instant.
6. Use Flow for observable local data.
7. Use StateFlow for UI state.
8. Use `Dispatchers.IO` for file/database operations.
9. Keep Composables UI-only.
10. Keep calculation deterministic and unit-tested.
