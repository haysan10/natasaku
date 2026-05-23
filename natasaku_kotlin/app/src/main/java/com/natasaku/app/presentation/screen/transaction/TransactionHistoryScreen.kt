package com.natasaku.app.presentation.screen.transaction

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarDuration
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.paging.LoadState
import androidx.paging.compose.LazyPagingItems
import androidx.paging.compose.collectAsLazyPagingItems
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.domain.validation.TransactionInputValidator
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton
import com.natasaku.app.presentation.component.NataShimmerBox
import com.natasaku.app.presentation.component.NataSwipeableRow
import com.natasaku.app.presentation.component.NominalInputField
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

@Composable
fun TransactionHistoryRoute(
    modifier: Modifier = Modifier,
    viewModel: TransactionHistoryViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val pagedItems = viewModel.pagedTransactions.collectAsLazyPagingItems()
    LaunchedEffect(Unit) { viewModel.onEvent(TransactionHistoryUiEvent.Load) }
    TransactionHistoryScreen(uiState, pagedItems, viewModel::onEvent, modifier)
}

@Composable
fun TransactionHistoryScreen(
    uiState: TransactionHistoryUiState,
    pagedItems: LazyPagingItems<ExpenseTransactionEntity>,
    onEvent: (TransactionHistoryUiEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    val snackbarHostState = remember { SnackbarHostState() }
    val dateFormatter = remember { DateTimeFormatter.ofPattern("EEEE, d MMM yyyy", Locale("id", "ID")) }
    val timeFormatter = remember { DateTimeFormatter.ofPattern("HH:mm", Locale("id", "ID")) }

    LaunchedEffect(uiState.snackbarMessage) {
        val message = uiState.snackbarMessage ?: return@LaunchedEffect
        val result = snackbarHostState.showSnackbar(
            message = message,
            actionLabel = "Batalkan",
            duration = SnackbarDuration.Long,
        )
        if (result == androidx.compose.material3.SnackbarResult.ActionPerformed) {
            onEvent(TransactionHistoryUiEvent.UndoDelete)
        }
        onEvent(TransactionHistoryUiEvent.ClearSnackbar)
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text("Riwayat transaksi", style = MaterialTheme.typography.titleLarge)
            OutlinedTextField(
                value = uiState.query,
                onValueChange = { onEvent(TransactionHistoryUiEvent.UpdateQuery(it)) },
                label = { Text("Cari kategori atau catatan") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
            )

            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                item {
                    FilterChip(
                        selected = uiState.selectedCategory == null,
                        onClick = { onEvent(TransactionHistoryUiEvent.SelectCategory(null)) },
                        label = { Text("Semua") },
                    )
                }
                items(uiState.categories) { cat ->
                    FilterChip(
                        selected = uiState.selectedCategory == cat,
                        onClick = { onEvent(TransactionHistoryUiEvent.SelectCategory(cat)) },
                        label = { Text(cat) },
                    )
                }
            }

            Text("Total terfilter")
            MoneyText(uiState.totalFilteredSpending)

            if (uiState.isEmpty && pagedItems.itemCount == 0 && pagedItems.loadState.refresh !is LoadState.Loading) {
                Text("📭 Belum ada transaksi")
                Text("Belum ada transaksi di filter ini. Coba ubah pencarian atau kategori.")
            } else {
                LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(
                        count = pagedItems.itemCount,
                        key = { idx -> pagedItems.peek(idx)?.id ?: "placeholder-$idx" },
                    ) { index ->
                        val item = pagedItems[index] ?: return@items
                        val previousDate = pagedItems.peek(index - 1)?.date
                        if (previousDate == null || previousDate != item.date) {
                            Text(item.date.format(dateFormatter), style = MaterialTheme.typography.titleMedium)
                        }
                        val timeLabel = item.createdAt.atZone(ZoneId.systemDefault()).toLocalTime().format(timeFormatter)
                        NataSwipeableRow(
                            onRevealDelete = { onEvent(TransactionHistoryUiEvent.AskDelete(item.id)) },
                            onRevealEdit = { onEvent(TransactionHistoryUiEvent.StartEdit(item.id)) },
                        ) {
                            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("${categoryEmoji(item.category)} ${item.category}")
                                    Text(item.note ?: "Tanpa catatan", style = MaterialTheme.typography.bodySmall)
                                    Text(timeLabel, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                }
                                Column(horizontalAlignment = Alignment.End) {
                                    MoneyText(item.amount)
                                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                        NataSecondaryButton("Edit", onClick = { onEvent(TransactionHistoryUiEvent.StartEdit(item.id)) })
                                        NataSecondaryButton("Hapus", onClick = { onEvent(TransactionHistoryUiEvent.AskDelete(item.id)) })
                                    }
                                }
                            }
                        }
                    }

                    if (pagedItems.loadState.append is LoadState.Loading || pagedItems.loadState.refresh is LoadState.Loading) {
                        item {
                            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                                repeat(3) {
                                    NataShimmerBox(
                                        width = 340.dp,
                                        height = 66.dp,
                                        shape = MaterialTheme.shapes.medium,
                                    )
                                }
                            }
                        }
                    }

                    if (pagedItems.loadState.append is LoadState.Error || pagedItems.loadState.refresh is LoadState.Error) {
                        item {
                            Text(
                                "Riwayat belum berhasil dimuat. Coba lagi.",
                                color = MaterialTheme.colorScheme.error,
                            )
                        }
                    }
                }
            }
        }
    }

    uiState.editingItem?.let { edit ->
        EditTransactionBottomSheet(
            item = edit,
            categories = uiState.categories,
            onDismiss = { onEvent(TransactionHistoryUiEvent.Load) },
        ) { amount, category, note ->
            onEvent(TransactionHistoryUiEvent.SaveEdit(edit.id, amount, category, note))
        }
    }

    uiState.deletingItemId?.let { id ->
        ModalBottomSheet(
            onDismissRequest = { onEvent(TransactionHistoryUiEvent.DismissDelete) },
        ) {
            Column(
                modifier = Modifier.padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Text("Hapus transaksi?", style = MaterialTheme.typography.titleMedium)
                Text(
                    "Transaksi ini tidak akan dihitung lagi pada dashboard dan laporan.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                NataPrimaryButton(
                    text = "Hapus",
                    onClick = { onEvent(TransactionHistoryUiEvent.ConfirmDelete(id)) },
                    modifier = Modifier.fillMaxWidth(),
                )
                NataSecondaryButton(
                    text = "Batal",
                    onClick = { onEvent(TransactionHistoryUiEvent.DismissDelete) },
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EditTransactionBottomSheet(
    item: TransactionItemUi,
    categories: List<String>,
    onDismiss: () -> Unit,
    onSave: (Long, String, String?) -> Unit,
) {
    var amountField by remember(item.id) { mutableStateOf(TextFieldValue(item.amount.toString())) }
    var selectedCategory by remember(item.id) { mutableStateOf(item.category) }
    var note by remember(item.id) { mutableStateOf(item.note.orEmpty()) }
    val amountValidation = NominalInputValidator.validate(amountField.text)
    val noteText = TransactionInputValidator.trimNoteToMaxLength(note)

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Text("Edit Transaksi", style = MaterialTheme.typography.titleLarge)
            NominalInputField(
                value = amountField,
                onValueChange = { amountField = it },
                label = "Nominal",
            )
            Text("Kategori", style = MaterialTheme.typography.bodyMedium)
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(categories.ifEmpty { listOf(item.category) }) { category ->
                    FilterChip(
                        selected = selectedCategory == category,
                        onClick = { selectedCategory = category },
                        label = { Text(category) },
                    )
                }
            }
            OutlinedTextField(
                value = noteText,
                onValueChange = { note = TransactionInputValidator.trimNoteToMaxLength(it) },
                label = { Text("Catatan") },
                placeholder = { Text("Opsional") },
                modifier = Modifier.fillMaxWidth(),
            )
            Text(
                TransactionInputValidator.noteCounter(noteText),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            NataPrimaryButton(
                "Simpan",
                onClick = {
                    onSave(amountValidation.amount, selectedCategory, noteText.ifBlank { null })
                },
                enabled = amountValidation.isValid && selectedCategory.isNotBlank(),
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}

private fun categoryEmoji(category: String): String {
    return when (category.lowercase()) {
        "makan", "makanan", "minum", "kuliner" -> "🍔"
        "transportasi", "transport", "ojek", "bensin" -> "🚗"
        "belanja", "shopping", "kebutuhan" -> "🛍️"
        "tagihan", "listrik", "pulsa", "wifi" -> "💳"
        "hiburan", "nonton", "game", "refreshing" -> "🍿"
        "tabungan", "investasi", "celengan" -> "💰"
        else -> "📦"
    }
}
