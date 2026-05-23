package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.natasaku.app.domain.model.FixedExpenseStatus
import java.time.Instant

@Entity(
    tableName = "fixed_expense",
    indices = [Index("periodId")],
)
data class FixedExpenseEntity(
    @PrimaryKey val id: String,
    val periodId: String,
    val name: String,
    val amount: Long,
    val dueDay: Int = 1,
    val status: FixedExpenseStatus = FixedExpenseStatus.COMMITTED,
    val snoozedUntilTs: Instant? = null,
    val paidAt: Instant? = null,
    val createdAt: Instant = Instant.now(),
)
