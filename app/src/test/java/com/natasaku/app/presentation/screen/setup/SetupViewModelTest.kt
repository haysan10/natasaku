package com.natasaku.app.presentation.screen.setup

import android.app.Application
import androidx.test.core.app.ApplicationProvider
import com.natasaku.app.domain.usecase.CompleteSetupUseCase
import java.time.LocalDate
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class SetupViewModelTest {

    @Test
    fun next_fromWelcome_movesToOnboarding() {
        val vm = createVm()
        vm.onEvent(SetupUiEvent.Next)
        assertEquals(SetupStep.ONBOARDING, vm.uiState.value.currentStep)
    }

    @Test
    fun invalid_period_blocks_advance() {
        val vm = createVm()
        vm.onEvent(SetupUiEvent.Next)
        vm.onEvent(SetupUiEvent.Next)
        vm.onEvent(SetupUiEvent.UpdatePeriodName("Mei"))
        vm.onEvent(SetupUiEvent.UpdateStartDate(LocalDate.of(2026, 5, 10)))
        vm.onEvent(SetupUiEvent.UpdateEndDate(LocalDate.of(2026, 5, 1)))
        vm.onEvent(SetupUiEvent.Next)
        assertTrue(vm.uiState.value.errorMessage?.isNotBlank() == true)
    }

    @Test
    fun review_is_recalculated_when_inputs_change() {
        val vm = createVm()
        vm.onEvent(SetupUiEvent.UpdateStartDate(LocalDate.of(2026, 5, 1)))
        vm.onEvent(SetupUiEvent.UpdateEndDate(LocalDate.of(2026, 5, 31)))
        vm.onEvent(SetupUiEvent.AddIncome("Gaji", 3_100_000))
        vm.onEvent(SetupUiEvent.AddFixedExpense("Kos", 620_000))
        vm.onEvent(SetupUiEvent.UpdateSavingTarget(310_000))
        assertEquals(2_170_000, vm.uiState.value.review.flexibleFund)
        assertEquals(70_000, vm.uiState.value.review.baseDailyAllowance)
    }

    @Test
    fun completeSetup_calls_usecase_when_valid() = runTest {
        var called = false
        val vm = createVm { called = true }
        vm.onEvent(SetupUiEvent.UpdatePeriodName("Mei"))
        vm.onEvent(SetupUiEvent.UpdateStartDate(LocalDate.of(2026, 5, 1)))
        vm.onEvent(SetupUiEvent.UpdateEndDate(LocalDate.of(2026, 5, 31)))
        vm.onEvent(SetupUiEvent.AddIncome("Gaji", 3_000_000))
        vm.completeSetup {}
        assertTrue(called)
    }

    private fun createVm(onComplete: () -> Unit = {}): SetupViewModel {
        val app = ApplicationProvider.getApplicationContext<Application>()
        val useCase = object : CompleteSetupUseCase {
            override suspend fun invoke(state: SetupUiState) = onComplete()
        }
        return SetupViewModel(
            budgetCalculator = com.natasaku.app.domain.calculator.BudgetCalculator(),
            dailyBudgetCalculator = com.natasaku.app.domain.calculator.DailyBudgetCalculator(),
            completeSetupUseCase = useCase,
        )
    }
}
