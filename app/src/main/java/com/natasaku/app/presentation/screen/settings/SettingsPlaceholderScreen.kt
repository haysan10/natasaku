package com.natasaku.app.presentation.screen.settings

import android.content.Intent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.model.DefaultLeftoverAllocation
import com.natasaku.app.domain.model.ThemeMode
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton

@Composable
fun SettingsRoute(onBack: () -> Unit, viewModel: SettingsViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onEvent(SettingsUiEvent.Load) }
    SettingsScreen(uiState, viewModel::onEvent, onBack)
}

@Composable
fun SettingsScreen(uiState: SettingsUiState, onEvent: (SettingsUiEvent) -> Unit, onBack: () -> Unit) {
    val context = LocalContext.current
    var restoreText by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Text("Pengaturan", style = MaterialTheme.typography.headlineSmall)

        Text("Mata uang")
        Text("${uiState.currencyCode} (lokal)", color = MaterialTheme.colorScheme.onSurfaceVariant)

        Text("Tema")
        ThemeMode.entries.forEach { mode ->
            val label = when (mode) {
                ThemeMode.SYSTEM -> "Ikuti sistem"
                ThemeMode.LIGHT -> "Terang"
                ThemeMode.DARK -> "Gelap"
            }
            NataSecondaryButton(
                text = label,
                onClick = { onEvent(SettingsUiEvent.ChangeTheme(mode)) },
                modifier = Modifier.fillMaxWidth(),
            )
        }

        Text("Default alokasi sisa harian")
        DefaultLeftoverAllocation.entries.forEach { allocation ->
            val label = when (allocation) {
                DefaultLeftoverAllocation.ASK_EVERY_TIME -> "Tanya setiap hari"
                DefaultLeftoverAllocation.NEXT_DAY -> "Tambah ke jatah besok"
                DefaultLeftoverAllocation.SAVING -> "Masukkan ke tabungan"
                DefaultLeftoverAllocation.AUTO_SPLIT -> "Bagi otomatis"
                DefaultLeftoverAllocation.FREE_BALANCE -> "Simpan saldo bebas"
            }
            NataSecondaryButton(
                text = label,
                onClick = { onEvent(SettingsUiEvent.ChangeLeftover(allocation)) },
                modifier = Modifier.fillMaxWidth(),
            )
        }

        Text("Pengingat harian")
        Switch(
            checked = uiState.dailyReminderEnabled,
            onCheckedChange = { onEvent(SettingsUiEvent.ToggleDailyReminder(it)) },
        )
        OutlinedTextField(
            value = uiState.dailyReminderTime,
            onValueChange = { onEvent(SettingsUiEvent.ChangeReminderTime(it)) },
            label = { Text("Waktu pengingat (HH:mm)") },
            modifier = Modifier.fillMaxWidth(),
        )

        Text("Backup data")
        NataPrimaryButton(
            text = "Buat backup JSON",
            onClick = { onEvent(SettingsUiEvent.BackupData) },
            modifier = Modifier.fillMaxWidth(),
            enabled = !uiState.isLoading,
        )

        uiState.backupFile?.let { file ->
            Text("File backup: ${file.fileName}")
            NataSecondaryButton(
                text = "Bagikan file backup",
                onClick = {
                    val i = Intent(Intent.ACTION_SEND).apply {
                        type = file.mimeType
                        putExtra(Intent.EXTRA_STREAM, file.uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    ContextCompat.startActivity(context, Intent.createChooser(i, "Bagikan Backup"), null)
                },
                modifier = Modifier.fillMaxWidth(),
            )
        }

        Text("Restore data")
        OutlinedTextField(
            value = restoreText,
            onValueChange = { restoreText = it },
            label = { Text("Tempel JSON backup") },
            modifier = Modifier.fillMaxWidth(),
            minLines = 4,
        )
        NataPrimaryButton(
            text = "Restore data",
            onClick = { onEvent(SettingsUiEvent.PickRestoreJson(restoreText)) },
            modifier = Modifier.fillMaxWidth(),
            enabled = restoreText.isNotBlank() && !uiState.isLoading,
        )

        Text("Tentang aplikasi")
        Text(
            "NataSaku membantu kamu mengatur budget bulanan secara offline, lokal, dan privat.",
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )

        uiState.message?.let { Text(it, color = MaterialTheme.colorScheme.primary) }
        uiState.errorMessage?.let { Text(it, color = MaterialTheme.colorScheme.error) }

        NataSecondaryButton(text = "Kembali", onClick = onBack, modifier = Modifier.fillMaxWidth())
    }

    if (uiState.showRestoreConfirmation) {
        AlertDialog(
            onDismissRequest = { onEvent(SettingsUiEvent.CancelRestore) },
            title = { Text("Konfirmasi restore") },
            text = { Text("Restore akan mengganti data NataSaku saat ini. Lanjutkan?") },
            confirmButton = { TextButton(onClick = { onEvent(SettingsUiEvent.ConfirmRestore) }) { Text("Restore") } },
            dismissButton = { TextButton(onClick = { onEvent(SettingsUiEvent.CancelRestore) }) { Text("Batal") } },
        )
    }
}
