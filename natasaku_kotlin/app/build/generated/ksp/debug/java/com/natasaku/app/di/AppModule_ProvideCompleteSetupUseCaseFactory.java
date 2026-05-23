package com.natasaku.app.di;

import com.natasaku.app.data.datastore.UserPreferenceDataStore;
import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.database.NataSakuDatabase;
import com.natasaku.app.domain.usecase.CompleteSetupUseCase;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata("javax.inject.Singleton")
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
public final class AppModule_ProvideCompleteSetupUseCaseFactory implements Factory<CompleteSetupUseCase> {
  private final Provider<NataSakuDatabase> dbProvider;

  private final Provider<BudgetPeriodDao> daoProvider;

  private final Provider<UserPreferenceDataStore> storeProvider;

  public AppModule_ProvideCompleteSetupUseCaseFactory(Provider<NataSakuDatabase> dbProvider,
      Provider<BudgetPeriodDao> daoProvider, Provider<UserPreferenceDataStore> storeProvider) {
    this.dbProvider = dbProvider;
    this.daoProvider = daoProvider;
    this.storeProvider = storeProvider;
  }

  @Override
  public CompleteSetupUseCase get() {
    return provideCompleteSetupUseCase(dbProvider.get(), daoProvider.get(), storeProvider.get());
  }

  public static AppModule_ProvideCompleteSetupUseCaseFactory create(
      Provider<NataSakuDatabase> dbProvider, Provider<BudgetPeriodDao> daoProvider,
      Provider<UserPreferenceDataStore> storeProvider) {
    return new AppModule_ProvideCompleteSetupUseCaseFactory(dbProvider, daoProvider, storeProvider);
  }

  public static CompleteSetupUseCase provideCompleteSetupUseCase(NataSakuDatabase db,
      BudgetPeriodDao dao, UserPreferenceDataStore store) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideCompleteSetupUseCase(db, dao, store));
  }
}
