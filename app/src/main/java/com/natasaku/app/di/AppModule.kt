package com.natasaku.app.di

import android.content.Context
import com.natasaku.app.data.export.MonthlyReportExporters
import com.natasaku.app.data.export.BackupRestoreService
import com.natasaku.app.data.datastore.UserPreferenceDataStore
import com.natasaku.app.data.local.dao.BackupRestoreDao
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.database.DatabaseProvider
import com.natasaku.app.data.local.database.NataSakuDatabase
import com.natasaku.app.data.repository.BudgetRepositoryImpl
import com.natasaku.app.data.repository.SettingsRepositoryImpl
import com.natasaku.app.data.repository.setup.CompleteSetupUseCaseImpl
import com.natasaku.app.reminder.ReminderScheduler
import com.natasaku.app.domain.calculator.BudgetCalculator
import com.natasaku.app.domain.calculator.DailyBudgetCalculator
import com.natasaku.app.domain.calculator.LeftoverAllocationCalculator
import com.natasaku.app.domain.calculator.MonthlyReportCalculator
import com.natasaku.app.domain.calculator.OverbudgetCalculator
import com.natasaku.app.domain.repository.BudgetRepository
import com.natasaku.app.domain.repository.SettingsRepository
import com.natasaku.app.domain.usecase.CompleteSetupUseCase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): NataSakuDatabase = DatabaseProvider.get(context)

    @Provides fun provideBudgetPeriodDao(db: NataSakuDatabase): BudgetPeriodDao = db.budgetPeriodDao()
    @Provides fun provideIncomeSourceDao(db: NataSakuDatabase): IncomeSourceDao = db.incomeSourceDao()
    @Provides fun provideFixedExpenseDao(db: NataSakuDatabase): FixedExpenseDao = db.fixedExpenseDao()
    @Provides fun provideSavingTargetDao(db: NataSakuDatabase): SavingTargetDao = db.savingTargetDao()
    @Provides fun provideSavingAllocationDao(db: NataSakuDatabase): SavingAllocationDao = db.savingAllocationDao()
    @Provides fun provideDailyBudgetSnapshotDao(db: NataSakuDatabase): DailyBudgetSnapshotDao = db.dailyBudgetSnapshotDao()
    @Provides fun provideExpenseTransactionDao(db: NataSakuDatabase): ExpenseTransactionDao = db.expenseTransactionDao()
    @Provides fun provideBackupRestoreDao(db: NataSakuDatabase): BackupRestoreDao = db.backupRestoreDao()

    @Provides
    @Singleton
    fun provideUserPreferenceDataStore(@ApplicationContext context: Context): UserPreferenceDataStore = UserPreferenceDataStore(context)

    @Provides fun provideBudgetCalculator(): BudgetCalculator = BudgetCalculator()
    @Provides fun provideDailyBudgetCalculator(): DailyBudgetCalculator = DailyBudgetCalculator()
    @Provides fun provideOverbudgetCalculator(): OverbudgetCalculator = OverbudgetCalculator()
    @Provides fun provideLeftoverAllocationCalculator(): LeftoverAllocationCalculator = LeftoverAllocationCalculator()
    @Provides fun provideMonthlyReportCalculator(): MonthlyReportCalculator = MonthlyReportCalculator()

    @Provides
    @Singleton
    fun provideMonthlyReportExporters(@ApplicationContext context: Context): MonthlyReportExporters = MonthlyReportExporters(context)

    @Provides
    @Singleton
    fun provideBackupRestoreService(
        @ApplicationContext context: Context,
        db: NataSakuDatabase,
        budgetPeriodDao: BudgetPeriodDao,
        incomeSourceDao: IncomeSourceDao,
        fixedExpenseDao: FixedExpenseDao,
        transactionDao: ExpenseTransactionDao,
        savingTargetDao: SavingTargetDao,
        savingAllocationDao: SavingAllocationDao,
        dailyBudgetSnapshotDao: DailyBudgetSnapshotDao,
        backupRestoreDao: BackupRestoreDao,
        dataStore: UserPreferenceDataStore,
    ): BackupRestoreService = BackupRestoreService(
        context = context,
        db = db,
        budgetPeriodDao = budgetPeriodDao,
        incomeSourceDao = incomeSourceDao,
        fixedExpenseDao = fixedExpenseDao,
        transactionDao = transactionDao,
        savingTargetDao = savingTargetDao,
        savingAllocationDao = savingAllocationDao,
        dailyBudgetSnapshotDao = dailyBudgetSnapshotDao,
        backupRestoreDao = backupRestoreDao,
        preferenceDataStore = dataStore,
    )

    @Provides
    @Singleton
    fun provideReminderScheduler(@ApplicationContext context: Context): ReminderScheduler = ReminderScheduler(context)

    @Provides
    @Singleton
    fun provideBudgetRepository(dao: BudgetPeriodDao): BudgetRepository = BudgetRepositoryImpl(dao)

    @Provides
    @Singleton
    fun provideSettingsRepository(store: UserPreferenceDataStore): SettingsRepository = SettingsRepositoryImpl(store)

    @Provides
    @Singleton
    fun provideCompleteSetupUseCase(
        db: NataSakuDatabase,
        dao: BudgetPeriodDao,
        store: UserPreferenceDataStore,
    ): CompleteSetupUseCase = CompleteSetupUseCaseImpl(
        db = db,
        budgetRepository = BudgetRepositoryImpl(dao),
        settingsRepository = SettingsRepositoryImpl(store),
    )
}
