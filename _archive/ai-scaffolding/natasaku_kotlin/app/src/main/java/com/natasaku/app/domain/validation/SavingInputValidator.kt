package com.natasaku.app.domain.validation

import java.time.LocalDate

object SavingInputValidator {
    data class SavingValidation(
        val blockingError: String? = null,
        val warning: String? = null,
    ) {
        val isValid: Boolean = blockingError == null
    }

    fun validateTarget(target: Long, totalIncome: Long): SavingValidation {
        if (target == 0L) {
            return SavingValidation()
        }
        return if (target > totalIncome) {
            SavingValidation(warning = "Target tabungan melebihi penghasilan. Pastikan ini sesuai rencanamu.")
        } else {
            SavingValidation()
        }
    }

    fun validateLeftoverAllocation(allocationAmount: Long, remainingDailyAllowance: Long): SavingValidation {
        return if (allocationAmount > remainingDailyAllowance) {
            SavingValidation(warning = "Nominal alokasi lebih besar dari sisa jatah hari ini. Kamu tetap bisa lanjut.")
        } else {
            SavingValidation()
        }
    }

    fun validateDuplicateDailyAllocation(existingAllocationDates: Set<LocalDate>, date: LocalDate): SavingValidation {
        return if (date in existingAllocationDates) {
            SavingValidation(blockingError = "Kamu sudah mengalokasikan tabungan hari ini")
        } else {
            SavingValidation()
        }
    }
}
