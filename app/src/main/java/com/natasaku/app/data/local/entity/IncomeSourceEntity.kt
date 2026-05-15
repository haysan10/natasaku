package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "income_source",
    indices = [Index("periodId")],
)
data class IncomeSourceEntity(
    @PrimaryKey val id: String,
    val periodId: String,
    val name: String,
    val amount: Long,
)
