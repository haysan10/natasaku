package com.natasaku.app.presentation.screen.transaction

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.Instant
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class TransactionHistoryViewModel @Inject constructor(
    private val budgetPeriodDao: BudgetPeriodDao,
    private val transactionDao: ExpenseTransactionDao,
) : ViewModel() {
    private val _uiState = MutableStateFlow(TransactionHistoryUiState())
    val uiState = _uiState.asStateFlow()

    private var latestItems: List<ExpenseTransactionEntity> = emptyList()

    fun onEvent(event: TransactionHistoryUiEvent) {
        when (event) {
            TransactionHistoryUiEvent.Load -> load()
            is TransactionHistoryUiEvent.UpdateQuery -> {
                _uiState.update { it.copy(query = event.value) }
                applyFilters()
            }
            is TransactionHistoryUiEvent.SelectCategory -> {
                _uiState.update { it.copy(selectedCategory = event.value) }
                applyFilters()
            }
            is TransactionHistoryUiEvent.StartEdit -> {
                val item = latestItems.firstOrNull { it.id == event.id } ?: return
                _uiState.update { it.copy(editingItem = item.toUi()) }
            }
            is TransactionHistoryUiEvent.SaveEdit -> saveEdit(event.id, event.amount, event.category, event.note)
            is TransactionHistoryUiEvent.AskDelete -> _uiState.update { it.copy(deletingItemId = event.id) }
            TransactionHistoryUiEvent.DismissDelete -> _uiState.update { it.copy(deletingItemId = null) }
            is TransactionHistoryUiEvent.ConfirmDelete -> softDelete(event.id)
        }
    }

    private fun load() = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first() ?: run {
            _uiState.update { TransactionHistoryUiState() }
            return@launch
        }
        latestItems = transactionDao.observeByPeriod(period.id).first()
        applyFilters()
    }

    private fun applyFilters() {
        val state = _uiState.value
        var filtered = latestItems
        if (state.query.isNotBlank()) {
            val q = state.query.trim().lowercase()
            filtered = filtered.filter {
                it.category.lowercase().contains(q) || (it.note?.lowercase()?.contains(q) == true)
            }
        }
        state.selectedCategory?.let { cat -> filtered = filtered.filter { it.category == cat } }

        val grouped = filtered.groupBy { it.date }
            .toSortedMap(compareByDescending { it })
            .map { (d, items) -> TransactionGroupUi(d, items.sortedByDescending { it.createdAt }.map { it.toUi() }) }

        _uiState.update {
            it.copy(
                categories = latestItems.map { x -> x.category }.distinct().sorted(),
                totalFilteredSpending = filtered.sumOf { x -> x.amount },
                grouped = grouped,
                isEmpty = grouped.isEmpty(),
                editingItem = null,
                deletingItemId = null,
            )
        }
    }

    private fun saveEdit(id: String, amount: Long, category: String, note: String?) {
        if (amount <= 0L || category.isBlank()) return
        viewModelScope.launch {
            val existing = latestItems.firstOrNull { it.id == id } ?: return@launch
            transactionDao.upsert(
                existing.copy(
                    amount = amount,
                    category = category,
                    note = note,
                    updatedAt = Instant.now(),
                ),
            )
            load()
        }
    }

    private fun softDelete(id: String) {
        viewModelScope.launch {
            transactionDao.softDelete(id, Instant.now())
            load()
        }
    }

    private fun ExpenseTransactionEntity.toUi(): TransactionItemUi = TransactionItemUi(
        id = id,
        amount = amount,
        category = category,
        note = note,
        date = date,
    )
}
