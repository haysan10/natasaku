package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Query

@Dao
interface BackupRestoreDao {
    @Query("DELETE FROM daily_budget_snapshot") suspend fun clearDailyBudgetSnapshots()
    @Query("DELETE FROM saving_allocation") suspend fun clearSavingAllocations()
    @Query("DELETE FROM saving_target") suspend fun clearSavingTargets()
    @Query("DELETE FROM expense_transaction") suspend fun clearExpenseTransactions()
    @Query("DELETE FROM fixed_expense") suspend fun clearFixedExpenses()
    @Query("DELETE FROM income_source") suspend fun clearIncomeSources()
    @Query("DELETE FROM budget_period") suspend fun clearBudgetPeriods()
}
