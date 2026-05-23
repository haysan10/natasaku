package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.FixedExpenseEntity
import com.natasaku.app.domain.model.FixedExpenseStatus
import java.time.Instant
import kotlinx.coroutines.flow.Flow

@Dao
interface FixedExpenseDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: FixedExpenseEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<FixedExpenseEntity>)

    @Query("SELECT * FROM fixed_expense")
    fun observeAll(): Flow<List<FixedExpenseEntity>>

    @Query("SELECT * FROM fixed_expense WHERE periodId = :periodId")
    fun observeByPeriod(periodId: String): Flow<List<FixedExpenseEntity>>

    @Query("SELECT * FROM fixed_expense WHERE id = :id LIMIT 1")
    suspend fun getById(id: String): FixedExpenseEntity?

    @Query("UPDATE fixed_expense SET status = :status, paidAt = :paidAt, snoozedUntilTs = NULL WHERE id = :id")
    suspend fun updatePaid(id: String, status: FixedExpenseStatus, paidAt: Instant)

    @Query("UPDATE fixed_expense SET status = :status, snoozedUntilTs = :snoozedUntilTs WHERE id = :id")
    suspend fun updateSnooze(id: String, status: FixedExpenseStatus, snoozedUntilTs: Instant)

    @Query("UPDATE fixed_expense SET status = :status, dueDay = :dueDay, snoozedUntilTs = NULL WHERE id = :id")
    suspend fun reschedule(id: String, status: FixedExpenseStatus, dueDay: Int)

    @Query("UPDATE fixed_expense SET status = :status WHERE id = :id")
    suspend fun updateStatus(id: String, status: FixedExpenseStatus)
}
