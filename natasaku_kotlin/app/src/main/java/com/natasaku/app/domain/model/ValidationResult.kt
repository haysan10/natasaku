package com.natasaku.app.domain.model

sealed interface ValidationResult {
    data object Valid : ValidationResult
    data class Invalid(val error: ValidationError) : ValidationResult
}
