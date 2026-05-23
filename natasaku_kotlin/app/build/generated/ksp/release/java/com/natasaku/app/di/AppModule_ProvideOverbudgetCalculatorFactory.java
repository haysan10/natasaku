package com.natasaku.app.di;

import com.natasaku.app.domain.calculator.OverbudgetCalculator;
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
public final class AppModule_ProvideOverbudgetCalculatorFactory implements Factory<OverbudgetCalculator> {
  @Override
  public OverbudgetCalculator get() {
    return provideOverbudgetCalculator();
  }

  public static AppModule_ProvideOverbudgetCalculatorFactory create() {
    return InstanceHolder.INSTANCE;
  }

  public static OverbudgetCalculator provideOverbudgetCalculator() {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideOverbudgetCalculator());
  }

  private static final class InstanceHolder {
    private static final AppModule_ProvideOverbudgetCalculatorFactory INSTANCE = new AppModule_ProvideOverbudgetCalculatorFactory();
  }
}
