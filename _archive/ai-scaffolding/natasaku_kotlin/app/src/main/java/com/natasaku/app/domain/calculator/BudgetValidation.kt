package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.ValidationError
import com.natasaku.app.domain.model.ValidationResult
import java.time.LocalDate

object BudgetValidation {
    fun validatePeriod(startDate: LocalDate, endDate: LocalDate): ValidationResult {
        return if (endDate.isBefore(startDate)) {
            ValidationResult.Invalid(ValidationError.INVALID_PERIOD)
        } else {
            ValidationResult.Valid
        }
    }

    fun validateAmount(amount: Long): ValidationResult {
        return if (amount > 0L) {
            ValidationResult.Valid
        } else {
            ValidationResult.Invalid(ValidationError.INVALID_AMOUNT)
        }
    }
}
