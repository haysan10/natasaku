package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.LocalDate

@Entity(
    tableName = "scheduled_saving_execution",
    indices = [Index("scheduledSavingId"), Index(value = ["scheduledSavingId", "executedDate"], unique = true)],
)
data class ScheduledSavingExecutionEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val scheduledSavingId: Long,
    val executedDate: LocalDate,
    val savingAllocationId: String,
    val amount: Long,
    val status: String,
)
