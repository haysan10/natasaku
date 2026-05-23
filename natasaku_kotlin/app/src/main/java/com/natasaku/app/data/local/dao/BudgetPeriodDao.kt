package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import java.time.LocalDate
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

    @Query("SELECT * FROM budget_period WHERE id = :id LIMIT 1")
    suspend fun getById(id: String): BudgetPeriodEntity?

    @Query("UPDATE budget_period SET isActive = 0 WHERE isActive = 1 AND endDate < :today")
    suspend fun deactivateExpiredActivePeriod(today: LocalDate)
}
