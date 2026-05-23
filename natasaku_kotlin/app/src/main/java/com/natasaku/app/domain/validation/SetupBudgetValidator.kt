package com.natasaku.app.domain.validation

import java.time.LocalDate
import java.time.temporal.ChronoUnit

object SetupBudgetValidator {
    data class SetupValidationResult(
        val blockingError: String? = null,
        val warning: String? = null,
    ) {
        val isValid: Boolean = blockingError == null
    }

    fun validatePeriod(startDate: LocalDate, endDate: LocalDate, today: LocalDate): SetupValidationResult {
        if (startDate.isBefore(today)) {
            return SetupValidationResult(blockingError = "Tanggal mulai periode harus hari ini atau setelahnya")
        }
        if (startDate == endDate) {
            return SetupValidationResult(blockingError = "Periode minimal 1 hari")
        }
        if (endDate.isBefore(startDate)) {
            return SetupValidationResult(blockingError = "Tanggal akhir tidak valid")
        }
        val totalDays = ChronoUnit.DAYS.between(startDate, endDate) + 1
        if (totalDays > 365) {
            return SetupValidationResult(
                warning = "Periode sangat panjang. Yakin lanjutkan?",
            )
        }
        return SetupValidationResult()
    }

    fun validateIncome(totalIncome: Long): SetupValidationResult {
        if (totalIncome <= 0L) {
            return SetupValidationResult(blockingError = "Total penghasilan wajib lebih dari Rp 0")
        }
        return SetupValidationResult()
    }

    fun validateFlexibleFund(totalIncome: Long, totalFixedExpense: Long, savingTarget: Long): SetupValidationResult {
        return if (totalIncome < totalFixedExpense + savingTarget) {
            SetupValidationResult(
                warning = "Dana fleksibel kamu negatif. Kamu bisa lanjutkan dan menyesuaikan nanti, atau kurangi pengeluaran tetap.",
            )
        } else {
            SetupValidationResult()
        }
    }

    fun defaultFixedExpenseName(inputName: String, fallbackCategory: String): String {
        return inputName.trim().ifBlank { fallbackCategory.trim().ifBlank { "Lainnya" } }
    }
}
