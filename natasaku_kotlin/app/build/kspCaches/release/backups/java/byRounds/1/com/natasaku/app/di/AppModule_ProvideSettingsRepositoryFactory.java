package com.natasaku.app.di;

import com.natasaku.app.data.datastore.UserPreferenceDataStore;
import com.natasaku.app.domain.repository.SettingsRepository;
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
public final class AppModule_ProvideSettingsRepositoryFactory implements Factory<SettingsRepository> {
  private final Provider<UserPreferenceDataStore> storeProvider;

  public AppModule_ProvideSettingsRepositoryFactory(
      Provider<UserPreferenceDataStore> storeProvider) {
    this.storeProvider = storeProvider;
  }

  @Override
  public SettingsRepository get() {
    return provideSettingsRepository(storeProvider.get());
  }

  public static AppModule_ProvideSettingsRepositoryFactory create(
      Provider<UserPreferenceDataStore> storeProvider) {
    return new AppModule_ProvideSettingsRepositoryFactory(storeProvider);
  }

  public static SettingsRepository provideSettingsRepository(UserPreferenceDataStore store) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideSettingsRepository(store));
  }
}
