package com.natasaku.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.natasaku.app.domain.model.ExpenseSource
import java.time.Instant
import java.time.LocalDate

@Entity(
    tableName = "expense_transaction",
    indices = [Index("periodId"), Index("date"), Index(value = ["periodId", "date"]), Index("deletedAt")],
)
data class ExpenseTransactionEntity(
    @PrimaryKey val id: String,
    val periodId: String,
    val amount: Long,
    val category: String,
    val date: LocalDate,
    val note: String?,
    val createdAt: Instant,
    val updatedAt: Instant,
    val deletedAt: Instant? = null,
    val source: ExpenseSource = ExpenseSource.MANUAL,
    val fixedExpenseId: String? = null,
)
