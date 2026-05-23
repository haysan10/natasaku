package com.natasaku.app.presentation.screen.setup

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.domain.calculator.BudgetCalculator
import com.natasaku.app.domain.calculator.DailyBudgetCalculator
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.domain.validation.SavingInputValidator
import com.natasaku.app.domain.validation.SetupBudgetValidator
import java.time.LocalDate
import com.natasaku.app.domain.usecase.CompleteSetupUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import java.util.UUID
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class SetupViewModel @Inject constructor(
    private val budgetCalculator: BudgetCalculator,
    private val dailyBudgetCalculator: DailyBudgetCalculator,
    private val completeSetupUseCase: CompleteSetupUseCase,
) : ViewModel() {
    private val _uiState = MutableStateFlow(SetupUiState())
    val uiState: StateFlow<SetupUiState> = _uiState.asStateFlow()

    fun onEvent(event: SetupUiEvent) {
        when (event) {
            is SetupUiEvent.SetStep -> _uiState.update { it.copy(currentStep = event.step, errorMessage = null, warningMessage = null) }
            SetupUiEvent.Back -> moveBack()
            SetupUiEvent.Next -> moveNext()
            is SetupUiEvent.UpdatePeriodName -> _uiState.update { it.copy(periodName = event.value, errorMessage = null, warningMessage = null) }
            is SetupUiEvent.UpdateStartDate -> _uiState.update { it.copy(startDate = event.value, errorMessage = null, warningMessage = null) }
            is SetupUiEvent.UpdateEndDate -> _uiState.update { it.copy(endDate = event.value, errorMessage = null, warningMessage = null) }
            is SetupUiEvent.AddIncome -> addIncome(event.name, event.amount)
            is SetupUiEvent.RemoveIncome -> _uiState.update { it.copy(incomes = it.incomes.filterNot { item -> item.id == event.id }) }
            is SetupUiEvent.AddFixedExpense -> addFixedExpense(event.name, event.amount)
            is SetupUiEvent.RemoveFixedExpense -> _uiState.update { it.copy(fixedExpenses = it.fixedExpenses.filterNot { item -> item.id == event.id }) }
            is SetupUiEvent.UpdateSavingTarget -> _uiState.update { it.copy(savingTarget = event.amount.coerceAtLeast(0L), errorMessage = null, warningMessage = null) }
        }
        recalculateReview()
    }

    fun completeSetup(onDone: () -> Unit) {
        val state = _uiState.value
        if (state.startDate == null || state.endDate == null || state.periodName.isBlank()) {
            _uiState.update { it.copy(errorMessage = "Periode belum lengkap.", warningMessage = null) }; return
        }
        val incomeValidation = SetupBudgetValidator.validateIncome(state.incomes.sumOf { it.amount })
        if (!incomeValidation.isValid) {
            _uiState.update { it.copy(errorMessage = incomeValidation.blockingError, warningMessage = null) }; return
        }
        viewModelScope.launch {
            _uiState.update { it.copy(isSaving = true, errorMessage = null) }
            runCatching { completeSetupUseCase(state) }
                .onSuccess { onDone() }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isSaving = false,
                            errorMessage = error.localizedMessage ?: "Setup belum berhasil disimpan. Coba lagi.",
                        )
                    }
                }
            _uiState.update { it.copy(isSaving = false) }
        }
    }

    private fun moveNext() { val s = _uiState.value; when (s.currentStep) {
        SetupStep.WELCOME -> _uiState.update { it.copy(currentStep = SetupStep.ONBOARDING, errorMessage = null) }
        SetupStep.ONBOARDING -> _uiState.update { it.copy(currentStep = SetupStep.PERIOD, errorMessage = null) }
        SetupStep.PERIOD -> validatePeriodAndAdvance()
        SetupStep.INCOME -> validateIncomeAndAdvance()
        SetupStep.FIXED_EXPENSE -> _uiState.update { it.copy(currentStep = SetupStep.SAVING, errorMessage = null, warningMessage = null) }
        SetupStep.SAVING -> validateSavingAndAdvance()
        SetupStep.REVIEW -> Unit } }
    private fun moveBack() { _uiState.update { it.copy(currentStep = when (it.currentStep) {
        SetupStep.WELCOME -> SetupStep.WELCOME
        SetupStep.ONBOARDING -> SetupStep.WELCOME
        SetupStep.PERIOD -> SetupStep.ONBOARDING
        SetupStep.INCOME -> SetupStep.PERIOD
        SetupStep.FIXED_EXPENSE -> SetupStep.INCOME
        SetupStep.SAVING -> SetupStep.FIXED_EXPENSE
        SetupStep.REVIEW -> SetupStep.SAVING }, errorMessage = null, warningMessage = null) } }

    private fun validatePeriodAndAdvance() {
        val s = _uiState.value; val start = s.startDate; val end = s.endDate
        if (s.periodName.isBlank() || start == null || end == null) {
            _uiState.update { it.copy(errorMessage = "Lengkapi nama dan tanggal periode dulu, ya.", warningMessage = null) }
            return
        }
        val validation = SetupBudgetValidator.validatePeriod(
            startDate = start,
            endDate = end,
            today = LocalDate.now(),
        )
        if (!validation.isValid) {
            _uiState.update { it.copy(errorMessage = validation.blockingError, warningMessage = null) }
            return
        }
        _uiState.update {
            it.copy(
                currentStep = SetupStep.INCOME,
                errorMessage = null,
                warningMessage = validation.warning,
            )
        }
    }
    private fun validateIncomeAndAdvance() {
        val validation = SetupBudgetValidator.validateIncome(_uiState.value.incomes.sumOf { it.amount })
        if (!validation.isValid) {
            _uiState.update { it.copy(errorMessage = validation.blockingError, warningMessage = null) }
            return
        }
        _uiState.update { it.copy(currentStep = SetupStep.FIXED_EXPENSE, errorMessage = null, warningMessage = null) }
    }
    private fun addIncome(name: String, amount: Long) {
        val nominalValidation = NominalInputValidator.validate(amount.toString())
        if (name.isBlank() || !nominalValidation.isValid) {
            _uiState.update { it.copy(errorMessage = nominalValidation.errorMessage ?: "Nominal penghasilan belum valid.", warningMessage = null) }
            return
        }
        _uiState.update {
            it.copy(
                incomes = it.incomes + SetupItemInput(UUID.randomUUID().toString(), name.trim(), nominalValidation.amount),
                errorMessage = null,
                warningMessage = null,
            )
        }
    }
    private fun addFixedExpense(name: String, amount: Long) {
        val nominalValidation = NominalInputValidator.validate(amount.toString())
        if (!nominalValidation.isValid) {
            _uiState.update {
                it.copy(
                    errorMessage = nominalValidation.errorMessage ?: "Nominal pengeluaran tetap belum valid.",
                    warningMessage = null,
                )
            }
            return
        }
        val finalName = SetupBudgetValidator.defaultFixedExpenseName(name, "Pengeluaran tetap")
        _uiState.update {
            it.copy(
                fixedExpenses = it.fixedExpenses + SetupItemInput(UUID.randomUUID().toString(), finalName, nominalValidation.amount),
                errorMessage = null,
                warningMessage = null,
            )
        }
    }

    private fun validateSavingAndAdvance() {
        val state = _uiState.value
        val totalIncome = state.incomes.sumOf { it.amount }
        val validation = SavingInputValidator.validateTarget(state.savingTarget, totalIncome)
        _uiState.update {
            it.copy(
                currentStep = SetupStep.REVIEW,
                errorMessage = null,
                warningMessage = validation.warning,
            )
        }
    }
    private fun recalculateReview() {
        val s = _uiState.value; val start = s.startDate ?: return; val end = s.endDate ?: return
        val totalIncome = s.incomes.sumOf { it.amount }
        val totalFixedExpense = s.fixedExpenses.sumOf { it.amount }
        val totalSaving = s.savingTarget
        val flexibleFund = budgetCalculator.flexibleFund(
            totalIncome = totalIncome,
            totalFixedExpense = totalFixedExpense,
            totalSavingTarget = totalSaving,
        )
        val daily = dailyBudgetCalculator.calculateBaseDailyAllowance(flexibleFund, start, end)
        val flexibleWarning = SetupBudgetValidator.validateFlexibleFund(
            totalIncome = totalIncome,
            totalFixedExpense = totalFixedExpense,
            savingTarget = totalSaving,
        ).warning
        _uiState.update {
            it.copy(
                review = ReviewBudgetUiModel(
                    totalIncome,
                    totalFixedExpense,
                    totalSaving,
                    flexibleFund,
                    daily,
                ),
                warningMessage = flexibleWarning ?: it.warningMessage,
            )
        }
    }
}
