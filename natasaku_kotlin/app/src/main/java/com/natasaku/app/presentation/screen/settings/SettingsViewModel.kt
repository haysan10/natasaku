package com.natasaku.app.presentation.screen.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.BuildConfig
import com.natasaku.app.data.export.BackupRestoreService
import com.natasaku.app.domain.validation.BackupRestoreValidator
import com.natasaku.app.domain.repository.SettingsRepository
import java.time.Instant
import com.natasaku.app.reminder.ReminderScheduler
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val backupRestoreService: BackupRestoreService,
    private val reminderScheduler: ReminderScheduler,
) : ViewModel() {
    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState = _uiState.asStateFlow()

    fun onEvent(event: SettingsUiEvent) {
        when (event) {
            SettingsUiEvent.Load -> load()
            is SettingsUiEvent.ChangeTheme -> updatePref { copy(themeMode = event.mode) }
            is SettingsUiEvent.ChangeLeftover -> updatePref { copy(defaultLeftoverAllocation = event.allocation) }
            is SettingsUiEvent.ToggleDailyReminder -> updatePref { copy(dailyReminderEnabled = event.enabled) }
            is SettingsUiEvent.ChangeReminderTime -> updatePref { copy(dailyReminderTime = event.time) }
            SettingsUiEvent.BackupData -> backup()
            is SettingsUiEvent.PickRestoreJson -> validateRestoreCandidate(event.jsonText, event.fileName)
            is SettingsUiEvent.PickRestoreMode -> _uiState.update { it.copy(restoreMode = event.mode) }
            SettingsUiEvent.CancelRestore -> _uiState.update { it.copy(showRestoreConfirmation = false, restoreCandidateJson = null) }
            SettingsUiEvent.ConfirmRestore -> restoreConfirmed()
            SettingsUiEvent.ClearMessage -> _uiState.update { it.copy(message = null, errorMessage = null) }
        }
    }

    private fun load() = viewModelScope.launch {
        val pref = settingsRepository.observePreferences().first()
        reminderScheduler.sync(pref.dailyReminderEnabled)
        _uiState.update {
            it.copy(
                currencyCode = pref.currencyCode,
                themeMode = pref.themeMode,
                defaultLeftoverAllocation = pref.defaultLeftoverAllocation,
                dailyReminderEnabled = pref.dailyReminderEnabled,
                dailyReminderTime = pref.dailyReminderTime,
                appVersionLabel = "${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})",
                databaseSizeLabel = formatSize(backupRestoreService.getDatabaseSizeBytes()),
            )
        }
    }

    private fun updatePref(transform: com.natasaku.app.domain.model.UserPreference.() -> com.natasaku.app.domain.model.UserPreference) = viewModelScope.launch {
        val current = settingsRepository.observePreferences().first()
        val updated = current.transform()
        settingsRepository.updatePreferences(updated)
        reminderScheduler.sync(updated.dailyReminderEnabled)
        _uiState.update {
            it.copy(
                currencyCode = updated.currencyCode,
                themeMode = updated.themeMode,
                defaultLeftoverAllocation = updated.defaultLeftoverAllocation,
                dailyReminderEnabled = updated.dailyReminderEnabled,
                dailyReminderTime = updated.dailyReminderTime,
            )
        }
    }

    private fun backup() = viewModelScope.launch {
        _uiState.update { it.copy(isLoading = true, errorMessage = null, message = null) }
        runCatching { withContext(Dispatchers.IO) { backupRestoreService.backup() } }
            .onSuccess { file ->
                val current = settingsRepository.observePreferences().first()
                settingsRepository.updatePreferences(
                    current.copy(lastBackupAtEpochMillis = Instant.now().toEpochMilli()),
                )
                _uiState.update { it.copy(isLoading = false, backupFile = file, message = "Backup disimpan: ${file.fileName}") }
            }
            .onFailure { _uiState.update { it.copy(isLoading = false, errorMessage = "Backup gagal dibuat. Coba lagi.") } }
    }

    private fun validateRestoreCandidate(jsonText: String, fileName: String?) {
        if (!fileName.isNullOrBlank()) {
            val fileValidation = BackupRestoreValidator.validateFileName(fileName)
            if (!fileValidation.isValid) {
                _uiState.update {
                    it.copy(
                        errorMessage = fileValidation.blockingError,
                        showRestoreConfirmation = false,
                    )
                }
                return
            }
        }
        val parsed = BackupRestoreValidator.parseJsonOrError(jsonText)
        if (parsed.isFailure) {
            _uiState.update { it.copy(errorMessage = "File backup rusak atau bukan dari NataSaku", showRestoreConfirmation = false) }
            return
        }
        val schemaValidation = BackupRestoreValidator.validateSchemaVersion(parsed.getOrThrow())
        if (!schemaValidation.isValid) {
            _uiState.update {
                it.copy(
                    errorMessage = schemaValidation.blockingError,
                    showRestoreConfirmation = false,
                )
            }
            return
        }
        _uiState.update {
            it.copy(
                restoreCandidateJson = jsonText,
                showRestoreConfirmation = true,
                errorMessage = null,
            )
        }
    }

    private fun restoreConfirmed() = viewModelScope.launch {
        val jsonText = _uiState.value.restoreCandidateJson ?: return@launch
        _uiState.update { it.copy(isLoading = true, showRestoreConfirmation = false, errorMessage = null, message = null) }
        val restoreMode = if (_uiState.value.restoreMode == RestoreModeUi.MERGE_APPEND) {
            BackupRestoreService.RestoreMode.MERGE_APPEND
        } else {
            BackupRestoreService.RestoreMode.REPLACE_ALL
        }
        val result = withContext(Dispatchers.IO) { backupRestoreService.restoreFromJson(jsonText, restoreMode) }
        result.onSuccess {
            _uiState.update { it.copy(isLoading = false, restoreCandidateJson = null, message = "Restore berhasil. Data aktif sudah diperbarui.") }
            load()
        }.onFailure { error ->
            _uiState.update { state ->
                state.copy(
                    isLoading = false,
                    errorMessage = error.localizedMessage ?: "File backup tidak bisa dibaca. Pastikan file berasal dari NataSaku.",
                )
            }
        }
    }

    private fun formatSize(bytes: Long): String {
        if (bytes <= 0L) return "0 B"
        val kb = bytes / 1024.0
        if (kb < 1024) return String.format("%.1f KB", kb)
        val mb = kb / 1024.0
        return String.format("%.2f MB", mb)
    }
}
