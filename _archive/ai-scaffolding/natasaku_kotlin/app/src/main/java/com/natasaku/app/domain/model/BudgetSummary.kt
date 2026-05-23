package com.natasaku.app.domain.model

data class BudgetSummary(
    val totalBudget: Long,
    val committedAmount: Long,
    val actualSpent: Long,
    val availableBalance: Long,
)
