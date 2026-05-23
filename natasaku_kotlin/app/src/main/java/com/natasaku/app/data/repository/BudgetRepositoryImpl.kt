package com.natasaku.app.data.repository

import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.mapper.toDomain
import com.natasaku.app.data.local.mapper.toEntity
import com.natasaku.app.domain.model.BudgetPeriod
import com.natasaku.app.domain.repository.BudgetRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class BudgetRepositoryImpl(private val dao: BudgetPeriodDao) : BudgetRepository {
    override suspend fun setActivePeriod(period: BudgetPeriod) {
        dao.clearActive()
        dao.upsert(period.copy(isActive = true).toEntity())
    }

    override fun observeActivePeriod(): Flow<BudgetPeriod?> = dao.observeActivePeriod().map { it?.toDomain() }
}
