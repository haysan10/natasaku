package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.natasaku.app.domain.model.SavingFrequency
import java.time.Instant
import java.time.LocalDate

@Entity(
    tableName = "scheduled_saving",
    indices = [Index("savingTargetId"), Index("isActive"), Index("lastExecutedDate")],
)
data class ScheduledSavingEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val savingTargetId: String,
    val name: String,
    val amountPerExecution: Long,
    val frequency: SavingFrequency,
    val dayOfMonth: Int? = null,
    val dayOfWeek: Int? = null,
    val startDate: LocalDate,
    val endDate: LocalDate? = null,
    val isActive: Boolean = true,
    val lastExecutedDate: LocalDate? = null,
    val createdAt: Instant = Instant.now(),
)
