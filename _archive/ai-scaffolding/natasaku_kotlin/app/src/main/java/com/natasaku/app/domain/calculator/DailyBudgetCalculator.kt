package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.domain.model.DailyBudgetSummary
import java.time.LocalDate
import java.time.temporal.ChronoUnit

class DailyBudgetCalculator {
    fun calculateBaseDailyAllowance(
        flexibleFund: Long,
        startDate: LocalDate,
        endDate: LocalDate,
    ): Long {
        val numberOfDays = ChronoUnit.DAYS.between(startDate, endDate).toInt() + 1
        if (numberOfDays <= 0) return 0L
        return maxOf(0L, flexibleFund) / numberOfDays
    }

    fun calculateDailySummary(
        finalDailyAllowance: Long,
        spentToday: Long,
    ): DailyBudgetSummary {
        val normalizedAllowance = maxOf(0L, finalDailyAllowance)
        val remainingToday = normalizedAllowance - spentToday
        val safeLimit = normalizedAllowance * 70
        val spentPercent = spentToday * 100
        val status = when {
            normalizedAllowance == 0L && spentToday == 0L -> BudgetStatus.SAFE
            normalizedAllowance == 0L && spentToday > 0L -> BudgetStatus.OVER_BUDGET
            spentPercent <= safeLimit -> BudgetStatus.SAFE
            spentToday <= normalizedAllowance -> BudgetStatus.WARNING
            else -> BudgetStatus.OVER_BUDGET
        }
        return DailyBudgetSummary(normalizedAllowance, spentToday, remainingToday, status)
    }
}
