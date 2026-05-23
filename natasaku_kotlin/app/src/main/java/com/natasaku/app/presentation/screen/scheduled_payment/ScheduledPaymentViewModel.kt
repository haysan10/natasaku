package com.natasaku.app.presentation.screen.scheduled_payment

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.ScheduledPaymentDao
import com.natasaku.app.data.local.entity.ScheduledPaymentEntity
import com.natasaku.app.domain.model.PaymentFrequency
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.domain.validation.ScheduleDueCalculator
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.Instant
import java.time.LocalDate
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class ScheduledPaymentItemUi(
    val id: Long,
    val name: String,
    val amount: Long,
    val frequency: PaymentFrequency,
    val dayOfMonth: Int,
    val isActive: Boolean,
    val nextExecutionLabel: String,
)

data class ScheduledPaymentUiState(
    val items: List<ScheduledPaymentItemUi> = emptyList(),
    val showAddSheet: Boolean = false,
    val errorMessage: String? = null,
)

sealed interface ScheduledPaymentUiEvent {
    data object Load : ScheduledPaymentUiEvent
    data object OpenAddSheet : ScheduledPaymentUiEvent
    data object CloseAddSheet : ScheduledPaymentUiEvent
    data class ToggleActive(val id: Long, val isActive: Boolean) : ScheduledPaymentUiEvent
    data class Save(
        val name: String,
        val amountRaw: String,
        val frequency: PaymentFrequency,
        val dayOfMonth: Int,
        val customIntervalDays: Int?,
        val note: String?,
    ) : ScheduledPaymentUiEvent
}

@HiltViewModel
class ScheduledPaymentViewModel @Inject constructor(
    private val scheduledPaymentDao: ScheduledPaymentDao,
) : ViewModel() {
    private val _uiState = MutableStateFlow(ScheduledPaymentUiState())
    val uiState = _uiState.asStateFlow()

    fun onEvent(event: ScheduledPaymentUiEvent) {
        when (event) {
            ScheduledPaymentUiEvent.Load -> load()
            ScheduledPaymentUiEvent.OpenAddSheet -> _uiState.update { it.copy(showAddSheet = true, errorMessage = null) }
            ScheduledPaymentUiEvent.CloseAddSheet -> _uiState.update { it.copy(showAddSheet = false, errorMessage = null) }
            is ScheduledPaymentUiEvent.ToggleActive -> toggleActive(event.id, event.isActive)
            is ScheduledPaymentUiEvent.Save -> save(event)
        }
    }

    private fun load() = viewModelScope.launch {
        val items = scheduledPaymentDao.observeAll().first()
        _uiState.update {
            it.copy(
                items = items.map { item ->
                    ScheduledPaymentItemUi(
                        id = item.id,
                        name = item.name,
                        amount = item.amount,
                        frequency = item.frequency,
                        dayOfMonth = item.dayOfMonth,
                        isActive = item.isActive,
                        nextExecutionLabel = buildNextExecutionLabel(item),
                    )
                },
            )
        }
    }

    private fun toggleActive(id: Long, isActive: Boolean) = viewModelScope.launch {
        scheduledPaymentDao.updateActive(id = id, isActive = !isActive)
        load()
    }

    private fun save(event: ScheduledPaymentUiEvent.Save) = viewModelScope.launch {
        if (event.name.isBlank()) {
            _uiState.update { it.copy(errorMessage = "Nama tagihan wajib diisi") }
            return@launch
        }
        val nominalValidation = NominalInputValidator.validate(event.amountRaw)
        if (!nominalValidation.isValid) {
            _uiState.update { it.copy(errorMessage = nominalValidation.errorMessage) }
            return@launch
        }
        val validatedDay = event.dayOfMonth.coerceIn(1, 28)
        val validatedInterval = event.customIntervalDays?.coerceIn(1, 365)
        scheduledPaymentDao.upsert(
            ScheduledPaymentEntity(
                name = event.name.trim(),
                amount = nominalValidation.amount,
                categoryId = 0L,
                dayOfMonth = validatedDay,
                frequency = event.frequency,
                customIntervalDays = validatedInterval,
                startDate = LocalDate.now(),
                endDate = null,
                isActive = true,
                note = event.note?.take(200),
                lastExecutedDate = null,
                createdAt = Instant.now(),
            ),
        )
        _uiState.update { it.copy(showAddSheet = false, errorMessage = null) }
        load()
    }

    private fun buildNextExecutionLabel(item: ScheduledPaymentEntity): String {
        val nextDate = ScheduleDueCalculator.nextScheduledPaymentExecutionDate(
            startDate = item.startDate,
            endDate = item.endDate,
            frequency = item.frequency,
            dayOfMonth = item.dayOfMonth,
            customIntervalDays = item.customIntervalDays,
            lastExecutedDate = item.lastExecutedDate,
            today = LocalDate.now(),
        )
        return if (nextDate == null) {
            "Berikutnya: tidak ada (jadwal berakhir)"
        } else {
            "Berikutnya: $nextDate"
        }
    }
}
