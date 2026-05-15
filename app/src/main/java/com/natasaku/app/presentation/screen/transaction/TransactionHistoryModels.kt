package com.natasaku.app.presentation.screen.transaction

import java.time.LocalDate

data class TransactionItemUi(
    val id: String,
    val amount: Long,
    val category: String,
    val note: String?,
    val date: LocalDate,
)

data class TransactionGroupUi(
    val date: LocalDate,
    val items: List<TransactionItemUi>,
)

data class TransactionHistoryUiState(
    val query: String = "",
    val selectedCategory: String? = null,
    val categories: List<String> = emptyList(),
    val totalFilteredSpending: Long = 0L,
    val grouped: List<TransactionGroupUi> = emptyList(),
    val editingItem: TransactionItemUi? = null,
    val deletingItemId: String? = null,
    val isEmpty: Boolean = true,
)

sealed interface TransactionHistoryUiEvent {
    data object Load : TransactionHistoryUiEvent
    data class UpdateQuery(val value: String) : TransactionHistoryUiEvent
    data class SelectCategory(val value: String?) : TransactionHistoryUiEvent
    data class StartEdit(val id: String) : TransactionHistoryUiEvent
    data class SaveEdit(val id: String, val amount: Long, val category: String, val note: String?) : TransactionHistoryUiEvent
    data class AskDelete(val id: String) : TransactionHistoryUiEvent
    data object DismissDelete : TransactionHistoryUiEvent
    data class ConfirmDelete(val id: String) : TransactionHistoryUiEvent
}
