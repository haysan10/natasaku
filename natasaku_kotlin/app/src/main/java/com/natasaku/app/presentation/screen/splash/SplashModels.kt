package com.natasaku.app.presentation.screen.splash

sealed interface SplashDestination {
    data object Welcome : SplashDestination
    data object SetupPeriod : SplashDestination
    data object Main : SplashDestination
}

data class SplashUiState(
    val destination: SplashDestination? = null,
)

sealed interface SplashUiEvent {
    data object Load : SplashUiEvent
}
