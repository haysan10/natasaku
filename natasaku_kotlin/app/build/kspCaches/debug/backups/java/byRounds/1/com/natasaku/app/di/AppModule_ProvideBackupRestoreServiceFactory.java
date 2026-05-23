package com.natasaku.app.di;

import android.content.Context;
import com.natasaku.app.data.datastore.UserPreferenceDataStore;
import com.natasaku.app.data.export.BackupRestoreService;
import com.natasaku.app.data.local.dao.BackupRestoreDao;
import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao;
import com.natasaku.app.data.local.dao.ExpenseTransactionDao;
import com.natasaku.app.data.local.dao.FixedExpenseDao;
import com.natasaku.app.data.local.dao.IncomeSourceDao;
import com.natasaku.app.data.local.dao.SavingAllocationDao;
import com.natasaku.app.data.local.dao.SavingTargetDao;
import com.natasaku.app.data.local.database.NataSakuDatabase;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata("dagger.hilt.android.qualifiers.ApplicationContext")
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
public final class AppModule_ProvideBackupRestoreServiceFactory implements Factory<BackupRestoreService> {
  private final Provider<Context> contextProvider;

  private final Provider<NataSakuDatabase> dbProvider;

  private final Provider<BudgetPeriodDao> budgetPeriodDaoProvider;

  private final Provider<IncomeSourceDao> incomeSourceDaoProvider;

  private final Provider<FixedExpenseDao> fixedExpenseDaoProvider;

  private final Provider<ExpenseTransactionDao> transactionDaoProvider;

  private final Provider<SavingTargetDao> savingTargetDaoProvider;

  private final Provider<SavingAllocationDao> savingAllocationDaoProvider;

  private final Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider;

  private final Provider<BackupRestoreDao> backupRestoreDaoProvider;

  private final Provider<UserPreferenceDataStore> dataStoreProvider;

  public AppModule_ProvideBackupRestoreServiceFactory(Provider<Context> contextProvider,
      Provider<NataSakuDatabase> dbProvider, Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<SavingAllocationDao> savingAllocationDaoProvider,
      Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider,
      Provider<BackupRestoreDao> backupRestoreDaoProvider,
      Provider<UserPreferenceDataStore> dataStoreProvider) {
    this.contextProvider = contextProvider;
    this.dbProvider = dbProvider;
    this.budgetPeriodDaoProvider = budgetPeriodDaoProvider;
    this.incomeSourceDaoProvider = incomeSourceDaoProvider;
    this.fixedExpenseDaoProvider = fixedExpenseDaoProvider;
    this.transactionDaoProvider = transactionDaoProvider;
    this.savingTargetDaoProvider = savingTargetDaoProvider;
    this.savingAllocationDaoProvider = savingAllocationDaoProvider;
    this.dailyBudgetSnapshotDaoProvider = dailyBudgetSnapshotDaoProvider;
    this.backupRestoreDaoProvider = backupRestoreDaoProvider;
    this.dataStoreProvider = dataStoreProvider;
  }

  @Override
  public BackupRestoreService get() {
    return provideBackupRestoreService(contextProvider.get(), dbProvider.get(), budgetPeriodDaoProvider.get(), incomeSourceDaoProvider.get(), fixedExpenseDaoProvider.get(), transactionDaoProvider.get(), savingTargetDaoProvider.get(), savingAllocationDaoProvider.get(), dailyBudgetSnapshotDaoProvider.get(), backupRestoreDaoProvider.get(), dataStoreProvider.get());
  }

  public static AppModule_ProvideBackupRestoreServiceFactory create(
      Provider<Context> contextProvider, Provider<NataSakuDatabase> dbProvider,
      Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<IncomeSourceDao> incomeSourceDaoProvider,
      Provider<FixedExpenseDao> fixedExpenseDaoProvider,
      Provider<ExpenseTransactionDao> transactionDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<SavingAllocationDao> savingAllocationDaoProvider,
      Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider,
      Provider<BackupRestoreDao> backupRestoreDaoProvider,
      Provider<UserPreferenceDataStore> dataStoreProvider) {
    return new AppModule_ProvideBackupRestoreServiceFactory(contextProvider, dbProvider, budgetPeriodDaoProvider, incomeSourceDaoProvider, fixedExpenseDaoProvider, transactionDaoProvider, savingTargetDaoProvider, savingAllocationDaoProvider, dailyBudgetSnapshotDaoProvider, backupRestoreDaoProvider, dataStoreProvider);
  }

  public static BackupRestoreService provideBackupRestoreService(Context context,
      NataSakuDatabase db, BudgetPeriodDao budgetPeriodDao, IncomeSourceDao incomeSourceDao,
      FixedExpenseDao fixedExpenseDao, ExpenseTransactionDao transactionDao,
      SavingTargetDao savingTargetDao, SavingAllocationDao savingAllocationDao,
      DailyBudgetSnapshotDao dailyBudgetSnapshotDao, BackupRestoreDao backupRestoreDao,
      UserPreferenceDataStore dataStore) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideBackupRestoreService(context, db, budgetPeriodDao, incomeSourceDao, fixedExpenseDao, transactionDao, savingTargetDao, savingAllocationDao, dailyBudgetSnapshotDao, backupRestoreDao, dataStore));
  }
}
