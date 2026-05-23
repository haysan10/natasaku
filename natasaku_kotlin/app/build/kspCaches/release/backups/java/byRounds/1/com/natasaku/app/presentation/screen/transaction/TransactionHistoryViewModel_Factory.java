package com.natasaku.app.presentation.screen.transaction;

import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.dao.ExpenseTransactionDao;
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
public final class TransactionHistoryViewModel_Factory implements Factory<TransactionHistoryViewModel> {
  private final Provider<BudgetPeriodDao> budgetPeriodDaoProvider;

  private final Provider<ExpenseTransactionDao> transactionDaoProvider;

  public TransactionHistoryViewModel_Factory(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider) {
    this.budgetPeriodDaoProvider = budgetPeriodDaoProvider;
    this.transactionDaoProvider = transactionDaoProvider;
  }

  @Override
  public TransactionHistoryViewModel get() {
    return newInstance(budgetPeriodDaoProvider.get(), transactionDaoProvider.get());
  }

  public static TransactionHistoryViewModel_Factory create(
      Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider) {
    return new TransactionHistoryViewModel_Factory(budgetPeriodDaoProvider, transactionDaoProvider);
  }

  public static TransactionHistoryViewModel newInstance(BudgetPeriodDao budgetPeriodDao,
      ExpenseTransactionDao transactionDao) {
    return new TransactionHistoryViewModel(budgetPeriodDao, transactionDao);
  }
}
