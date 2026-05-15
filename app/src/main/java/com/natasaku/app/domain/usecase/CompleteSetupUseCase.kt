package com.natasaku.app.domain.usecase

import com.natasaku.app.presentation.screen.setup.SetupUiState

interface CompleteSetupUseCase {
    suspend operator fun invoke(state: SetupUiState)
}
