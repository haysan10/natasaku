package com.natasaku.app.domain.validation

import com.natasaku.app.core.money.RupiahFormatter

object NominalInputValidator {
    const val MAX_AMOUNT: Long = 999_999_999_999L

    data class NominalValidation(
        val rawDigits: String,
        val normalizedDigits: String,
        val amount: Long,
        val isEmpty: Boolean,
        val isValid: Boolean,
        val errorMessage: String? = null,
    )

    fun sanitizeRawInput(input: String): String = input.filter(Char::isDigit)

    fun normalizeDigits(digits: String): String {
        val cleaned = sanitizeRawInput(digits)
        if (cleaned.isEmpty()) return ""
        return cleaned.trimStart('0').ifBlank { "0" }
    }

    fun validate(input: String): NominalValidation {
        if (input.contains('-')) {
            return NominalValidation(
                rawDigits = sanitizeRawInput(input),
                normalizedDigits = "",
                amount = 0L,
                isEmpty = false,
                isValid = false,
                errorMessage = "Nominal harus lebih dari Rp 0",
            )
        }

        val rawDigits = sanitizeRawInput(input)
        val normalized = normalizeDigits(rawDigits)

        if (rawDigits.isEmpty()) {
            return NominalValidation(
                rawDigits = "",
                normalizedDigits = "",
                amount = 0L,
                isEmpty = true,
                isValid = false,
            )
        }

        val amount = normalized.toLongOrNull() ?: Long.MAX_VALUE
        if (amount <= 0L) {
            return NominalValidation(
                rawDigits = rawDigits,
                normalizedDigits = "0",
                amount = 0L,
                isEmpty = false,
                isValid = false,
                errorMessage = "Nominal harus lebih dari Rp 0",
            )
        }

        if (amount > MAX_AMOUNT) {
            return NominalValidation(
                rawDigits = rawDigits,
                normalizedDigits = normalized,
                amount = amount,
                isEmpty = false,
                isValid = false,
                errorMessage = "Nominal terlalu besar. Maksimum Rp 999.999.999.999",
            )
        }

        return NominalValidation(
            rawDigits = rawDigits,
            normalizedDigits = normalized,
            amount = amount,
            isEmpty = false,
            isValid = true,
        )
    }

    fun formatDisplay(input: String): String {
        val validation = validate(input)
        if (validation.isEmpty) return ""
        return RupiahFormatter().format(validation.amount)
    }
}
