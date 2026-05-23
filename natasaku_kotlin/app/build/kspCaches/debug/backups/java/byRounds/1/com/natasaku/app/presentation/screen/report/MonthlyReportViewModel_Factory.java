package com.natasaku.app.presentation.screen.report;

import com.natasaku.app.data.export.MonthlyReportExporters;
import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.dao.ExpenseTransactionDao;
import com.natasaku.app.data.local.dao.FixedExpenseDao;
import com.natasaku.app.data.local.dao.IncomeSourceDao;
import com.natasaku.app.data.local.dao.SavingAllocationDao;
import com.natasaku.app.domain.calculator.DailyBudgetCalculator;
import com.natasaku.app.domain.calculator.MonthlyReportCalculator;
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
public final class MonthlyReportViewModel_Factory implements Factory<MonthlyReportViewModel> {
  private final Provider<BudgetPeriodDao> budgetPeriodDaoProvider;

  private final Provider<IncomeSourceDao> incomeSourceDaoProvider;

  private final Provider<ExpenseTransactionDao> transactionDaoProvider;

  private final Provider<FixedExpenseDao> fixedExpenseDaoProvider;

  private final Provider<SavingAllocationDao> savingAllocationDaoProvider;

  private final Provider<MonthlyReportCalculator> monthlyReportCalculatorProvider;

  private final Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider;

  private final Provider<MonthlyReportExporters> exportersProvider;

  public MonthlyReportViewModel_Factory(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<SavingAllocationDao> savingAllocationDaoProvider,
      Provider<MonthlyReportCalculator> monthlyReportCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<MonthlyReportExporters> exportersProvider) {
    this.budgetPeriodDaoProvider = budgetPeriodDaoProvider;
    this.incomeSourceDaoProvider = incomeSourceDaoProvider;
    this.transactionDaoProvider = transactionDaoProvider;
    this.fixedExpenseDaoProvider = fixedExpenseDaoProvider;
    this.savingAllocationDaoProvider = savingAllocationDaoProvider;
    this.monthlyReportCalculatorProvider = monthlyReportCalculatorProvider;
    this.dailyBudgetCalculatorProvider = dailyBudgetCalculatorProvider;
    this.exportersProvider = exportersProvider;
  }

  @Override
  public MonthlyReportViewModel get() {
    return newInstance(budgetPeriodDaoProvider.get(), incomeSourceDaoProvider.get(), transactionDaoProvider.get(), fixedExpenseDaoProvider.get(), savingAllocationDaoProvider.get(), monthlyReportCalculatorProvider.get(), dailyBudgetCalculatorProvider.get(), exportersProvider.get());
  }

  public static MonthlyReportViewModel_Factory create(
      Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<SavingAllocationDao> savingAllocationDaoProvider,
      Provider<MonthlyReportCalculator> monthlyReportCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<MonthlyReportExporters> exportersProvider) {
    return new MonthlyReportViewModel_Factory(budgetPeriodDaoProvider, incomeSourceDaoProvider, transactionDaoProvider, fixedExpenseDaoProvider, savingAllocationDaoProvider, monthlyReportCalculatorProvider, dailyBudgetCalculatorProvider, exportersProvider);
  }

  public static MonthlyReportViewModel newInstance(BudgetPeriodDao budgetPeriodDao,
      IncomeSourceDao incomeSourceDao, ExpenseTransactionDao transactionDao,
      FixedExpenseDao fixedExpenseDao, SavingAllocationDao savingAllocationDao,
      MonthlyReportCalculator monthlyReportCalculator, DailyBudgetCalculator dailyBudgetCalculator,
      MonthlyReportExporters exporters) {
    return new MonthlyReportViewModel(budgetPeriodDao, incomeSourceDao, transactionDao, fixedExpenseDao, savingAllocationDao, monthlyReportCalculator, dailyBudgetCalculator, exporters);
  }
}
