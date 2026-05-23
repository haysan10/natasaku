package com.natasaku.app.presentation.screen.saving

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.weight
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.model.LeftoverAllocationType
import com.natasaku.app.domain.model.SavingFrequency
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataProgressBar
import com.natasaku.app.presentation.component.NataSecondaryButton
import com.natasaku.app.presentation.component.NominalInputField
import java.time.LocalDate

@Composable
fun SavingRoute(
    modifier: Modifier = Modifier,
    viewModel: SavingViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val snackbarHostState = remember { SnackbarHostState() }
    LaunchedEffect(Unit) { viewModel.onEvent(SavingUiEvent.Load) }
    LaunchedEffect(uiState.infoMessage, uiState.errorMessage) {
        val message = uiState.errorMessage ?: uiState.infoMessage ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(message)
        viewModel.onEvent(SavingUiEvent.ClearMessage)
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(snackbarHostState) },
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
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
                NataProgressBar(progress = uiState.progress, modifier = Modifier.fillMaxWidth())
                Text("Progress ${(uiState.progress * 100).toInt()}%")
                Text("Terkumpul ${com.natasaku.app.core.money.RupiahFormatter().format(uiState.totalCollected)} dari target ${com.natasaku.app.core.money.RupiahFormatter().format(uiState.targetAmount)}.")
            }

            Text("Riwayat alokasi")
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(uiState.history, key = { it.id }) { item ->
                    Text("${item.date} • ${item.source}")
                    MoneyText(item.amount)
                }
            }

            Text("Jadwal Otomatis", style = MaterialTheme.typography.titleMedium)
            if (uiState.scheduledSavings.isEmpty()) {
                Text("Belum ada jadwal otomatis tabungan.")
            }
            NataSecondaryButton(
                text = "Atur Jadwal Otomatis",
                onClick = { viewModel.onEvent(SavingUiEvent.OpenAddScheduleSheet) },
                modifier = Modifier.fillMaxWidth(),
            )
            uiState.scheduledSavings.forEach { schedule ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(schedule.name, style = MaterialTheme.typography.bodyLarge)
                        Text(
                            "${com.natasaku.app.core.money.RupiahFormatter().format(schedule.amountPerExecution)} • ${schedule.frequencyLabel}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Text(
                            schedule.nextExecutionLabel,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.primary,
                        )
                    }
                    Switch(
                        checked = schedule.isActive,
                        onCheckedChange = { viewModel.onEvent(SavingUiEvent.ToggleScheduleActive(schedule.id, schedule.isActive)) },
                    )
                }
            }

            if (uiState.scheduleExecutionHistory.isNotEmpty()) {
                Text("Riwayat eksekusi jadwal", style = MaterialTheme.typography.titleSmall)
                LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(uiState.scheduleExecutionHistory, key = { it.id }) { item ->
                        Text("${item.date} • ${item.source}")
                        MoneyText(item.amount)
                    }
                }
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

    if (uiState.showAddScheduleSheet) {
        AddScheduledSavingBottomSheet(
            errorMessage = uiState.errorMessage,
            onDismiss = { viewModel.onEvent(SavingUiEvent.CloseAddScheduleSheet) },
            onSave = { name, amountRaw, frequency, dayOfMonth, dayOfWeek ->
                viewModel.onEvent(
                    SavingUiEvent.SaveSchedule(
                        name = name,
                        amountRaw = amountRaw,
                        frequency = frequency,
                        dayOfMonth = dayOfMonth,
                        dayOfWeek = dayOfWeek,
                    ),
                )
            },
        )
    }
}

@Composable
private fun AddScheduledSavingBottomSheet(
    errorMessage: String?,
    onDismiss: () -> Unit,
    onSave: (String, String, SavingFrequency, Int?, Int?) -> Unit,
) {
    var name by remember { mutableStateOf("") }
    var amountField by remember { mutableStateOf(TextFieldValue("")) }
    var frequency by remember { mutableStateOf(SavingFrequency.WEEKLY) }
    var dayOfWeek by remember { mutableIntStateOf(LocalDate.now().dayOfWeek.value.coerceIn(1, 7)) }
    var dayOfMonth by remember { mutableIntStateOf(LocalDate.now().dayOfMonth.coerceIn(1, 28)) }

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text("Atur Jadwal Otomatis", style = MaterialTheme.typography.titleLarge)
            if (!errorMessage.isNullOrBlank()) {
                Text(errorMessage, color = MaterialTheme.colorScheme.error)
            }
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Nama jadwal") },
                placeholder = { Text("Contoh: Tabungan rutin") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
            )
            NominalInputField(
                value = amountField,
                onValueChange = { amountField = it },
                label = "Nominal per eksekusi",
            )
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                item {
                    FilterChip(
                        selected = frequency == SavingFrequency.DAILY,
                        onClick = { frequency = SavingFrequency.DAILY },
                        label = { Text("Harian") },
                    )
                }
                item {
                    FilterChip(
                        selected = frequency == SavingFrequency.WEEKLY,
                        onClick = { frequency = SavingFrequency.WEEKLY },
                        label = { Text("Mingguan") },
                    )
                }
                item {
                    FilterChip(
                        selected = frequency == SavingFrequency.MONTHLY,
                        onClick = { frequency = SavingFrequency.MONTHLY },
                        label = { Text("Bulanan") },
                    )
                }
            }
            if (frequency == SavingFrequency.WEEKLY) {
                OutlinedTextField(
                    value = dayOfWeek.toString(),
                    onValueChange = { value -> dayOfWeek = (value.toIntOrNull() ?: dayOfWeek).coerceIn(1, 7) },
                    label = { Text("Hari ke- (1=Senin..7=Minggu)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )
            }
            if (frequency == SavingFrequency.MONTHLY) {
                OutlinedTextField(
                    value = dayOfMonth.toString(),
                    onValueChange = { value -> dayOfMonth = (value.toIntOrNull() ?: dayOfMonth).coerceIn(1, 28) },
                    label = { Text("Tanggal (1-28)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )
            }
            NataPrimaryButton(
                text = "Simpan Jadwal",
                onClick = {
                    onSave(
                        name.trim(),
                        amountField.text,
                        frequency,
                        if (frequency == SavingFrequency.MONTHLY) dayOfMonth else null,
                        if (frequency == SavingFrequency.WEEKLY) dayOfWeek else null,
                    )
                },
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}
