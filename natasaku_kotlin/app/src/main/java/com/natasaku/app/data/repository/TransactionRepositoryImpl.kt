package com.natasaku.app.data.repository

import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.mapper.toDomain
import com.natasaku.app.data.local.mapper.toEntity
import com.natasaku.app.domain.model.ExpenseTransaction
import com.natasaku.app.domain.repository.TransactionRepository
import java.time.Instant
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class TransactionRepositoryImpl(private val dao: ExpenseTransactionDao) : TransactionRepository {
    override suspend fun upsert(transaction: ExpenseTransaction) = dao.upsert(transaction.toEntity())
    override fun observeByPeriod(periodId: String): Flow<List<ExpenseTransaction>> = dao.observeByPeriod(periodId).map { it.map { e -> e.toDomain() } }
    override fun observeByPeriodAndQuery(periodId: String, query: String): Flow<List<ExpenseTransaction>> = dao.observeByPeriodAndQuery(periodId, query).map { it.map { e -> e.toDomain() } }
    override suspend fun softDelete(id: String, deletedAt: Instant) = dao.softDelete(id, deletedAt)
}
