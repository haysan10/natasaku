package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.LocalDate

@Entity(
    tableName = "budget_period",
    indices = [Index("isActive")],
)
data class BudgetPeriodEntity(
    @PrimaryKey val id: String,
    val name: String,
    val startDate: LocalDate,
    val endDate: LocalDate,
    val isActive: Boolean,
    val createdAt: Instant,
    val updatedAt: Instant,
)
