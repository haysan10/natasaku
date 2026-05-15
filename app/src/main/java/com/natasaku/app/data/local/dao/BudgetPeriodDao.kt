package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface BudgetPeriodDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(period: BudgetPeriodEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(periods: List<BudgetPeriodEntity>)

    @Query("UPDATE budget_period SET isActive = 0")
    suspend fun clearActive()

    @Query("SELECT * FROM budget_period WHERE isActive = 1 LIMIT 1")
    fun observeActivePeriod(): Flow<BudgetPeriodEntity?>

    @Query("SELECT * FROM budget_period ORDER BY createdAt DESC")
    fun observeAll(): Flow<List<BudgetPeriodEntity>>
}
