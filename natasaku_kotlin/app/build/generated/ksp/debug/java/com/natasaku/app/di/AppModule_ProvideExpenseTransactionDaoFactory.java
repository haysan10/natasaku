package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.ExpenseTransactionDao;
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
public final class AppModule_ProvideExpenseTransactionDaoFactory implements Factory<ExpenseTransactionDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideExpenseTransactionDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public ExpenseTransactionDao get() {
    return provideExpenseTransactionDao(dbProvider.get());
  }

  public static AppModule_ProvideExpenseTransactionDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideExpenseTransactionDaoFactory(dbProvider);
  }

  public static ExpenseTransactionDao provideExpenseTransactionDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideExpenseTransactionDao(db));
  }
}
