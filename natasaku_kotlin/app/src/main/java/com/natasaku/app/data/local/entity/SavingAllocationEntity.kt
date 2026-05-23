package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.LocalDate

@Entity(
    tableName = "saving_allocation",
    indices = [Index("periodId"), Index("date")],
)
data class SavingAllocationEntity(
    @PrimaryKey val id: String,
    val periodId: String,
    val amount: Long,
    val date: LocalDate,
    val source: String,
)
