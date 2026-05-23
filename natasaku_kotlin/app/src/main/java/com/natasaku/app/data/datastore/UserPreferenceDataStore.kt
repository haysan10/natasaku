package com.natasaku.app.data.datastore

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.preferencesDataStore
import com.natasaku.app.domain.model.DefaultLeftoverAllocation
import com.natasaku.app.domain.model.ThemeMode
import com.natasaku.app.domain.model.UserPreference
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "natasaku_preferences")

class UserPreferenceDataStore(private val context: Context) {
    val preferences: Flow<UserPreference> = context.dataStore.data.map { prefs ->
        UserPreference(
            currencyCode = prefs[UserPreferenceKeys.currencyCode] ?: "IDR",
            themeMode = runCatching { ThemeMode.valueOf(prefs[UserPreferenceKeys.themeMode] ?: ThemeMode.SYSTEM.name) }.getOrDefault(ThemeMode.SYSTEM),
            defaultLeftoverAllocation = runCatching {
                DefaultLeftoverAllocation.valueOf(prefs[UserPreferenceKeys.defaultLeftoverAllocation] ?: DefaultLeftoverAllocation.ASK_EVERY_TIME.name)
            }.getOrDefault(DefaultLeftoverAllocation.ASK_EVERY_TIME),
            dailyReminderEnabled = prefs[UserPreferenceKeys.dailyReminderEnabled] ?: false,
            dailyReminderTime = prefs[UserPreferenceKeys.dailyReminderTime] ?: "20:00",
            onboardingCompleted = prefs[UserPreferenceKeys.onboardingCompleted] ?: false,
            activePeriodId = prefs[UserPreferenceKeys.activePeriodId],
            migrationV1Done = prefs[UserPreferenceKeys.migrationV1Done] ?: false,
            lastBackupAtEpochMillis = prefs[UserPreferenceKeys.lastBackupAtEpochMillis] ?: 0L,
            lastBackupReminderDismissedAtEpochMillis = prefs[UserPreferenceKeys.lastBackupReminderDismissedAtEpochMillis] ?: 0L,
            tourCompleted = prefs[UserPreferenceKeys.tourCompleted] ?: false,
        )
    }

    suspend fun update(preference: UserPreference) {
        context.dataStore.edit { prefs ->
            prefs[UserPreferenceKeys.currencyCode] = preference.currencyCode
            prefs[UserPreferenceKeys.themeMode] = preference.themeMode.name
            prefs[UserPreferenceKeys.defaultLeftoverAllocation] = preference.defaultLeftoverAllocation.name
            prefs[UserPreferenceKeys.dailyReminderEnabled] = preference.dailyReminderEnabled
            prefs[UserPreferenceKeys.dailyReminderTime] = preference.dailyReminderTime
            prefs[UserPreferenceKeys.onboardingCompleted] = preference.onboardingCompleted
            prefs[UserPreferenceKeys.migrationV1Done] = preference.migrationV1Done
            prefs[UserPreferenceKeys.lastBackupAtEpochMillis] = preference.lastBackupAtEpochMillis
            prefs[UserPreferenceKeys.lastBackupReminderDismissedAtEpochMillis] = preference.lastBackupReminderDismissedAtEpochMillis
            prefs[UserPreferenceKeys.tourCompleted] = preference.tourCompleted
            if (preference.activePeriodId == null) {
                prefs.remove(UserPreferenceKeys.activePeriodId)
            } else {
                prefs[UserPreferenceKeys.activePeriodId] = preference.activePeriodId
            }
        }
    }
}
