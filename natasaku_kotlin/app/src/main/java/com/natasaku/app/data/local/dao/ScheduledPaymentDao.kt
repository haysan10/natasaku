package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.ScheduledPaymentEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ScheduledPaymentDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ScheduledPaymentEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<ScheduledPaymentEntity>)

    @Query("SELECT * FROM scheduled_payment ORDER BY createdAt DESC")
    fun observeAll(): Flow<List<ScheduledPaymentEntity>>

    @Query("SELECT * FROM scheduled_payment WHERE isActive = 1 ORDER BY createdAt DESC")
    suspend fun getActiveNow(): List<ScheduledPaymentEntity>

    @Query("UPDATE scheduled_payment SET isActive = :isActive WHERE id = :id")
    suspend fun updateActive(id: Long, isActive: Boolean)

    @Query("UPDATE scheduled_payment SET isActive = 0 WHERE id = :id")
    suspend fun softDelete(id: Long)

    @Query("UPDATE scheduled_payment SET lastExecutedDate = :date WHERE id = :id")
    suspend fun updateLastExecutedDate(id: Long, date: java.time.LocalDate)
}
