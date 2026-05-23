package com.natasaku.app.data.repository.setup

import com.natasaku.app.data.repository.BudgetRepositoryImpl
import com.natasaku.app.data.repository.SettingsRepositoryImpl
import com.natasaku.app.data.local.database.NataSakuDatabase
import com.natasaku.app.data.local.entity.FixedExpenseEntity
import com.natasaku.app.data.local.entity.IncomeSourceEntity
import com.natasaku.app.data.local.entity.SavingTargetEntity
import com.natasaku.app.domain.model.FixedExpenseStatus
import com.natasaku.app.domain.model.BudgetPeriod
import com.natasaku.app.domain.usecase.CompleteSetupUseCase
import com.natasaku.app.presentation.screen.setup.SetupUiState
import java.time.Instant
import java.util.UUID
import kotlinx.coroutines.flow.first

class CompleteSetupUseCaseImpl(
    private val db: NataSakuDatabase,
    private val budgetRepository: BudgetRepositoryImpl,
    private val settingsRepository: SettingsRepositoryImpl,
) : CompleteSetupUseCase {
    override suspend fun invoke(state: SetupUiState) {
        val start = requireNotNull(state.startDate)
        val end = requireNotNull(state.endDate)
        val now = Instant.now()
        val periodId = UUID.randomUUID().toString()

        budgetRepository.setActivePeriod(
            BudgetPeriod(
                id = periodId,
                name = state.periodName,
                startDate = start,
                endDate = end,
                isActive = true,
                createdAt = now,
                updatedAt = now,
            ),
        )

        db.incomeSourceDao().upsertAll(state.incomes.map {
            IncomeSourceEntity(it.id, periodId, it.name, it.amount)
        })

        db.fixedExpenseDao().upsertAll(state.fixedExpenses.map {
            FixedExpenseEntity(
                id = it.id,
                periodId = periodId,
                name = it.name,
                amount = it.amount,
                dueDay = start.dayOfMonth,
                status = FixedExpenseStatus.COMMITTED,
                createdAt = now,
            )
        })

        if (state.savingTarget > 0L) {
            db.savingTargetDao().upsert(
                SavingTargetEntity(UUID.randomUUID().toString(), periodId, state.savingTarget),
            )
        }

        val updated = settingsRepository.observePreferences().first().copy(
            onboardingCompleted = true,
            activePeriodId = periodId,
        )
        settingsRepository.updatePreferences(updated)
    }
}
