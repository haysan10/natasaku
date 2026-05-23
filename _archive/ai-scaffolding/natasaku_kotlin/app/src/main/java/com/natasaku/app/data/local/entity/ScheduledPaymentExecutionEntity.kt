package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.natasaku.app.domain.model.ExecutionStatus
import java.time.LocalDate

@Entity(
    tableName = "scheduled_payment_execution",
    indices = [Index("scheduledPaymentId"), Index(value = ["scheduledPaymentId", "executedDate"], unique = true)],
)
data class ScheduledPaymentExecutionEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val scheduledPaymentId: Long,
    val executedDate: LocalDate,
    val transactionId: String,
    val status: ExecutionStatus,
)
