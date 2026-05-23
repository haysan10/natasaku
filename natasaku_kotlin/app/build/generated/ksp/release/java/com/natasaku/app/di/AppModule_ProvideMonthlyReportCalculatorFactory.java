package com.natasaku.app.di;

import com.natasaku.app.domain.calculator.MonthlyReportCalculator;
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
public final class AppModule_ProvideMonthlyReportCalculatorFactory implements Factory<MonthlyReportCalculator> {
  @Override
  public MonthlyReportCalculator get() {
    return provideMonthlyReportCalculator();
  }

  public static AppModule_ProvideMonthlyReportCalculatorFactory create() {
    return InstanceHolder.INSTANCE;
  }

  public static MonthlyReportCalculator provideMonthlyReportCalculator() {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideMonthlyReportCalculator());
  }

  private static final class InstanceHolder {
    private static final AppModule_ProvideMonthlyReportCalculatorFactory INSTANCE = new AppModule_ProvideMonthlyReportCalculatorFactory();
  }
}
