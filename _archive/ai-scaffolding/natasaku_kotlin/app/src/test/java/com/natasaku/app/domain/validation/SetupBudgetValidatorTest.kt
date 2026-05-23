package com.natasaku.app.domain.validation

import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SetupBudgetValidatorTest {
    @Test
    fun incomeMustBePositive() {
        val result = SetupBudgetValidator.validateIncome(0)
        assertFalse(result.isValid)
        assertEquals("Total penghasilan wajib lebih dari Rp 0", result.blockingError)
    }

    @Test
    fun equalStartEndDate_blocked() {
        val today = LocalDate.of(2026, 5, 23)
        val result = SetupBudgetValidator.validatePeriod(today, today, today)
        assertFalse(result.isValid)
        assertEquals("Periode minimal 1 hari", result.blockingError)
    }

    @Test
    fun endBeforeStart_blocked() {
        val today = LocalDate.of(2026, 5, 23)
        val result = SetupBudgetValidator.validatePeriod(today.plusDays(2), today.plusDays(1), today)
        assertFalse(result.isValid)
        assertEquals("Tanggal akhir tidak valid", result.blockingError)
    }

    @Test
    fun longPeriod_warned() {
        val today = LocalDate.of(2026, 5, 23)
        val result = SetupBudgetValidator.validatePeriod(today, today.plusDays(400), today)
        assertTrue(result.isValid)
        assertEquals("Periode sangat panjang. Yakin lanjutkan?", result.warning)
    }

    @Test
    fun negativeFlexibleFund_warned() {
        val result = SetupBudgetValidator.validateFlexibleFund(
            totalIncome = 1_000_000L,
            totalFixedExpense = 900_000L,
            savingTarget = 200_000L,
        )
        assertTrue(result.isValid)
        assertTrue(result.warning?.contains("negatif") == true)
    }

    @Test
    fun startDateInPast_blocked() {
        val today = LocalDate.of(2026, 5, 23)
        val result = SetupBudgetValidator.validatePeriod(
            startDate = today.minusDays(1),
            endDate = today.plusDays(30),
            today = today,
        )
        assertFalse(result.isValid)
        assertEquals("Tanggal mulai periode harus hari ini atau setelahnya", result.blockingError)
    }

    @Test
    fun fixedExpenseNameDefaultsToFallbackWhenBlank() {
        val name = SetupBudgetValidator.defaultFixedExpenseName("", "Kos")
        assertEquals("Kos", name)
    }
}
