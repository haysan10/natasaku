package com.natasaku.app.domain.calculator

import org.junit.Assert.assertEquals
import org.junit.Test

class BudgetCalculatorTest {
    private val calculator = BudgetCalculator()

    @Test
    fun totalsAndFlexibleFund_areCalculatedFromAllInputs() {
        val totalIncome = calculator.totalIncome(listOf(3_000_000L, 1_000_000L))
        val totalFixed = calculator.totalFixedExpense(listOf(1_200_000L, 300_000L))
        val totalSaving = calculator.totalSavingTarget(listOf(400_000L, 100_000L))

        assertEquals(4_000_000L, totalIncome)
        assertEquals(1_500_000L, totalFixed)
        assertEquals(500_000L, totalSaving)
        assertEquals(2_000_000L, calculator.flexibleFund(totalIncome, totalFixed, totalSaving))
    }

    @Test
    fun flexibleFund_canBeNegative() {
        val result = calculator.flexibleFund(
            totalIncome = 1_000_000L,
            totalFixedExpense = 1_300_000L,
            totalSavingTarget = 200_000L,
        )

        assertEquals(-500_000L, result)
    }
}
