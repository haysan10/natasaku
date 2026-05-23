package com.natasaku.app.domain.validation

import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SavingInputValidatorTest {
    @Test
    fun zeroTarget_allowed() {
        val result = SavingInputValidator.validateTarget(0, totalIncome = 1_000_000)
        assertTrue(result.isValid)
    }

    @Test
    fun targetAboveIncome_warned() {
        val result = SavingInputValidator.validateTarget(2_000_000, totalIncome = 1_000_000)
        assertTrue(result.isValid)
        assertTrue(result.warning?.contains("melebihi penghasilan") == true)
    }

    @Test
    fun duplicateDailyAllocation_blocked() {
        val today = LocalDate.of(2026, 5, 23)
        val result = SavingInputValidator.validateDuplicateDailyAllocation(setOf(today), today)
        assertFalse(result.isValid)
        assertEquals("Kamu sudah mengalokasikan tabungan hari ini", result.blockingError)
    }

    @Test
    fun allocationOverRemaining_warnOnly() {
        val result = SavingInputValidator.validateLeftoverAllocation(
            allocationAmount = 50_000L,
            remainingDailyAllowance = 20_000L,
        )
        assertTrue(result.isValid)
        assertTrue(result.warning?.contains("lebih besar") == true)
    }
}
