package com.natasaku.app.domain.repository

import com.natasaku.app.domain.model.UserPreference
import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    fun observePreferences(): Flow<UserPreference>
    suspend fun updatePreferences(preference: UserPreference)
}
