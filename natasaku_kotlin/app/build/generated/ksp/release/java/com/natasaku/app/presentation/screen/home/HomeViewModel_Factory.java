package com.natasaku.app.presentation.screen.home;

import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao;
import com.natasaku.app.data.local.dao.ExpenseTransactionDao;
import com.natasaku.app.data.local.dao.FixedExpenseDao;
import com.natasaku.app.data.local.dao.IncomeSourceDao;
import com.natasaku.app.data.local.dao.SavingTargetDao;
import com.natasaku.app.domain.calculator.BudgetCalculator;
import com.natasaku.app.domain.calculator.DailyBudgetCalculator;
import com.natasaku.app.domain.calculator.OverbudgetCalculator;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata
@QualifierMetadata
@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava",
    "cast",
    "deprecation"
})
public final class HomeViewModel_Factory implements Factory<HomeViewModel> {
  private final Provider<BudgetPeriodDao> budgetPeriodDaoProvider;

  private final Provider<ExpenseTransactionDao> transactionDaoProvider;

  private final Provider<IncomeSourceDao> incomeSourceDaoProvider;

  private final Provider<FixedExpenseDao> fixedExpenseDaoProvider;

  private final Provider<SavingTargetDao> savingTargetDaoProvider;

  private final Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider;

  private final Provider<BudgetCalculator> budgetCalculatorProvider;

  private final Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider;

  private final Provider<OverbudgetCalculator> overbudgetCalculatorProvider;

  public HomeViewModel_Factory(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider,
      Provider<BudgetCalculator> budgetCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<OverbudgetCalculator> overbudgetCalculatorProvider) {
    this.budgetPeriodDaoProvider = budgetPeriodDaoProvider;
    this.transactionDaoProvider = transactionDaoProvider;
    this.incomeSourceDaoProvider = incomeSourceDaoProvider;
    this.fixedExpenseDaoProvider = fixedExpenseDaoProvider;
    this.savingTargetDaoProvider = savingTargetDaoProvider;
    this.dailyBudgetSnapshotDaoProvider = dailyBudgetSnapshotDaoProvider;
    this.budgetCalculatorProvider = budgetCalculatorProvider;
    this.dailyBudgetCalculatorProvider = dailyBudgetCalculatorProvider;
    this.overbudgetCalculatorProvider = overbudgetCalculatorProvider;
  }

  @Override
  public HomeViewModel get() {
    return newInstance(budgetPeriodDaoProvider.get(), transactionDaoProvider.get(), incomeSourceDaoProvider.get(), fixedExpenseDaoProvider.get(), savingTargetDaoProvider.get(), dailyBudgetSnapshotDaoProvider.get(), budgetCalculatorProvider.get(), dailyBudgetCalculatorProvider.get(), overbudgetCalculatorProvider.get());
  }

  public static HomeViewModel_Factory create(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider,
      Provider<BudgetCalculator> budgetCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<OverbudgetCalculator> overbudgetCalculatorProvider) {
    return new HomeViewModel_Factory(budgetPeriodDaoProvider, transactionDaoProvider, incomeSourceDaoProvider, fixedExpenseDaoProvider, savingTargetDaoProvider, dailyBudgetSnapshotDaoProvider, budgetCalculatorProvider, dailyBudgetCalculatorProvider, overbudgetCalculatorProvider);
  }

  public static HomeViewModel newInstance(BudgetPeriodDao budgetPeriodDao,
      ExpenseTransactionDao transactionDao, IncomeSourceDao incomeSourceDao,
      FixedExpenseDao fixedExpenseDao, SavingTargetDao savingTargetDao,
      DailyBudgetSnapshotDao dailyBudgetSnapshotDao, BudgetCalculator budgetCalculator,
      DailyBudgetCalculator dailyBudgetCalculator, OverbudgetCalculator overbudgetCalculator) {
    return new HomeViewModel(budgetPeriodDao, transactionDao, incomeSourceDao, fixedExpenseDao, savingTargetDao, dailyBudgetSnapshotDao, budgetCalculator, dailyBudgetCalculator, overbudgetCalculator);
  }
}
