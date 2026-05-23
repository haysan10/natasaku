package com.natasaku.app.domain.validation

import java.time.LocalDate

object TransactionInputValidator {
    private const val MAX_NOTE_LENGTH = 200

    data class TransactionValidation(
        val blockingError: String? = null,
        val warning: String? = null,
    ) {
        val isValid: Boolean = blockingError == null
    }

    fun validateDate(
        transactionDate: LocalDate,
        today: LocalDate,
        activePeriodStartDate: LocalDate,
    ): TransactionValidation {
        if (transactionDate.isAfter(today)) {
            return TransactionValidation(blockingError = "Tanggal transaksi tidak boleh setelah hari ini")
        }
        if (transactionDate.isBefore(activePeriodStartDate)) {
            return TransactionValidation(blockingError = "Tanggal transaksi tidak boleh sebelum periode aktif")
        }
        return TransactionValidation()
    }

    fun validateCategory(category: String): TransactionValidation {
        return if (category.isBlank()) {
            TransactionValidation(blockingError = "Kategori wajib dipilih")
        } else {
            TransactionValidation()
        }
    }

    fun validateSingleExpenseAmount(amount: Long, flexibleFundTotal: Long): TransactionValidation {
        return if (amount > flexibleFundTotal) {
            TransactionValidation(warning = "Nominal transaksi melebihi dana fleksibel total. Kamu tetap bisa lanjut simpan.")
        } else {
            TransactionValidation()
        }
    }

    fun trimNoteToMaxLength(note: String): String = note.take(MAX_NOTE_LENGTH)

    fun noteCounter(note: String): String = "${note.length.coerceAtMost(MAX_NOTE_LENGTH)}/$MAX_NOTE_LENGTH"
}
