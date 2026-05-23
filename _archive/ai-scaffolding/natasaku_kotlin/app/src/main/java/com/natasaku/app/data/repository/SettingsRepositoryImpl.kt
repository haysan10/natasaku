package com.natasaku.app.data.repository

import com.natasaku.app.data.datastore.UserPreferenceDataStore
import com.natasaku.app.domain.model.UserPreference
import com.natasaku.app.domain.repository.SettingsRepository
import kotlinx.coroutines.flow.Flow

class SettingsRepositoryImpl(private val store: UserPreferenceDataStore) : SettingsRepository {
    override fun observePreferences(): Flow<UserPreference> = store.preferences
    override suspend fun updatePreferences(preference: UserPreference) = store.update(preference)
}
