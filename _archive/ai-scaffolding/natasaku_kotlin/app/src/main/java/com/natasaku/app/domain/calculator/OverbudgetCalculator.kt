package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.OverbudgetAdjustment
import java.time.LocalDate
import java.time.temporal.ChronoUnit

class OverbudgetCalculator {
    fun remainingDaysForAdjustment(
        today: LocalDate,
        periodEndDate: LocalDate,
    ): Int {
        if (!today.isBefore(periodEndDate)) return 0
        return ChronoUnit.DAYS.between(today.plusDays(1), periodEndDate).toInt() + 1
    }

    fun calculate(
        finalDailyAllowance: Long,
        spentToday: Long,
        remainingDays: Int,
    ): OverbudgetAdjustment {
        val overbudgetAmount = (spentToday - finalDailyAllowance).coerceAtLeast(0L)
        val adjustmentPerDay = if (remainingDays <= 0) 0L else overbudgetAmount / remainingDays
        return OverbudgetAdjustment(
            overbudgetAmount = overbudgetAmount,
            remainingDays = remainingDays.coerceAtLeast(0),
            adjustmentPerDay = adjustmentPerDay,
        )
    }
}
