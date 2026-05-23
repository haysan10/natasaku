package com.natasaku.app.domain.repository

import com.natasaku.app.domain.model.BudgetPeriod
import kotlinx.coroutines.flow.Flow

interface BudgetRepository {
    suspend fun setActivePeriod(period: BudgetPeriod)
    fun observeActivePeriod(): Flow<BudgetPeriod?>
}
