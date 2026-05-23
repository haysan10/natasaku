package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.database.NataSakuDatabase;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
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
public final class AppModule_ProvideBudgetPeriodDaoFactory implements Factory<BudgetPeriodDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideBudgetPeriodDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public BudgetPeriodDao get() {
    return provideBudgetPeriodDao(dbProvider.get());
  }

  public static AppModule_ProvideBudgetPeriodDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideBudgetPeriodDaoFactory(dbProvider);
  }

  public static BudgetPeriodDao provideBudgetPeriodDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideBudgetPeriodDao(db));
  }
}
