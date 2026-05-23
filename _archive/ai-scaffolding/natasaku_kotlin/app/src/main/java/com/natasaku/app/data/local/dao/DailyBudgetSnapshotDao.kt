package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity
import java.time.LocalDate
import kotlinx.coroutines.flow.Flow

@Dao
interface DailyBudgetSnapshotDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(snapshot: DailyBudgetSnapshotEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<DailyBudgetSnapshotEntity>)

    @Query("SELECT * FROM daily_budget_snapshot ORDER BY date DESC")
    fun observeAll(): Flow<List<DailyBudgetSnapshotEntity>>

    @Query("SELECT * FROM daily_budget_snapshot WHERE periodId = :periodId AND date = :date LIMIT 1")
    fun observeByDate(periodId: String, date: LocalDate): Flow<DailyBudgetSnapshotEntity?>
}
