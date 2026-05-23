package com.natasaku.app.presentation.screen.saving

import com.natasaku.app.domain.model.LeftoverAllocationType
import java.time.LocalDate

data class SavingAllocationUi(
    val id: String,
    val amount: Long,
    val date: LocalDate,
    val source: String,
)

data class ScheduledSavingUi(
    val id: Long,
    val name: String,
    val amountPerExecution: Long,
    val frequencyLabel: String,
    val nextExecutionLabel: String,
    val isActive: Boolean,
)

data class SavingUiState(
    val hasTarget: Boolean = false,
    val targetAmount: Long = 0L,
    val totalCollected: Long = 0L,
    val progress: Float = 0f,
    val history: List<SavingAllocationUi> = emptyList(),
    val showLeftoverDialog: Boolean = false,
    val leftoverAmount: Long = 0L,
    val scheduledSummary: String? = null,
    val scheduledSavings: List<ScheduledSavingUi> = emptyList(),
    val scheduleExecutionHistory: List<SavingAllocationUi> = emptyList(),
    val showAddScheduleSheet: Boolean = false,
    val infoMessage: String? = null,
    val errorMessage: String? = null,
)

sealed interface SavingUiEvent {
    data object Load : SavingUiEvent
    data class AllocateLeftover(val type: LeftoverAllocationType) : SavingUiEvent
    data object OpenAddScheduleSheet : SavingUiEvent
    data object CloseAddScheduleSheet : SavingUiEvent
    data class SaveSchedule(
        val name: String,
        val amountRaw: String,
        val frequency: com.natasaku.app.domain.model.SavingFrequency,
        val dayOfMonth: Int?,
        val dayOfWeek: Int?,
    ) : SavingUiEvent
    data class ToggleScheduleActive(val id: Long, val isActive: Boolean) : SavingUiEvent
    data object DismissLeftover : SavingUiEvent
    data object ClearMessage : SavingUiEvent
}
