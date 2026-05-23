package com.natasaku.app.presentation.screen.splash;

import com.natasaku.app.data.local.dao.BudgetPeriodDao;
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
public final class SplashViewModel_Factory implements Factory<SplashViewModel> {
  private final Provider<SettingsRepository> settingsRepositoryProvider;

  private final Provider<BudgetPeriodDao> budgetPeriodDaoProvider;

  public SplashViewModel_Factory(Provider<SettingsRepository> settingsRepositoryProvider,
      Provider<BudgetPeriodDao> budgetPeriodDaoProvider) {
    this.settingsRepositoryProvider = settingsRepositoryProvider;
    this.budgetPeriodDaoProvider = budgetPeriodDaoProvider;
  }

  @Override
  public SplashViewModel get() {
    return newInstance(settingsRepositoryProvider.get(), budgetPeriodDaoProvider.get());
  }

  public static SplashViewModel_Factory create(
      Provider<SettingsRepository> settingsRepositoryProvider,
      Provider<BudgetPeriodDao> budgetPeriodDaoProvider) {
    return new SplashViewModel_Factory(settingsRepositoryProvider, budgetPeriodDaoProvider);
  }

  public static SplashViewModel newInstance(SettingsRepository settingsRepository,
      BudgetPeriodDao budgetPeriodDao) {
    return new SplashViewModel(settingsRepository, budgetPeriodDao);
  }
}
