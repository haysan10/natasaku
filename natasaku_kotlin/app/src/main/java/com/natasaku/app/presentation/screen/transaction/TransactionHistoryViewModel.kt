package com.natasaku.app.presentation.screen.transaction

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.PagingData
import androidx.paging.cachedIn
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.domain.validation.TransactionInputValidator
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.Instant
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class TransactionHistoryViewModel @Inject constructor(
    private val budgetPeriodDao: BudgetPeriodDao,
    private val transactionDao: ExpenseTransactionDao,
) : ViewModel() {
    private val _uiState = MutableStateFlow(TransactionHistoryUiState())
    val uiState = _uiState.asStateFlow()

    private val queryFlow = MutableStateFlow("")
    private val categoryFlow = MutableStateFlow<String?>(null)
    private val activePeriodIdFlow = MutableStateFlow<String?>(null)
    private var filterSummaryJob: Job? = null
    private var lastSoftDeleted: ExpenseTransactionEntity? = null
    private var lastEditSaveAt: Long = 0L

    val pagedTransactions: Flow<PagingData<ExpenseTransactionEntity>> =
        combine(activePeriodIdFlow, queryFlow, categoryFlow) { periodId, query, category ->
            Triple(periodId, query.trim(), category)
        }.flatMapLatest { (periodId, query, category) ->
            if (periodId == null) {
                flowOf(PagingData.empty())
            } else {
                Pager(
                    config = PagingConfig(pageSize = 30, enablePlaceholders = false),
                ) {
                    transactionDao.pagingByPeriodFiltered(periodId, query, category)
                }.flow
            }
        }.cachedIn(viewModelScope)

    fun onEvent(event: TransactionHistoryUiEvent) {
        when (event) {
            TransactionHistoryUiEvent.Load -> load()
            is TransactionHistoryUiEvent.UpdateQuery -> {
                _uiState.update { it.copy(query = event.value) }
                queryFlow.value = event.value
            }
            is TransactionHistoryUiEvent.SelectCategory -> {
                _uiState.update { it.copy(selectedCategory = event.value) }
                categoryFlow.value = event.value
            }
            is TransactionHistoryUiEvent.StartEdit -> startEdit(event.id)
            is TransactionHistoryUiEvent.SaveEdit -> saveEdit(event.id, event.amount, event.category, event.note)
            is TransactionHistoryUiEvent.AskDelete -> _uiState.update { it.copy(deletingItemId = event.id) }
            TransactionHistoryUiEvent.DismissDelete -> _uiState.update { it.copy(deletingItemId = null) }
            is TransactionHistoryUiEvent.ConfirmDelete -> softDelete(event.id)
            TransactionHistoryUiEvent.UndoDelete -> undoDelete()
            TransactionHistoryUiEvent.ClearSnackbar -> _uiState.update { it.copy(snackbarMessage = null) }
        }
    }

    private fun load() = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first() ?: run {
            _uiState.update { TransactionHistoryUiState() }
            return@launch
        }
        activePeriodIdFlow.value = period.id
        _uiState.update { it.copy(activePeriodId = period.id) }
        observeFilterSummary(period.id)
    }

    private fun observeFilterSummary(periodId: String) {
        filterSummaryJob?.cancel()
        filterSummaryJob = viewModelScope.launch {
            combine(queryFlow, categoryFlow) { query, category -> query.trim() to category }
                .flatMapLatest { (query, category) ->
                    transactionDao.observeFiltered(periodId, query, category)
                }
                .collect { filtered ->
                    _uiState.update {
                        it.copy(
                            categories = filtered.map { item -> item.category }.distinct().sorted(),
                            totalFilteredSpending = filtered.sumOf { item -> item.amount },
                            isEmpty = filtered.isEmpty(),
                        )
                    }
                }
        }
    }

    private fun startEdit(id: String) = viewModelScope.launch {
        val item = transactionDao.findById(id) ?: return@launch
        if (item.deletedAt != null) return@launch
        _uiState.update { it.copy(editingItem = item.toUi()) }
    }

    private fun saveEdit(id: String, amount: Long, category: String, note: String?) {
        val nowMs = System.currentTimeMillis()
        if (nowMs - lastEditSaveAt < 500L) return
        lastEditSaveAt = nowMs

        val nominalValidation = NominalInputValidator.validate(amount.toString())
        if (!nominalValidation.isValid) return
        val categoryValidation = TransactionInputValidator.validateCategory(category)
        if (!categoryValidation.isValid) return
        viewModelScope.launch {
            val existing = transactionDao.findById(id) ?: return@launch
            transactionDao.upsert(
                existing.copy(
                    amount = nominalValidation.amount,
                    category = category.trim(),
                    note = TransactionInputValidator.trimNoteToMaxLength(note.orEmpty()).ifBlank { null },
                    updatedAt = Instant.now(),
                ),
            )
            _uiState.update { it.copy(editingItem = null) }
        }
    }

    private fun softDelete(id: String) {
        viewModelScope.launch {
            lastSoftDeleted = transactionDao.findById(id)
            transactionDao.softDelete(id, Instant.now())
            _uiState.update { it.copy(snackbarMessage = "Transaksi dihapus · Batalkan") }
            _uiState.update { it.copy(deletingItemId = null) }
        }
    }

    private fun undoDelete() {
        val deleted = lastSoftDeleted ?: return
        viewModelScope.launch {
            transactionDao.upsert(
                deleted.copy(
                    deletedAt = null,
                    updatedAt = Instant.now(),
                ),
            )
            _uiState.update { it.copy(snackbarMessage = null) }
            lastSoftDeleted = null
        }
    }

    private fun ExpenseTransactionEntity.toUi(): TransactionItemUi = TransactionItemUi(
        id = id,
        amount = amount,
        category = category,
        note = note,
        date = date,
        createdAt = createdAt,
    )
}
