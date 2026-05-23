package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.SavingAllocationDao;
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
public final class AppModule_ProvideSavingAllocationDaoFactory implements Factory<SavingAllocationDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideSavingAllocationDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public SavingAllocationDao get() {
    return provideSavingAllocationDao(dbProvider.get());
  }

  public static AppModule_ProvideSavingAllocationDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideSavingAllocationDaoFactory(dbProvider);
  }

  public static SavingAllocationDao provideSavingAllocationDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideSavingAllocationDao(db));
  }
}
