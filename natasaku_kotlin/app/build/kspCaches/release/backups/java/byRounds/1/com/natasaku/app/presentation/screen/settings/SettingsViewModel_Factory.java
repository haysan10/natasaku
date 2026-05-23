package com.natasaku.app.presentation.screen.settings;

import com.natasaku.app.data.export.BackupRestoreService;
import com.natasaku.app.domain.repository.SettingsRepository;
import com.natasaku.app.reminder.ReminderScheduler;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
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
public final class SettingsViewModel_Factory implements Factory<SettingsViewModel> {
  private final Provider<SettingsRepository> settingsRepositoryProvider;

  private final Provider<BackupRestoreService> backupRestoreServiceProvider;

  private final Provider<ReminderScheduler> reminderSchedulerProvider;

  public SettingsViewModel_Factory(Provider<SettingsRepository> settingsRepositoryProvider,
      Provider<BackupRestoreService> backupRestoreServiceProvider,
      Provider<ReminderScheduler> reminderSchedulerProvider) {
    this.settingsRepositoryProvider = settingsRepositoryProvider;
    this.backupRestoreServiceProvider = backupRestoreServiceProvider;
    this.reminderSchedulerProvider = reminderSchedulerProvider;
  }

  @Override
  public SettingsViewModel get() {
    return newInstance(settingsRepositoryProvider.get(), backupRestoreServiceProvider.get(), reminderSchedulerProvider.get());
  }

  public static SettingsViewModel_Factory create(
      Provider<SettingsRepository> settingsRepositoryProvider,
      Provider<BackupRestoreService> backupRestoreServiceProvider,
      Provider<ReminderScheduler> reminderSchedulerProvider) {
    return new SettingsViewModel_Factory(settingsRepositoryProvider, backupRestoreServiceProvider, reminderSchedulerProvider);
  }

  public static SettingsViewModel newInstance(SettingsRepository settingsRepository,
      BackupRestoreService backupRestoreService, ReminderScheduler reminderScheduler) {
    return new SettingsViewModel(settingsRepository, backupRestoreService, reminderScheduler);
  }
}
