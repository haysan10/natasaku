package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.IncomeSourceDao;
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
public final class AppModule_ProvideIncomeSourceDaoFactory implements Factory<IncomeSourceDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideIncomeSourceDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public IncomeSourceDao get() {
    return provideIncomeSourceDao(dbProvider.get());
  }

  public static AppModule_ProvideIncomeSourceDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideIncomeSourceDaoFactory(dbProvider);
  }

  public static IncomeSourceDao provideIncomeSourceDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideIncomeSourceDao(db));
  }
}
