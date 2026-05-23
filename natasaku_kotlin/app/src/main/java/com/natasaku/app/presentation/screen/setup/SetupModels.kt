package com.natasaku.app.presentation.screen.setup

import java.time.LocalDate

enum class SetupStep {
    WELCOME,
    ONBOARDING,
    PERIOD,
    INCOME,
    FIXED_EXPENSE,
    SAVING,
    REVIEW,
}

data class SetupItemInput(
    val id: String,
    val name: String,
    val amount: Long,
)

data class ReviewBudgetUiModel(
    val totalIncome: Long = 0L,
    val totalFixedExpense: Long = 0L,
    val totalSavingTarget: Long = 0L,
    val flexibleFund: Long = 0L,
    val baseDailyAllowance: Long = 0L,
)

data class SetupUiState(
    val currentStep: SetupStep = SetupStep.WELCOME,
    val periodName: String = "",
    val startDate: LocalDate? = LocalDate.now(),
    val endDate: LocalDate? = LocalDate.now().plusDays(30),
    val incomes: List<SetupItemInput> = emptyList(),
    val fixedExpenses: List<SetupItemInput> = emptyList(),
    val savingTarget: Long = 0L,
    val canSkipSaving: Boolean = true,
    val review: ReviewBudgetUiModel = ReviewBudgetUiModel(),
    val errorMessage: String? = null,
    val warningMessage: String? = null,
    val isSaving: Boolean = false,
)

sealed interface SetupUiEvent {
    data class SetStep(val step: SetupStep) : SetupUiEvent
    data object Next : SetupUiEvent
    data object Back : SetupUiEvent
    data class UpdatePeriodName(val value: String) : SetupUiEvent
    data class UpdateStartDate(val value: LocalDate) : SetupUiEvent
    data class UpdateEndDate(val value: LocalDate) : SetupUiEvent
    data class AddIncome(val name: String, val amount: Long) : SetupUiEvent
    data class RemoveIncome(val id: String) : SetupUiEvent
    data class AddFixedExpense(val name: String, val amount: Long) : SetupUiEvent
    data class RemoveFixedExpense(val id: String) : SetupUiEvent
    data class UpdateSavingTarget(val amount: Long) : SetupUiEvent
}
