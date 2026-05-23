package com.natasaku.app.di;

import com.natasaku.app.domain.calculator.BudgetCalculator;
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
public final class AppModule_ProvideBudgetCalculatorFactory implements Factory<BudgetCalculator> {
  @Override
  public BudgetCalculator get() {
    return provideBudgetCalculator();
  }

  public static AppModule_ProvideBudgetCalculatorFactory create() {
    return InstanceHolder.INSTANCE;
  }

  public static BudgetCalculator provideBudgetCalculator() {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideBudgetCalculator());
  }

  private static final class InstanceHolder {
    private static final AppModule_ProvideBudgetCalculatorFactory INSTANCE = new AppModule_ProvideBudgetCalculatorFactory();
  }
}
