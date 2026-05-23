package com.natasaku.app.presentation.screen.scheduled_payment

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
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
import com.natasaku.app.core.money.RupiahFormatter
import com.natasaku.app.domain.model.PaymentFrequency
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton
import com.natasaku.app.presentation.component.NominalInputField
import java.time.LocalDate

@Composable
fun ScheduledPaymentRoute(
    modifier: Modifier = Modifier,
    viewModel: ScheduledPaymentViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onEvent(ScheduledPaymentUiEvent.Load) }
    ScheduledPaymentListScreen(uiState, viewModel::onEvent, modifier)
}

@Composable
fun ScheduledPaymentListScreen(
    uiState: ScheduledPaymentUiState,
    onEvent: (ScheduledPaymentUiEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text("Jadwal Pembayaran", style = MaterialTheme.typography.titleLarge)
        Text("Tagihan berulang akan dicatat otomatis saat jatuh tempo.")
        NataPrimaryButton(
            text = "Tambah Jadwal",
            onClick = { onEvent(ScheduledPaymentUiEvent.OpenAddSheet) },
            modifier = Modifier.fillMaxWidth(),
        )
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(uiState.items, key = { it.id }) { item ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(item.name)
                        Text(
                            "${RupiahFormatter().format(item.amount)} • ${item.frequency.name} • ${
                                if (item.dayOfMonth == -1) "Akhir bulan" else "Tgl ${item.dayOfMonth}"
                            }",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Text(
                            item.nextExecutionLabel,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.primary,
                        )
                    }
                    Switch(
                        checked = item.isActive,
                        onCheckedChange = { onEvent(ScheduledPaymentUiEvent.ToggleActive(item.id, item.isActive)) },
                    )
                }
            }
        }
    }

    if (uiState.showAddSheet) {
        AddScheduledPaymentBottomSheet(
            errorMessage = uiState.errorMessage,
            onDismiss = { onEvent(ScheduledPaymentUiEvent.CloseAddSheet) },
            onSave = { name, amountRaw, frequency, dayOfMonth, customIntervalDays, note ->
                onEvent(
                    ScheduledPaymentUiEvent.Save(
                        name = name,
                        amountRaw = amountRaw,
                        frequency = frequency,
                        dayOfMonth = dayOfMonth,
                        customIntervalDays = customIntervalDays,
                        note = note,
                    ),
                )
            },
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddScheduledPaymentBottomSheet(
    errorMessage: String?,
    onDismiss: () -> Unit,
    onSave: (String, String, PaymentFrequency, Int, Int?, String?) -> Unit,
) {
    var name by remember { mutableStateOf("") }
    var amountField by remember { mutableStateOf(TextFieldValue("")) }
    var frequency by remember { mutableStateOf(PaymentFrequency.MONTHLY) }
    var dayOfMonth by remember { mutableIntStateOf(LocalDate.now().dayOfMonth.coerceIn(1, 28)) }
    var customIntervalDays by remember { mutableIntStateOf(7) }
    var note by remember { mutableStateOf("") }

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text("Tambah Jadwal Pembayaran", style = MaterialTheme.typography.titleLarge)
            if (!errorMessage.isNullOrBlank()) {
                Text(errorMessage, color = MaterialTheme.colorScheme.error)
            }
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Nama tagihan") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
            )
            NominalInputField(
                value = amountField,
                onValueChange = { amountField = it },
                label = "Nominal",
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                FilterChip(
                    selected = frequency == PaymentFrequency.WEEKLY,
                    onClick = { frequency = PaymentFrequency.WEEKLY },
                    label = { Text("Mingguan") },
                )
                FilterChip(
                    selected = frequency == PaymentFrequency.MONTHLY,
                    onClick = { frequency = PaymentFrequency.MONTHLY },
                    label = { Text("Bulanan") },
                )
                FilterChip(
                    selected = frequency == PaymentFrequency.CUSTOM_DAYS,
                    onClick = { frequency = PaymentFrequency.CUSTOM_DAYS },
                    label = { Text("Kustom") },
                )
            }
            if (frequency == PaymentFrequency.MONTHLY) {
                OutlinedTextField(
                    value = dayOfMonth.toString(),
                    onValueChange = { dayOfMonth = (it.toIntOrNull() ?: dayOfMonth).coerceIn(1, 28) },
                    label = { Text("Tanggal (1-28)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )
                Text(
                    "Jika bulan tidak punya tanggal ini, akan dieksekusi di hari terakhir bulan tersebut",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            if (frequency == PaymentFrequency.CUSTOM_DAYS) {
                OutlinedTextField(
                    value = customIntervalDays.toString(),
                    onValueChange = { customIntervalDays = (it.toIntOrNull() ?: customIntervalDays).coerceIn(1, 365) },
                    label = { Text("Interval hari (1-365)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )
            }
            OutlinedTextField(
                value = note,
                onValueChange = { note = it.take(200) },
                label = { Text("Catatan") },
                placeholder = { Text("Opsional") },
                modifier = Modifier.fillMaxWidth(),
            )
            NataPrimaryButton(
                text = "Simpan Jadwal",
                onClick = {
                    onSave(
                        name,
                        amountField.text,
                        frequency,
                        dayOfMonth,
                        if (frequency == PaymentFrequency.CUSTOM_DAYS) customIntervalDays else null,
                        note.ifBlank { null },
                    )
                },
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}
