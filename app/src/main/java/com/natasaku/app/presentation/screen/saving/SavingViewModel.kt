package com.natasaku.app.presentation.screen.saving

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.domain.calculator.LeftoverAllocationCalculator
import com.natasaku.app.domain.model.DefaultLeftoverAllocation
import com.natasaku.app.domain.model.LeftoverAllocationType
import com.natasaku.app.domain.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.LocalDate
import java.util.UUID
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class SavingViewModel @Inject constructor(
    private val budgetPeriodDao: BudgetPeriodDao,
    private val savingTargetDao: SavingTargetDao,
    private val savingAllocationDao: SavingAllocationDao,
    private val dailyBudgetSnapshotDao: DailyBudgetSnapshotDao,
    private val settingsRepository: SettingsRepository,
    private val leftoverAllocationCalculator: LeftoverAllocationCalculator = LeftoverAllocationCalculator(),
) : ViewModel() {
    private val _uiState = MutableStateFlow(SavingUiState())
    val uiState = _uiState.asStateFlow()

    fun onEvent(event: SavingUiEvent) {
        when (event) {
            SavingUiEvent.Load -> load()
            is SavingUiEvent.AllocateLeftover -> allocate(event.type)
            SavingUiEvent.DismissLeftover -> _uiState.update { it.copy(showLeftoverDialog = false) }
        }
    }

    private fun load() {
        viewModelScope.launch {
            val period = budgetPeriodDao.observeActivePeriod().first() ?: return@launch
            val target = savingTargetDao.observeByPeriod(period.id).first()
            val allocations = savingAllocationDao.observeByPeriod(period.id).first()
            val preferences = settingsRepository.observePreferences().first()
            val totalCollected = allocations.sumOf { it.amount }
            val targetAmount = target?.targetAmount ?: 0L
            val progress = if (targetAmount <= 0L) 0f else (totalCollected.toFloat() / targetAmount.toFloat()).coerceIn(0f, 1f)

            val today = LocalDate.now()
            val todaySnapshot = dailyBudgetSnapshotDao.observeByDate(period.id, today).first()
            val todayAlreadyAllocated = allocations.any { it.date == today }
            val leftover = todaySnapshot?.remainingToday ?: 0L

            _uiState.update {
                it.copy(
                    hasTarget = target != null,
                    targetAmount = targetAmount,
                    totalCollected = totalCollected,
                    progress = progress,
                    history = allocations.map { a -> SavingAllocationUi(a.id, a.amount, a.date, a.source) },
                    leftoverAmount = leftover,
                    showLeftoverDialog = leftover > 0L && !todayAlreadyAllocated &&
                        preferences.defaultLeftoverAllocation == DefaultLeftoverAllocation.ASK_EVERY_TIME,
                )
            }

            if (leftover > 0L && !todayAlreadyAllocated) {
                val mapped: LeftoverAllocationType? = when (preferences.defaultLeftoverAllocation) {
                    DefaultLeftoverAllocation.ASK_EVERY_TIME -> null
                    DefaultLeftoverAllocation.NEXT_DAY -> LeftoverAllocationType.NEXT_DAY
                    DefaultLeftoverAllocation.SAVING -> LeftoverAllocationType.SAVING
                    DefaultLeftoverAllocation.AUTO_SPLIT -> LeftoverAllocationType.AUTO_SPLIT
                    DefaultLeftoverAllocation.FREE_BALANCE -> LeftoverAllocationType.FREE_BALANCE
                }
                if (mapped != null) {
                    allocate(mapped)
                }
            }
        }
    }

    private fun allocate(type: LeftoverAllocationType) {
        viewModelScope.launch {
            val period = budgetPeriodDao.observeActivePeriod().first() ?: return@launch
            val today = LocalDate.now()
            val existingToday = savingAllocationDao.observeByPeriod(period.id).first().any { it.date == today }
            if (existingToday) {
                _uiState.update { it.copy(showLeftoverDialog = false) }
                return@launch
            }

            val amount = _uiState.value.leftoverAmount
            if (amount <= 0L) return@launch
            val hasTarget = _uiState.value.hasTarget
            val split = leftoverAllocationCalculator.allocate(amount, type)

            val contribution = when (type) {
                LeftoverAllocationType.SAVING -> if (hasTarget) amount else 0L
                LeftoverAllocationType.AUTO_SPLIT -> if (hasTarget) split.toSaving else 0L
                LeftoverAllocationType.NEXT_DAY -> 0L
                LeftoverAllocationType.FREE_BALANCE -> 0L
            }

            val source = when {
                type == LeftoverAllocationType.SAVING && !hasTarget -> "SAVING_SKIPPED_NO_TARGET"
                else -> type.name
            }

            savingAllocationDao.upsert(
                SavingAllocationEntity(
                    id = UUID.randomUUID().toString(),
                    periodId = period.id,
                    amount = contribution,
                    date = today,
                    source = source,
                ),
            )

            _uiState.update { it.copy(showLeftoverDialog = false) }
            load()
        }
    }
}
