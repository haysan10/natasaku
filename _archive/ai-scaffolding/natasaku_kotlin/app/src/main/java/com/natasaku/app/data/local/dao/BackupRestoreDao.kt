package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Query

@Dao
interface BackupRestoreDao {
    @Query("DELETE FROM scheduled_saving_execution") suspend fun clearScheduledSavingExecutions()
    @Query("DELETE FROM scheduled_payment_execution") suspend fun clearScheduledPaymentExecutions()
    @Query("DELETE FROM scheduled_saving") suspend fun clearScheduledSavings()
    @Query("DELETE FROM scheduled_payment") suspend fun clearScheduledPayments()
    @Query("DELETE FROM daily_budget_snapshot") suspend fun clearDailyBudgetSnapshots()
    @Query("DELETE FROM saving_allocation") suspend fun clearSavingAllocations()
    @Query("DELETE FROM saving_target") suspend fun clearSavingTargets()
    @Query("DELETE FROM expense_transaction") suspend fun clearExpenseTransactions()
    @Query("DELETE FROM fixed_expense") suspend fun clearFixedExpenses()
    @Query("DELETE FROM income_source") suspend fun clearIncomeSources()
    @Query("DELETE FROM budget_period") suspend fun clearBudgetPeriods()
}
