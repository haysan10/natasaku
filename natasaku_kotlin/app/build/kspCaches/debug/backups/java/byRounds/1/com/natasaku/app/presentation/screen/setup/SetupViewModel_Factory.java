package com.natasaku.app.presentation.screen.setup;

import com.natasaku.app.domain.calculator.BudgetCalculator;
import com.natasaku.app.domain.calculator.DailyBudgetCalculator;
import com.natasaku.app.domain.usecase.CompleteSetupUseCase;
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
public final class SetupViewModel_Factory implements Factory<SetupViewModel> {
  private final Provider<BudgetCalculator> budgetCalculatorProvider;

  private final Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider;

  private final Provider<CompleteSetupUseCase> completeSetupUseCaseProvider;

  public SetupViewModel_Factory(Provider<BudgetCalculator> budgetCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<CompleteSetupUseCase> completeSetupUseCaseProvider) {
    this.budgetCalculatorProvider = budgetCalculatorProvider;
    this.dailyBudgetCalculatorProvider = dailyBudgetCalculatorProvider;
    this.completeSetupUseCaseProvider = completeSetupUseCaseProvider;
  }

  @Override
  public SetupViewModel get() {
    return newInstance(budgetCalculatorProvider.get(), dailyBudgetCalculatorProvider.get(), completeSetupUseCaseProvider.get());
  }

  public static SetupViewModel_Factory create(Provider<BudgetCalculator> budgetCalculatorProvider,
      Provider<DailyBudgetCalculator> dailyBudgetCalculatorProvider,
      Provider<CompleteSetupUseCase> completeSetupUseCaseProvider) {
    return new SetupViewModel_Factory(budgetCalculatorProvider, dailyBudgetCalculatorProvider, completeSetupUseCaseProvider);
  }

  public static SetupViewModel newInstance(BudgetCalculator budgetCalculator,
      DailyBudgetCalculator dailyBudgetCalculator, CompleteSetupUseCase completeSetupUseCase) {
    return new SetupViewModel(budgetCalculator, dailyBudgetCalculator, completeSetupUseCase);
  }
}
