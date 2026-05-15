package com.natasaku.app.presentation.screen.transaction

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton

@Composable
fun TransactionHistoryRoute(
    modifier: Modifier = Modifier,
    viewModel: TransactionHistoryViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onEvent(TransactionHistoryUiEvent.Load) }
    TransactionHistoryScreen(uiState, viewModel::onEvent, modifier)
}

@Composable
fun TransactionHistoryScreen(
    uiState: TransactionHistoryUiState,
    onEvent: (TransactionHistoryUiEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text("Riwayat transaksi", style = MaterialTheme.typography.titleLarge)
        OutlinedTextField(
            value = uiState.query,
            onValueChange = { onEvent(TransactionHistoryUiEvent.UpdateQuery(it)) },
            label = { Text("Cari kategori atau catatan") },
            modifier = Modifier.fillMaxWidth(),
        )

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            FilterChip(
                selected = uiState.selectedCategory == null,
                onClick = { onEvent(TransactionHistoryUiEvent.SelectCategory(null)) },
                label = { Text("Semua") },
            )
            uiState.categories.forEach { cat ->
                FilterChip(
                    selected = uiState.selectedCategory == cat,
                    onClick = { onEvent(TransactionHistoryUiEvent.SelectCategory(cat)) },
                    label = { Text(cat) },
                )
            }
        }

        Text("Total terfilter")
        MoneyText(uiState.totalFilteredSpending)

        if (uiState.isEmpty) {
            Text("Belum ada transaksi")
            Text("Pengeluaran yang kamu catat akan muncul di sini.")
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                uiState.grouped.forEach { group ->
                    item { Text(group.date.toString(), style = MaterialTheme.typography.titleMedium) }
                    items(group.items, key = { it.id }) { item ->
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(item.category)
                                Text(item.note ?: "Tanpa catatan", style = MaterialTheme.typography.bodySmall)
                            }
                            Column(horizontalAlignment = androidx.compose.ui.Alignment.End) {
                                MoneyText(item.amount)
                                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    NataSecondaryButton("Edit", onClick = { onEvent(TransactionHistoryUiEvent.StartEdit(item.id)) })
                                    NataSecondaryButton("Hapus", onClick = { onEvent(TransactionHistoryUiEvent.AskDelete(item.id)) })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    uiState.editingItem?.let { edit ->
        EditTransactionDialog(edit, onDismiss = { onEvent(TransactionHistoryUiEvent.Load) }) { amount, category, note ->
            onEvent(TransactionHistoryUiEvent.SaveEdit(edit.id, amount, category, note))
        }
    }

    uiState.deletingItemId?.let { id ->
        AlertDialog(
            onDismissRequest = { onEvent(TransactionHistoryUiEvent.DismissDelete) },
            title = { Text("Hapus transaksi") },
            text = { Text("Transaksi ini tidak akan dihitung lagi pada dashboard dan laporan.") },
            confirmButton = { TextButton(onClick = { onEvent(TransactionHistoryUiEvent.ConfirmDelete(id)) }) { Text("Hapus") } },
            dismissButton = { TextButton(onClick = { onEvent(TransactionHistoryUiEvent.DismissDelete) }) { Text("Batal") } },
        )
    }
}

@Composable
private fun EditTransactionDialog(
    item: TransactionItemUi,
    onDismiss: () -> Unit,
    onSave: (Long, String, String?) -> Unit,
) {
    var amountText by remember(item.id) { mutableStateOf(item.amount.toString()) }
    var category by remember(item.id) { mutableStateOf(item.category) }
    var note by remember(item.id) { mutableStateOf(item.note.orEmpty()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit transaksi") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = amountText,
                    onValueChange = { amountText = it.filter { ch -> ch.isDigit() } },
                    label = { Text("Nominal") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                )
                OutlinedTextField(category, { category = it }, label = { Text("Kategori") })
                OutlinedTextField(note, { note = it }, label = { Text("Catatan") })
            }
        },
        confirmButton = {
            NataPrimaryButton("Simpan", onClick = {
                onSave(amountText.toLongOrNull() ?: 0L, category, note.ifBlank { null })
                onDismiss()
            })
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Batal") } },
    )
}
