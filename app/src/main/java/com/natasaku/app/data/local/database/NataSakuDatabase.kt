package com.natasaku.app.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.BackupRestoreDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.data.local.entity.FixedExpenseEntity
import com.natasaku.app.data.local.entity.IncomeSourceEntity
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.data.local.entity.SavingTargetEntity

@Database(
    entities = [
        BudgetPeriodEntity::class,
        IncomeSourceEntity::class,
        FixedExpenseEntity::class,
        ExpenseTransactionEntity::class,
        SavingTargetEntity::class,
        SavingAllocationEntity::class,
        DailyBudgetSnapshotEntity::class,
    ],
    version = 2,
    exportSchema = false,
)
@TypeConverters(RoomConverters::class)
abstract class NataSakuDatabase : RoomDatabase() {
    abstract fun budgetPeriodDao(): BudgetPeriodDao
    abstract fun incomeSourceDao(): IncomeSourceDao
    abstract fun fixedExpenseDao(): FixedExpenseDao
    abstract fun expenseTransactionDao(): ExpenseTransactionDao
    abstract fun savingTargetDao(): SavingTargetDao
    abstract fun savingAllocationDao(): SavingAllocationDao
    abstract fun dailyBudgetSnapshotDao(): DailyBudgetSnapshotDao
    abstract fun backupRestoreDao(): BackupRestoreDao
}
