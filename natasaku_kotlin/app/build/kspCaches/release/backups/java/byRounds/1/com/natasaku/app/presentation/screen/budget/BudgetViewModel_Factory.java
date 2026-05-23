package com.natasaku.app.presentation.screen.budget;

import com.natasaku.app.data.local.dao.BudgetPeriodDao;
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
public final class BudgetViewModel_Factory implements Factory<BudgetViewModel> {
  private final Provider<BudgetPeriodDao> budgetPeriodDaoProvider;

  private final Provider<IncomeSourceDao> incomeSourceDaoProvider;

  private final Provider<FixedExpenseDao> fixedExpenseDaoProvider;

  private final Provider<SavingTargetDao> savingTargetDaoProvider;

  private final Provider<ExpenseTransactionDao> transactionDaoProvider;

  private final Provider<BudgetCalculator> budgetCalculatorProvider;

  private final Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider;

  private final Provider<OverbudgetCalculator> overbudgetCalculatorProvider;

  public BudgetViewModel_Factory(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<BudgetCalculator> budgetCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<OverbudgetCalculator> overbudgetCalculatorProvider) {
    this.budgetPeriodDaoProvider = budgetPeriodDaoProvider;
    this.incomeSourceDaoProvider = incomeSourceDaoProvider;
    this.fixedExpenseDaoProvider = fixedExpenseDaoProvider;
    this.savingTargetDaoProvider = savingTargetDaoProvider;
    this.transactionDaoProvider = transactionDaoProvider;
    this.budgetCalculatorProvider = budgetCalculatorProvider;
    this.dailyBudgetCalculatorProvider = dailyBudgetCalculatorProvider;
    this.overbudgetCalculatorProvider = overbudgetCalculatorProvider;
  }

  @Override
  public BudgetViewModel get() {
    return newInstance(budgetPeriodDaoProvider.get(), incomeSourceDaoProvider.get(), fixedExpenseDaoProvider.get(), savingTargetDaoProvider.get(), transactionDaoProvider.get(), budgetCalculatorProvider.get(), dailyBudgetCalculatorProvider.get(), overbudgetCalculatorProvider.get());
  }

  public static BudgetViewModel_Factory create(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<BudgetCalculator> budgetCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<OverbudgetCalculator> overbudgetCalculatorProvider) {
    return new BudgetViewModel_Factory(budgetPeriodDaoProvider, incomeSourceDaoProvider, fixedExpenseDaoProvider, savingTargetDaoProvider, transactionDaoProvider, budgetCalculatorProvider, dailyBudgetCalculatorProvider, overbudgetCalculatorProvider);
  }

  public static BudgetViewModel newInstance(BudgetPeriodDao budgetPeriodDao,
      IncomeSourceDao incomeSourceDao, FixedExpenseDao fixedExpenseDao,
      SavingTargetDao savingTargetDao, ExpenseTransactionDao transactionDao,
      BudgetCalculator budgetCalculator, DailyBudgetCalculator dailyBudgetCalculator,
      OverbudgetCalculator overbudgetCalculator) {
    return new BudgetViewModel(budgetPeriodDao, incomeSourceDao, fixedExpenseDao, savingTargetDao, transactionDao, budgetCalculator, dailyBudgetCalculator, overbudgetCalculator);
  }
}
