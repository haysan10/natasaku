package com.natasaku.app.presentation.screen.saving

import com.natasaku.app.domain.model.LeftoverAllocationType
import java.time.LocalDate

data class SavingAllocationUi(
    val id: String,
    val amount: Long,
    val date: LocalDate,
    val source: String,
)

data class SavingUiState(
    val hasTarget: Boolean = false,
    val targetAmount: Long = 0L,
    val totalCollected: Long = 0L,
    val progress: Float = 0f,
    val history: List<SavingAllocationUi> = emptyList(),
    val showLeftoverDialog: Boolean = false,
    val leftoverAmount: Long = 0L,
)

sealed interface SavingUiEvent {
    data object Load : SavingUiEvent
    data class AllocateLeftover(val type: LeftoverAllocationType) : SavingUiEvent
    data object DismissLeftover : SavingUiEvent
}
