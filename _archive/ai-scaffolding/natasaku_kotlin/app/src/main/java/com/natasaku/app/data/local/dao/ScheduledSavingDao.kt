package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.ScheduledSavingEntity
import java.time.LocalDate
import kotlinx.coroutines.flow.Flow

@Dao
interface ScheduledSavingDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ScheduledSavingEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<ScheduledSavingEntity>)

    @Query("SELECT * FROM scheduled_saving ORDER BY createdAt DESC")
    fun observeAll(): Flow<List<ScheduledSavingEntity>>

    @Query("SELECT * FROM scheduled_saving WHERE isActive = 1 ORDER BY createdAt DESC")
    suspend fun getActiveNow(): List<ScheduledSavingEntity>

    @Query("UPDATE scheduled_saving SET isActive = :isActive WHERE id = :id")
    suspend fun updateActive(id: Long, isActive: Boolean)

    @Query("UPDATE scheduled_saving SET lastExecutedDate = :date WHERE id = :id")
    suspend fun updateLastExecutedDate(id: Long, date: LocalDate)
}
