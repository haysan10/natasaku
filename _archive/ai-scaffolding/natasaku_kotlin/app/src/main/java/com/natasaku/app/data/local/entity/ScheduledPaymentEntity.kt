package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.natasaku.app.domain.model.PaymentFrequency
import java.time.Instant
import java.time.LocalDate

@Entity(
    tableName = "scheduled_payment",
    indices = [Index("isActive"), Index("startDate"), Index("lastExecutedDate")],
)
data class ScheduledPaymentEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val amount: Long,
    val categoryId: Long,
    val dayOfMonth: Int,
    val frequency: PaymentFrequency,
    val customIntervalDays: Int? = null,
    val startDate: LocalDate,
    val endDate: LocalDate? = null,
    val isActive: Boolean = true,
    val note: String? = null,
    val lastExecutedDate: LocalDate? = null,
    val createdAt: Instant = Instant.now(),
)
