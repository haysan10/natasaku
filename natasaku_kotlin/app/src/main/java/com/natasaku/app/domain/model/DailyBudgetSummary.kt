package com.natasaku.app.domain.model

data class DailyBudgetSummary(
    val finalDailyAllowance: Long,
    val spentToday: Long,
    val remainingToday: Long,
    val status: BudgetStatus,
)
