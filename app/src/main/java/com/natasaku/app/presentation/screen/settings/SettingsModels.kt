package com.natasaku.app.presentation.screen.settings

import com.natasaku.app.domain.model.DefaultLeftoverAllocation
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.domain.model.ThemeMode

data class SettingsUiState(
    val currencyCode: String = "IDR",
    val themeMode: ThemeMode = ThemeMode.SYSTEM,
    val defaultLeftoverAllocation: DefaultLeftoverAllocation = DefaultLeftoverAllocation.ASK_EVERY_TIME,
    val dailyReminderEnabled: Boolean = false,
    val dailyReminderTime: String = "20:00",
    val backupFile: ExportedFileUiModel? = null,
    val restoreCandidateJson: String? = null,
    val showRestoreConfirmation: Boolean = false,
    val isLoading: Boolean = false,
    val message: String? = null,
    val errorMessage: String? = null,
)

sealed interface SettingsUiEvent {
    data object Load : SettingsUiEvent
    data class ChangeTheme(val mode: ThemeMode) : SettingsUiEvent
    data class ChangeLeftover(val allocation: DefaultLeftoverAllocation) : SettingsUiEvent
    data class ToggleDailyReminder(val enabled: Boolean) : SettingsUiEvent
    data class ChangeReminderTime(val time: String) : SettingsUiEvent
    data object BackupData : SettingsUiEvent
    data class PickRestoreJson(val jsonText: String) : SettingsUiEvent
    data object ConfirmRestore : SettingsUiEvent
    data object CancelRestore : SettingsUiEvent
    data object ClearMessage : SettingsUiEvent
}
