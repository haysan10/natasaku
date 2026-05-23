package com.natasaku.app.domain.model

data class MonthlyReportSummary(
    val totalIncome: Long,
    val totalExpense: Long,
    val totalSaving: Long,
    val endingBalance: Long,
    val averageDailyExpense: Long,
    val overbudgetDays: Int,
)
