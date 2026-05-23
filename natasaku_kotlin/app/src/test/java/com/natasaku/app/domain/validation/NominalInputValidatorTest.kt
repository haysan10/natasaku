package com.natasaku.app.domain.validation

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NominalInputValidatorTest {
    @Test
    fun nominalZero_blocked() {
        val result = NominalInputValidator.validate("0")
        assertFalse(result.isValid)
        assertEquals("Nominal harus lebih dari Rp 0", result.errorMessage)
    }

    @Test
    fun nominalEmpty_blocked() {
        val result = NominalInputValidator.validate("")
        assertTrue(result.isEmpty)
        assertFalse(result.isValid)
    }

    @Test
    fun stripNonDigit_forDotAndComma() {
        assertEquals("4000000", NominalInputValidator.sanitizeRawInput("4.000.000"))
        assertEquals("4000000", NominalInputValidator.sanitizeRawInput("4,000,000"))
    }

    @Test
    fun leadingZeros_areNormalized() {
        val result = NominalInputValidator.validate("007000")
        assertTrue(result.isValid)
        assertEquals("7000", result.normalizedDigits)
        assertEquals(7_000L, result.amount)
    }

    @Test
    fun maxNominalExceeded_blocked() {
        val result = NominalInputValidator.validate("1000000000000")
        assertFalse(result.isValid)
        assertEquals("Nominal terlalu besar. Maksimum Rp 999.999.999.999", result.errorMessage)
    }

    @Test
    fun formatDisplay_formatsRupiah() {
        val display = NominalInputValidator.formatDisplay("4000000")
        assertEquals("Rp 4.000.000", display)
    }

    @Test
    fun negativeInput_blocked() {
        val result = NominalInputValidator.validate("-5000")
        assertFalse(result.isValid)
        assertEquals("Nominal harus lebih dari Rp 0", result.errorMessage)
    }
}
