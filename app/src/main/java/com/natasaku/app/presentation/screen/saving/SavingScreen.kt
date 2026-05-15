package com.natasaku.app.presentation.screen.saving

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.model.LeftoverAllocationType
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton

@Composable
fun SavingRoute(
    modifier: Modifier = Modifier,
    viewModel: SavingViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onEvent(SavingUiEvent.Load) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text("Tabungan", style = MaterialTheme.typography.titleLarge)
        if (!uiState.hasTarget) {
            Text("Belum ada target tabungan")
            Text("Kamu bisa mulai dari nominal kecil dulu.")
        } else {
            Text("Target")
            MoneyText(uiState.targetAmount)
            Text("Total terkumpul")
            MoneyText(uiState.totalCollected)
            LinearProgressIndicator(progress = { uiState.progress }, modifier = Modifier.fillMaxWidth())
            Text("Terkumpul ${com.natasaku.app.core.money.RupiahFormatter().format(uiState.totalCollected)} dari target ${com.natasaku.app.core.money.RupiahFormatter().format(uiState.targetAmount)}.")
        }

        Text("Riwayat alokasi")
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(uiState.history, key = { it.id }) { item ->
                Text("${item.date} • ${item.source}")
                MoneyText(item.amount)
            }
        }
    }

    if (uiState.showLeftoverDialog) {
        AlertDialog(
            onDismissRequest = { viewModel.onEvent(SavingUiEvent.DismissLeftover) },
            title = { Text("Ada sisa jatah hari ini") },
            text = { Text("Kamu masih punya sisa. Mau dialokasikan ke mana?") },
            confirmButton = {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    NataPrimaryButton(text = "Tambah ke jatah besok", onClick = { viewModel.onEvent(SavingUiEvent.AllocateLeftover(LeftoverAllocationType.NEXT_DAY)) })
                    NataPrimaryButton(text = "Masukkan ke tabungan", onClick = { viewModel.onEvent(SavingUiEvent.AllocateLeftover(LeftoverAllocationType.SAVING)) })
                    NataPrimaryButton(text = "Bagi otomatis", onClick = { viewModel.onEvent(SavingUiEvent.AllocateLeftover(LeftoverAllocationType.AUTO_SPLIT)) })
                    NataPrimaryButton(text = "Simpan saldo bebas", onClick = { viewModel.onEvent(SavingUiEvent.AllocateLeftover(LeftoverAllocationType.FREE_BALANCE)) })
                }
            },
            dismissButton = { TextButton(onClick = { viewModel.onEvent(SavingUiEvent.DismissLeftover) }) { Text("Nanti") } },
        )
    }
}
