package com.natasaku.app.di;

import android.content.Context;
import com.natasaku.app.data.datastore.UserPreferenceDataStore;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata("dagger.hilt.android.qualifiers.ApplicationContext")
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
public final class AppModule_ProvideUserPreferenceDataStoreFactory implements Factory<UserPreferenceDataStore> {
  private final Provider<Context> contextProvider;

  public AppModule_ProvideUserPreferenceDataStoreFactory(Provider<Context> contextProvider) {
    this.contextProvider = contextProvider;
  }

  @Override
  public UserPreferenceDataStore get() {
    return provideUserPreferenceDataStore(contextProvider.get());
  }

  public static AppModule_ProvideUserPreferenceDataStoreFactory create(
      Provider<Context> contextProvider) {
    return new AppModule_ProvideUserPreferenceDataStoreFactory(contextProvider);
  }

  public static UserPreferenceDataStore provideUserPreferenceDataStore(Context context) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideUserPreferenceDataStore(context));
  }
}
