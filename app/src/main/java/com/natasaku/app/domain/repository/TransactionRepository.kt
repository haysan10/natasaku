package com.natasaku.app.domain.repository

import com.natasaku.app.domain.model.ExpenseTransaction
import java.time.Instant
import kotlinx.coroutines.flow.Flow

interface TransactionRepository {
    suspend fun upsert(transaction: ExpenseTransaction)
    fun observeByPeriod(periodId: String): Flow<List<ExpenseTransaction>>
    fun observeByPeriodAndQuery(periodId: String, query: String): Flow<List<ExpenseTransaction>>
    suspend fun softDelete(id: String, deletedAt: Instant)
}
