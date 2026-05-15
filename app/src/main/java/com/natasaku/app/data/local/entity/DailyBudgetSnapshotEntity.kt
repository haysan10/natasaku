package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.LocalDate

@Entity(
    tableName = "daily_budget_snapshot",
    indices = [Index(value = ["periodId", "date"], unique = true)],
)
data class DailyBudgetSnapshotEntity(
    @PrimaryKey val id: String,
    val periodId: String,
    val date: LocalDate,
    val finalDailyAllowance: Long,
    val spentToday: Long,
    val remainingToday: Long,
)
