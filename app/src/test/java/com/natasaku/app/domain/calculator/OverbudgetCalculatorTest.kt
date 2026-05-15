package com.natasaku.app.domain.calculator

import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Test

class OverbudgetCalculatorTest {
    private val calculator = OverbudgetCalculator()

    @Test
    fun adjustmentIsSpreadAcrossRemainingDays() {
        val adjustment = calculator.calculate(
            finalDailyAllowance = 100_000L,
            spentToday = 160_000L,
            remainingDays = 3,
        )

        assertEquals(60_000L, adjustment.overbudgetAmount)
        assertEquals(20_000L, adjustment.adjustmentPerDay)
    }

    @Test
    fun noFutureAdjustmentOnFinalDay() {
        val remainingDays = calculator.remainingDaysForAdjustment(
            today = LocalDate.of(2026, 5, 31),
            periodEndDate = LocalDate.of(2026, 5, 31),
        )
        val adjustment = calculator.calculate(
            finalDailyAllowance = 100_000L,
            spentToday = 130_000L,
            remainingDays = remainingDays,
        )

        assertEquals(0, remainingDays)
        assertEquals(0L, adjustment.adjustmentPerDay)
    }
}
