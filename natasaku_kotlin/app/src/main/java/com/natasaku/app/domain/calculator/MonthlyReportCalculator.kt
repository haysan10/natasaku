package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.MonthlyReportSummary

class MonthlyReportCalculator {
    fun calculate(
        totalIncome: Long,
        totalExpense: Long,
        totalSaving: Long,
        periodDays: Int,
        overbudgetDays: Int,
    ): MonthlyReportSummary {
        val endingBalance = totalIncome - totalExpense - totalSaving
        val averageDailyExpense = if (periodDays <= 0) 0L else totalExpense / periodDays
        return MonthlyReportSummary(
            totalIncome = totalIncome,
            totalExpense = totalExpense,
            totalSaving = totalSaving,
            endingBalance = endingBalance,
            averageDailyExpense = averageDailyExpense,
            overbudgetDays = overbudgetDays.coerceAtLeast(0),
        )
    }
}
