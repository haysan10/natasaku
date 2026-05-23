package com.natasaku.app.domain.validation

import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class TransactionInputValidatorTest {
    @Test
    fun futureDate_blocked() {
        val today = LocalDate.of(2026, 5, 23)
        val result = TransactionInputValidator.validateDate(
            transactionDate = today.plusDays(1),
            today = today,
            activePeriodStartDate = today.minusDays(10),
        )
        assertFalse(result.isValid)
    }

    @Test
    fun beforePeriodDate_blocked() {
        val today = LocalDate.of(2026, 5, 23)
        val result = TransactionInputValidator.validateDate(
            transactionDate = today.minusDays(30),
            today = today,
            activePeriodStartDate = today.minusDays(7),
        )
        assertFalse(result.isValid)
    }

    @Test
    fun blankCategory_blocked() {
        val result = TransactionInputValidator.validateCategory("")
        assertFalse(result.isValid)
        assertEquals("Kategori wajib dipilih", result.blockingError)
    }

    @Test
    fun overFlexibleFund_warnOnly() {
        val result = TransactionInputValidator.validateSingleExpenseAmount(
            amount = 500_000L,
            flexibleFundTotal = 200_000L,
        )
        assertTrue(result.isValid)
        assertTrue(result.warning?.contains("melebihi") == true)
    }

    @Test
    fun overFlexibleFund_warnsEvenWhenFlexibleIsZeroOrNegative() {
        val zeroFlexible = TransactionInputValidator.validateSingleExpenseAmount(
            amount = 10_000L,
            flexibleFundTotal = 0L,
        )
        val negativeFlexible = TransactionInputValidator.validateSingleExpenseAmount(
            amount = 10_000L,
            flexibleFundTotal = -5_000L,
        )
        assertTrue(zeroFlexible.isValid)
        assertTrue(negativeFlexible.isValid)
        assertTrue(zeroFlexible.warning?.contains("melebihi") == true)
        assertTrue(negativeFlexible.warning?.contains("melebihi") == true)
    }

    @Test
    fun noteLengthLimitedTo200() {
        val note = "a".repeat(250)
        val trimmed = TransactionInputValidator.trimNoteToMaxLength(note)
        assertEquals(200, trimmed.length)
        assertEquals("200/200", TransactionInputValidator.noteCounter(trimmed))
    }
}
