package com.natasaku.app.presentation.featuretour

import com.natasaku.app.domain.repository.SettingsRepository
import kotlinx.coroutines.flow.first
import javax.inject.Inject

class FeatureTourManager @Inject constructor(
    private val settingsRepository: SettingsRepository,
) {
    suspend fun shouldStart(): Boolean {
        val pref = settingsRepository.observePreferences().first()
        return !pref.tourCompleted
    }

    suspend fun markCompleted() {
        val current = settingsRepository.observePreferences().first()
        settingsRepository.updatePreferences(
            current.copy(tourCompleted = true),
        )
    }
}
