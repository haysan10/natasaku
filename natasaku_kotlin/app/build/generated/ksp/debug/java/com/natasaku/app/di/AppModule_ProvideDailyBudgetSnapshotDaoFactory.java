package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao;
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
public final class AppModule_ProvideDailyBudgetSnapshotDaoFactory implements Factory<DailyBudgetSnapshotDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideDailyBudgetSnapshotDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public DailyBudgetSnapshotDao get() {
    return provideDailyBudgetSnapshotDao(dbProvider.get());
  }

  public static AppModule_ProvideDailyBudgetSnapshotDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideDailyBudgetSnapshotDaoFactory(dbProvider);
  }

  public static DailyBudgetSnapshotDao provideDailyBudgetSnapshotDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideDailyBudgetSnapshotDao(db));
  }
}
