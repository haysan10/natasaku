package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.ScheduledSavingExecutionEntity
import java.time.LocalDate
import kotlinx.coroutines.flow.Flow

@Dao
interface ScheduledSavingExecutionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ScheduledSavingExecutionEntity)

    @Query(
        """
        SELECT * FROM scheduled_saving_execution
        WHERE scheduledSavingId = :scheduledSavingId
        ORDER BY executedDate DESC
        """,
    )
    fun observeByScheduledSaving(scheduledSavingId: Long): Flow<List<ScheduledSavingExecutionEntity>>

    @Query(
        """
        SELECT COUNT(*) FROM scheduled_saving_execution
        WHERE scheduledSavingId = :scheduledSavingId
        AND executedDate = :date
        """,
    )
    suspend fun countByDate(scheduledSavingId: Long, date: LocalDate): Int
}
