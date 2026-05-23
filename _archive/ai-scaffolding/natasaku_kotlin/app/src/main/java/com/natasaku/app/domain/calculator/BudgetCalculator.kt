package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.BudgetSummary

class BudgetCalculator {
    fun totalIncome(amounts: List<Long>): Long = amounts.sum()

    fun totalFixedExpense(amounts: List<Long>): Long = amounts.sum()

    fun totalSavingTarget(amounts: List<Long>): Long = amounts.sum()

    fun flexibleFund(
        totalIncome: Long,
        totalFixedExpense: Long,
        totalSavingTarget: Long,
    ): Long = totalIncome - totalFixedExpense - totalSavingTarget

    fun calculate(
        totalBudget: Long,
        committedAmount: Long,
        actualSpent: Long,
    ): BudgetSummary {
        val availableBalance = totalBudget - committedAmount - actualSpent
        return BudgetSummary(
            totalBudget = totalBudget,
            committedAmount = committedAmount,
            actualSpent = actualSpent,
            availableBalance = availableBalance,
        )
    }
}
