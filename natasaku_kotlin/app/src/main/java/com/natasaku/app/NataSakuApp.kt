package com.natasaku.app

import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.model.ThemeMode
import com.natasaku.app.presentation.screen.settings.SettingsViewModel
import com.natasaku.app.presentation.navigation.NataSakuNavHost
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun NataSakuApp() {
    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val uiState = settingsViewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) {
        settingsViewModel.onEvent(com.natasaku.app.presentation.screen.settings.SettingsUiEvent.Load)
    }
    val darkTheme = when (uiState.value.themeMode) {
        ThemeMode.SYSTEM -> androidx.compose.foundation.isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
    NataSakuTheme(darkTheme = darkTheme) {
        Surface {
            NataSakuNavHost()
        }
    }
}
