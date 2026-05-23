package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.LeftoverAllocationType
import org.junit.Assert.assertEquals
import org.junit.Test

class LeftoverAllocationCalculatorTest {
    private val calculator = LeftoverAllocationCalculator()

    @Test
    fun autoSplitOddAmount_givesRemainderToTomorrow() {
        val result = calculator.allocate(remainingToday = 15_001L, type = LeftoverAllocationType.AUTO_SPLIT)

        assertEquals(7_501L, result.toNextDay)
        assertEquals(7_500L, result.toSaving)
        assertEquals(0L, result.toFreeBalance)
    }

    @Test
    fun addToSaving_assignsAllToSaving() {
        val result = calculator.allocate(remainingToday = 25_000L, type = LeftoverAllocationType.SAVING)

        assertEquals(25_000L, result.toSaving)
        assertEquals(0L, result.toNextDay)
    }

    @Test
    fun noAllocationWhenLeftoverNotPositive() {
        val result = calculator.allocate(remainingToday = 0L, type = LeftoverAllocationType.NEXT_DAY)

        assertEquals(0L, result.toSaving)
        assertEquals(0L, result.toNextDay)
        assertEquals(0L, result.toFreeBalance)
    }
}
