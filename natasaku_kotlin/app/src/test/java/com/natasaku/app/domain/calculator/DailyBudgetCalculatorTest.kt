package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.BudgetStatus
import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Test

class DailyBudgetCalculatorTest {
    private val calculator = DailyBudgetCalculator()

    @Test
    fun baseDailyAllowance_usesInclusiveDaysAndRoundsDown() {
        val value = calculator.calculateBaseDailyAllowance(
            flexibleFund = 1_000_000L,
            startDate = LocalDate.of(2026, 5, 1),
            endDate = LocalDate.of(2026, 5, 31),
        )

        assertEquals(32_258L, value)
    }

    @Test
    fun baseDailyAllowance_neverNegative() {
        val value = calculator.calculateBaseDailyAllowance(
            flexibleFund = -100_000L,
            startDate = LocalDate.of(2026, 5, 1),
            endDate = LocalDate.of(2026, 5, 31),
        )

        assertEquals(0L, value)
    }

    @Test
    fun statusRules_followSafeWarningOverBudgetThresholds() {
        val safe = calculator.calculateDailySummary(finalDailyAllowance = 100_000L, spentToday = 70_000L)
        val warning = calculator.calculateDailySummary(finalDailyAllowance = 100_000L, spentToday = 71_000L)
        val warningAtLimit = calculator.calculateDailySummary(finalDailyAllowance = 100_000L, spentToday = 100_000L)
        val over = calculator.calculateDailySummary(finalDailyAllowance = 100_000L, spentToday = 100_001L)

        assertEquals(BudgetStatus.SAFE, safe.status)
        assertEquals(BudgetStatus.WARNING, warning.status)
        assertEquals(BudgetStatus.WARNING, warningAtLimit.status)
        assertEquals(BudgetStatus.OVER_BUDGET, over.status)
    }

    @Test
    fun zeroAllowanceRules_matchSpec() {
        val safe = calculator.calculateDailySummary(finalDailyAllowance = 0L, spentToday = 0L)
        val over = calculator.calculateDailySummary(finalDailyAllowance = 0L, spentToday = 1L)

        assertEquals(BudgetStatus.SAFE, safe.status)
        assertEquals(BudgetStatus.OVER_BUDGET, over.status)
    }
}
