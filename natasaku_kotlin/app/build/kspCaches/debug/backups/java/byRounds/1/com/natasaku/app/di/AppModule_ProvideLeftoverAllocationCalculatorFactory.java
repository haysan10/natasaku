package com.natasaku.app.di;

import com.natasaku.app.domain.calculator.LeftoverAllocationCalculator;
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
public final class AppModule_ProvideLeftoverAllocationCalculatorFactory implements Factory<LeftoverAllocationCalculator> {
  @Override
  public LeftoverAllocationCalculator get() {
    return provideLeftoverAllocationCalculator();
  }

  public static AppModule_ProvideLeftoverAllocationCalculatorFactory create() {
    return InstanceHolder.INSTANCE;
  }

  public static LeftoverAllocationCalculator provideLeftoverAllocationCalculator() {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideLeftoverAllocationCalculator());
  }

  private static final class InstanceHolder {
    private static final AppModule_ProvideLeftoverAllocationCalculatorFactory INSTANCE = new AppModule_ProvideLeftoverAllocationCalculatorFactory();
  }
}
