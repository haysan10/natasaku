package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.FixedExpenseDao;
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
public final class AppModule_ProvideFixedExpenseDaoFactory implements Factory<FixedExpenseDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideFixedExpenseDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public FixedExpenseDao get() {
    return provideFixedExpenseDao(dbProvider.get());
  }

  public static AppModule_ProvideFixedExpenseDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideFixedExpenseDaoFactory(dbProvider);
  }

  public static FixedExpenseDao provideFixedExpenseDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideFixedExpenseDao(db));
  }
}
