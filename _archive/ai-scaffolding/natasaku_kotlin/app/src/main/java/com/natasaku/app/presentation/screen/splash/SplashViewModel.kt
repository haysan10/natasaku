package com.natasaku.app.presentation.screen.splash

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.domain.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class SplashViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val budgetPeriodDao: BudgetPeriodDao,
) : ViewModel() {
    private val _uiState = MutableStateFlow(SplashUiState())
    val uiState = _uiState.asStateFlow()

    fun onEvent(event: SplashUiEvent) {
        when (event) {
            SplashUiEvent.Load -> resolveDestination()
        }
    }

    private fun resolveDestination() = viewModelScope.launch {
        val preference = settingsRepository.observePreferences().first()
        val activePeriod = budgetPeriodDao.observeActivePeriod().first()
        val destination = when {
            activePeriod != null -> SplashDestination.Main
            preference.onboardingCompleted -> SplashDestination.SetupPeriod
            else -> SplashDestination.Welcome
        }
        _uiState.update { it.copy(destination = destination) }
    }
}
