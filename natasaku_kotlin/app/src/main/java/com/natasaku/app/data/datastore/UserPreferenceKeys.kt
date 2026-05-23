package com.natasaku.app.data.datastore

import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey

object UserPreferenceKeys {
    val currencyCode = stringPreferencesKey("currency_code")
    val themeMode = stringPreferencesKey("theme_mode")
    val defaultLeftoverAllocation = stringPreferencesKey("default_leftover_allocation")
    val dailyReminderEnabled = booleanPreferencesKey("daily_reminder_enabled")
    val dailyReminderTime = stringPreferencesKey("daily_reminder_time")
    val onboardingCompleted = booleanPreferencesKey("onboarding_completed")
    val activePeriodId = stringPreferencesKey("active_period_id")
    val migrationV1Done = booleanPreferencesKey("migration_v1_done")
    val lastBackupAtEpochMillis = longPreferencesKey("last_backup_at_epoch_millis")
    val lastBackupReminderDismissedAtEpochMillis = longPreferencesKey("last_backup_reminder_dismissed_at_epoch_millis")
    val tourCompleted = booleanPreferencesKey("tour_completed")
}
