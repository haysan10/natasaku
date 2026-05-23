package com.natasaku.app.di;

import android.content.Context;
import com.natasaku.app.reminder.ReminderScheduler;
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
public final class AppModule_ProvideReminderSchedulerFactory implements Factory<ReminderScheduler> {
  private final Provider<Context> contextProvider;

  public AppModule_ProvideReminderSchedulerFactory(Provider<Context> contextProvider) {
    this.contextProvider = contextProvider;
  }

  @Override
  public ReminderScheduler get() {
    return provideReminderScheduler(contextProvider.get());
  }

  public static AppModule_ProvideReminderSchedulerFactory create(
      Provider<Context> contextProvider) {
    return new AppModule_ProvideReminderSchedulerFactory(contextProvider);
  }

  public static ReminderScheduler provideReminderScheduler(Context context) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideReminderScheduler(context));
  }
}
