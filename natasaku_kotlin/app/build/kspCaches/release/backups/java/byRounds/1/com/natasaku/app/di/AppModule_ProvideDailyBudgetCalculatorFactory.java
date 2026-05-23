package com.natasaku.app.di;

import com.natasaku.app.domain.calculator.DailyBudgetCalculator;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;

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
public final class AppModule_ProvideDailyBudgetCalculatorFactory implements Factory<DailyBudgetCalculator> {
  @Override
  public DailyBudgetCalculator get() {
    return provideDailyBudgetCalculator();
  }

  public static AppModule_ProvideDailyBudgetCalculatorFactory create() {
    return InstanceHolder.INSTANCE;
  }

  public static DailyBudgetCalculator provideDailyBudgetCalculator() {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideDailyBudgetCalculator());
  }

  private static final class InstanceHolder {
    private static final AppModule_ProvideDailyBudgetCalculatorFactory INSTANCE = new AppModule_ProvideDailyBudgetCalculatorFactory();
  }
}
