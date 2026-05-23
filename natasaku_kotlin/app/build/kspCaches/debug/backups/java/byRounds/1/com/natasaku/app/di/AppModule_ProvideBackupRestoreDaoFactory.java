package com.natasaku.app.di;

import com.natasaku.app.data.local.dao.BackupRestoreDao;
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
public final class AppModule_ProvideBackupRestoreDaoFactory implements Factory<BackupRestoreDao> {
  private final Provider<NataSakuDatabase> dbProvider;

  public AppModule_ProvideBackupRestoreDaoFactory(Provider<NataSakuDatabase> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public BackupRestoreDao get() {
    return provideBackupRestoreDao(dbProvider.get());
  }

  public static AppModule_ProvideBackupRestoreDaoFactory create(
      Provider<NataSakuDatabase> dbProvider) {
    return new AppModule_ProvideBackupRestoreDaoFactory(dbProvider);
  }

  public static BackupRestoreDao provideBackupRestoreDao(NataSakuDatabase db) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideBackupRestoreDao(db));
  }
}
