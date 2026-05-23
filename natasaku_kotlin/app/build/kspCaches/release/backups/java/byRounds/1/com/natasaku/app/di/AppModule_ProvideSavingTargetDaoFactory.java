package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.SavingTargetDao;
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
public final class AppModule_ProvideSavingTargetDaoFactory implements Factory<SavingTargetDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideSavingTargetDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public SavingTargetDao get() {
    return provideSavingTargetDao(dbProvider.get());
  }

  public static AppModule_ProvideSavingTargetDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideSavingTargetDaoFactory(dbProvider);
  }

  public static SavingTargetDao provideSavingTargetDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideSavingTargetDao(db));
  }
}
