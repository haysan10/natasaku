package com.natasaku.app.domain.calculator

import org.junit.Assert.assertEquals
import org.junit.Test

class MonthlyReportCalculatorTest {
    private val calculator = MonthlyReportCalculator()

    @Test
    fun calculate_returnsExpectedSummaryMetrics() {
        val result = calculator.calculate(
            totalIncome = 10_000_000,
            totalExpense = 4_650_000,
            totalSaving = 2_000_000,
            periodDays = 31,
            overbudgetDays = 5,
        )

        assertEquals(3_350_000, result.endingBalance)
        assertEquals(150_000, result.averageDailyExpense)
        assertEquals(5, result.overbudgetDays)
    }
}
