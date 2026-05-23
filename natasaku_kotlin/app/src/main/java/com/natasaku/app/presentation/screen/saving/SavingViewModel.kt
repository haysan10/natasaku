package com.natasaku.app.presentation.screen.saving

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.ScheduledSavingDao
import com.natasaku.app.data.local.dao.ScheduledSavingExecutionDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.data.local.entity.ScheduledSavingEntity
import com.natasaku.app.domain.calculator.LeftoverAllocationCalculator
import com.natasaku.app.domain.model.DefaultLeftoverAllocation
import com.natasaku.app.domain.model.LeftoverAllocationType
import com.natasaku.app.domain.model.SavingFrequency
import com.natasaku.app.domain.repository.SettingsRepository
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.domain.validation.ScheduleDueCalculator
import com.natasaku.app.domain.validation.SavingInputValidator
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.Instant
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
    private val scheduledSavingDao: ScheduledSavingDao,
    private val scheduledSavingExecutionDao: ScheduledSavingExecutionDao,
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
            SavingUiEvent.OpenAddScheduleSheet -> _uiState.update { it.copy(showAddScheduleSheet = true, errorMessage = null) }
            SavingUiEvent.CloseAddScheduleSheet -> _uiState.update { it.copy(showAddScheduleSheet = false) }
            is SavingUiEvent.SaveSchedule -> saveSchedule(event)
            is SavingUiEvent.ToggleScheduleActive -> toggleSchedule(event.id, event.isActive)
            SavingUiEvent.DismissLeftover -> _uiState.update { it.copy(showLeftoverDialog = false) }
            SavingUiEvent.ClearMessage -> _uiState.update { it.copy(infoMessage = null, errorMessage = null) }
        }
    }

    private fun load() {
        viewModelScope.launch {
            val period = budgetPeriodDao.observeActivePeriod().first() ?: return@launch
            val target = savingTargetDao.observeByPeriod(period.id).first()
            val allocations = savingAllocationDao.observeByPeriod(period.id).first()
            val preferences = settingsRepository.observePreferences().first()
            val schedules = scheduledSavingDao.observeAll().first()
            val totalCollected = allocations.sumOf { it.amount }
            val targetAmount = target?.targetAmount ?: 0L
            val progress = if (targetAmount <= 0L) 0f else (totalCollected.toFloat() / targetAmount.toFloat()).coerceIn(0f, 1f)

            val today = LocalDate.now()
            val todaySnapshot = dailyBudgetSnapshotDao.observeByDate(period.id, today).first()
            val todayAlreadyAllocated = allocations.any { it.date == today }
            val leftover = todaySnapshot?.remainingToday ?: 0L
            val scheduleExecutionHistory = schedules
                .flatMap { scheduled ->
                    scheduledSavingExecutionDao.observeByScheduledSaving(scheduled.id).first().map { execution ->
                        SavingAllocationUi(
                            id = "${execution.scheduledSavingId}-${execution.executedDate}-${execution.id}",
                            amount = execution.amount,
                            date = execution.executedDate,
                            source = execution.status,
                        )
                    }
                }
                .sortedByDescending { it.date }
                .take(20)
            val scheduledUi = schedules
                .filter { target == null || it.savingTargetId == target.id }
                .map { scheduled ->
                    ScheduledSavingUi(
                        id = scheduled.id,
                        name = scheduled.name,
                        amountPerExecution = scheduled.amountPerExecution,
                        frequencyLabel = frequencyLabel(scheduled),
                        nextExecutionLabel = buildNextExecutionLabel(scheduled),
                        isActive = scheduled.isActive,
                    )
                }

            _uiState.update {
                it.copy(
                    hasTarget = target != null,
                    targetAmount = targetAmount,
                    totalCollected = totalCollected,
                    progress = progress,
                    history = allocations.map { a -> SavingAllocationUi(a.id, a.amount, a.date, a.source) },
                    scheduledSavings = scheduledUi,
                    scheduleExecutionHistory = scheduleExecutionHistory,
                    scheduledSummary = if (scheduledUi.isEmpty()) null else "${scheduledUi.size} jadwal aktif",
                    leftoverAmount = leftover,
                    infoMessage = null,
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
            val existingDates = savingAllocationDao.observeByPeriod(period.id).first().map { it.date }.toSet()
            val duplicateValidation = SavingInputValidator.validateDuplicateDailyAllocation(existingDates, today)
            if (!duplicateValidation.isValid) {
                _uiState.update {
                    it.copy(
                        showLeftoverDialog = false,
                        errorMessage = duplicateValidation.blockingError,
                    )
                }
                return@launch
            }

            val amount = _uiState.value.leftoverAmount
            if (amount <= 0L) return@launch
            val hasTarget = _uiState.value.hasTarget
            val leftoverValidation = SavingInputValidator.validateLeftoverAllocation(
                allocationAmount = amount,
                remainingDailyAllowance = _uiState.value.leftoverAmount,
            )
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

            _uiState.update {
                it.copy(
                    showLeftoverDialog = false,
                    errorMessage = null,
                    infoMessage = leftoverValidation.warning ?: "Sisa jatah berhasil dialokasikan.",
                )
            }
            load()
        }
    }

    private fun saveSchedule(event: SavingUiEvent.SaveSchedule) = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first() ?: return@launch
        val target = savingTargetDao.observeByPeriod(period.id).first()
        if (target == null) {
            _uiState.update {
                it.copy(
                    errorMessage = "Belum ada target tabungan. Tambahkan target dulu sebelum membuat jadwal otomatis.",
                    showAddScheduleSheet = false,
                )
            }
            return@launch
        }
        if (event.name.isBlank()) {
            _uiState.update { it.copy(errorMessage = "Nama jadwal wajib diisi") }
            return@launch
        }
        val nominalValidation = NominalInputValidator.validate(event.amountRaw)
        if (!nominalValidation.isValid) {
            _uiState.update { it.copy(errorMessage = nominalValidation.errorMessage) }
            return@launch
        }
        val normalizedDayOfMonth = if (event.frequency == SavingFrequency.MONTHLY) {
            (event.dayOfMonth ?: 1).coerceIn(1, 28)
        } else {
            null
        }
        val normalizedDayOfWeek = if (event.frequency == SavingFrequency.WEEKLY) {
            (event.dayOfWeek ?: LocalDate.now().dayOfWeek.value).coerceIn(1, 7)
        } else {
            null
        }
        scheduledSavingDao.upsert(
            ScheduledSavingEntity(
                savingTargetId = target.id,
                name = event.name.trim(),
                amountPerExecution = nominalValidation.amount,
                frequency = event.frequency,
                dayOfMonth = normalizedDayOfMonth,
                dayOfWeek = normalizedDayOfWeek,
                startDate = LocalDate.now(),
                endDate = null,
                isActive = true,
                lastExecutedDate = null,
                createdAt = Instant.now(),
            ),
        )
        _uiState.update {
            it.copy(
                showAddScheduleSheet = false,
                errorMessage = null,
                infoMessage = "Jadwal tabungan otomatis disimpan.",
            )
        }
        load()
    }

    private fun toggleSchedule(id: Long, isActive: Boolean) = viewModelScope.launch {
        scheduledSavingDao.updateActive(id, !isActive)
        load()
    }

    private fun frequencyLabel(scheduled: ScheduledSavingEntity): String {
        return when (scheduled.frequency) {
            SavingFrequency.DAILY -> "Harian"
            SavingFrequency.WEEKLY -> "Mingguan"
            SavingFrequency.MONTHLY -> "Bulanan"
        }
    }

    private fun buildNextExecutionLabel(scheduled: ScheduledSavingEntity): String {
        val today = LocalDate.now()
        val next = (0..365)
            .asSequence()
            .map { today.plusDays(it.toLong()) }
            .firstOrNull { candidate ->
                ScheduleDueCalculator.isScheduledSavingDue(
                    startDate = scheduled.startDate,
                    endDate = scheduled.endDate,
                    frequency = scheduled.frequency,
                    dayOfMonth = scheduled.dayOfMonth,
                    dayOfWeek = scheduled.dayOfWeek,
                    targetDate = candidate,
                )
            }
        return if (next == null) "Berikutnya: tidak ada" else "Berikutnya: $next"
    }
}
