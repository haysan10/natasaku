package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.domain.repository.BudgetRepository;
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
public final class AppModule_ProvideBudgetRepositoryFactory implements Factory<BudgetRepository> {
  private final Provider<BudgetPeriodDao> daoProvider;

  public AppModule_ProvideBudgetRepositoryFactory(Provider<BudgetPeriodDao> daoProvider) {
    this.daoProvider = daoProvider;
  }

  @Override
  public BudgetRepository get() {
    return provideBudgetRepository(daoProvider.get());
  }

  public static AppModule_ProvideBudgetRepositoryFactory create(
      Provider<BudgetPeriodDao> daoProvider) {
    return new AppModule_ProvideBudgetRepositoryFactory(daoProvider);
  }

  public static BudgetRepository provideBudgetRepository(BudgetPeriodDao dao) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideBudgetRepository(dao));
  }
}
