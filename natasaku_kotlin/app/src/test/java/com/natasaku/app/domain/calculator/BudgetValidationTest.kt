package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.ValidationError
import com.natasaku.app.domain.model.ValidationResult
import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Test

class BudgetValidationTest {
    @Test
    fun validatePeriod_invalidWhenEndBeforeStart() {
        val result = BudgetValidation.validatePeriod(
            startDate = LocalDate.of(2026, 6, 1),
            endDate = LocalDate.of(2026, 5, 31),
        )
        assertEquals(ValidationResult.Invalid(ValidationError.INVALID_PERIOD), result)
    }

    @Test
    fun validateAmount_invalidWhenZeroOrNegative() {
        assertEquals(
            ValidationResult.Invalid(ValidationError.INVALID_AMOUNT),
            BudgetValidation.validateAmount(0),
        )
        assertEquals(
            ValidationResult.Invalid(ValidationError.INVALID_AMOUNT),
            BudgetValidation.validateAmount(-1),
        )
    }
}
