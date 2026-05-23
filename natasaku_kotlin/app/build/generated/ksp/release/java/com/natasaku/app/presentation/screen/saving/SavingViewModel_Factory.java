package com.natasaku.app.presentation.screen.saving;

import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao;
import com.natasaku.app.data.local.dao.SavingAllocationDao;
import com.natasaku.app.data.local.dao.SavingTargetDao;
import com.natasaku.app.domain.calculator.LeftoverAllocationCalculator;
import com.natasaku.app.domain.repository.SettingsRepository;
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
public final class SavingViewModel_Factory implements Factory<SavingViewModel> {
  private final Provider<BudgetPeriodDao> budgetPeriodDaoProvider;

  private final Provider<SavingTargetDao> savingTargetDaoProvider;

  private final Provider<SavingAllocationDao> savingAllocationDaoProvider;

  private final Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider;

  private final Provider<SettingsRepository> settingsRepositoryProvider;

  private final Provider<LeftoverAllocationCalculator> leftoverAllocationCalculatorProvider;

  public SavingViewModel_Factory(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<SavingAllocationDao> savingAllocationDaoProvider,
      Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider,
      Provider<SettingsRepository> settingsRepositoryProvider,
      Provider<LeftoverAllocationCalculator> leftoverAllocationCalculatorProvider) {
    this.budgetPeriodDaoProvider = budgetPeriodDaoProvider;
    this.savingTargetDaoProvider = savingTargetDaoProvider;
    this.savingAllocationDaoProvider = savingAllocationDaoProvider;
    this.dailyBudgetSnapshotDaoProvider = dailyBudgetSnapshotDaoProvider;
    this.settingsRepositoryProvider = settingsRepositoryProvider;
    this.leftoverAllocationCalculatorProvider = leftoverAllocationCalculatorProvider;
  }

  @Override
  public SavingViewModel get() {
    return newInstance(budgetPeriodDaoProvider.get(), savingTargetDaoProvider.get(), savingAllocationDaoProvider.get(), dailyBudgetSnapshotDaoProvider.get(), settingsRepositoryProvider.get(), leftoverAllocationCalculatorProvider.get());
  }

  public static SavingViewModel_Factory create(Provider<BudgetPeriodDao> budgetPeriodDaoProvider,
      Provider<SavingTargetDao> savingTargetDaoProvider,
      Provider<SavingAllocationDao> savingAllocationDaoProvider,
      Provider<DailyBudgetSnapshotDao> dailyBudgetSnapshotDaoProvider,
      Provider<SettingsRepository> settingsRepositoryProvider,
      Provider<LeftoverAllocationCalculator> leftoverAllocationCalculatorProvider) {
    return new SavingViewModel_Factory(budgetPeriodDaoProvider, savingTargetDaoProvider, savingAllocationDaoProvider, dailyBudgetSnapshotDaoProvider, settingsRepositoryProvider, leftoverAllocationCalculatorProvider);
  }

  public static SavingViewModel newInstance(BudgetPeriodDao budgetPeriodDao,
      SavingTargetDao savingTargetDao, SavingAllocationDao savingAllocationDao,
      DailyBudgetSnapshotDao dailyBudgetSnapshotDao, SettingsRepository settingsRepository,
      LeftoverAllocationCalculator leftoverAllocationCalculator) {
    return new SavingViewModel(budgetPeriodDao, savingTargetDao, savingAllocationDao, dailyBudgetSnapshotDao, settingsRepository, leftoverAllocationCalculator);
  }
}
