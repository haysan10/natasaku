package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.ScheduledPaymentExecutionEntity
import java.time.LocalDate
import kotlinx.coroutines.flow.Flow

@Dao
interface ScheduledPaymentExecutionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ScheduledPaymentExecutionEntity)

    @Query(
        """
        SELECT * FROM scheduled_payment_execution
        WHERE scheduledPaymentId = :scheduledPaymentId
        ORDER BY executedDate DESC
        """,
    )
    fun observeByScheduledPayment(scheduledPaymentId: Long): Flow<List<ScheduledPaymentExecutionEntity>>

    @Query(
        """
        SELECT COUNT(*) FROM scheduled_payment_execution
        WHERE scheduledPaymentId = :scheduledPaymentId
        AND executedDate = :executedDate
        """,
    )
    suspend fun countByDate(scheduledPaymentId: Long, executedDate: LocalDate): Int

    @Query(
        """
        SELECT * FROM scheduled_payment_execution
        WHERE executedDate BETWEEN :startDate AND :endDate
        ORDER BY executedDate DESC
        """,
    )
    suspend fun getByDateRange(startDate: LocalDate, endDate: LocalDate): List<ScheduledPaymentExecutionEntity>
}
