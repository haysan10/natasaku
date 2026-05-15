package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "saving_target",
    indices = [Index("periodId")],
)
data class SavingTargetEntity(
    @PrimaryKey val id: String,
    val periodId: String,
    val targetAmount: Long,
)
