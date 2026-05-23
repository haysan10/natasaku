package com.natasaku.app.reminder

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDate

private const val PREF_NAME = "natasaku_expense_reminder"
private const val KEY_LAST_EXPENSE_DATE = "last_expense_date"
private const val KEY_LAST_PROMPT_SLOT = "last_prompt_slot"
private const val KEY_MUTE_UNTIL_MS = "mute_until_ms"
private const val KEY_PENDING_TRANSACTIONS = "pending_transactions"
private const val KEY_REMINDER_HOURS = "reminder_hours"

class ExpenseReminderStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

    fun getReminderHours(): List<Int> {
        val raw = prefs.getString(KEY_REMINDER_HOURS, "11,13,15,18") ?: "11,13,15,18"
        return raw
            .split(',')
            .mapNotNull { it.trim().toIntOrNull() }
            .filter { it in 0..23 }
            .distinct()
            .sorted()
            .ifEmpty { listOf(11, 13, 15, 18) }
    }

    fun setReminderHours(hours: List<Int>) {
        val normalized = hours.filter { it in 0..23 }.distinct().sorted().joinToString(",")
        prefs.edit().putString(KEY_REMINDER_HOURS, if (normalized.isBlank()) "11,13,15,18" else normalized).apply()
    }

    fun markExpenseForDate(date: LocalDate = LocalDate.now()) {
        prefs.edit().putString(KEY_LAST_EXPENSE_DATE, date.toString()).apply()
    }

    fun hasExpenseForDate(date: LocalDate = LocalDate.now()): Boolean {
        return prefs.getString(KEY_LAST_EXPENSE_DATE, null) == date.toString()
    }

    fun getMuteUntilMs(): Long = prefs.getLong(KEY_MUTE_UNTIL_MS, 0L)

    fun setMuteUntilMs(value: Long) {
        prefs.edit().putLong(KEY_MUTE_UNTIL_MS, value).apply()
    }

    fun wasPromptedInSlot(slotKey: String): Boolean {
        return prefs.getString(KEY_LAST_PROMPT_SLOT, null) == slotKey
    }

    fun markPromptedSlot(slotKey: String) {
        prefs.edit().putString(KEY_LAST_PROMPT_SLOT, slotKey).apply()
    }

    fun enqueuePendingTransaction(transaction: PendingQuickTransaction) {
        val existing = getPendingTransactionsJsonArray().toMutableList()
        existing += transaction.toJson()
        prefs.edit().putString(KEY_PENDING_TRANSACTIONS, JSONArray(existing).toString()).apply()
    }

    fun consumePendingTransactionsJson(): String {
        val raw = prefs.getString(KEY_PENDING_TRANSACTIONS, "[]") ?: "[]"
        prefs.edit().putString(KEY_PENDING_TRANSACTIONS, "[]").apply()
        return raw
    }

    fun syncFromWebSnapshot(snapshotJson: String) {
        runCatching {
            val obj = JSONObject(snapshotJson)
            val hasExpenseToday = obj.optBoolean("hasExpenseToday", false)
            val date = obj.optString("date", LocalDate.now().toString())
            val reminderHoursCsv = obj.optString("reminderHoursCsv", "").trim()
            if (hasExpenseToday) {
                prefs.edit().putString(KEY_LAST_EXPENSE_DATE, date).apply()
            }
            if (reminderHoursCsv.isNotBlank()) {
                val parsedHours = reminderHoursCsv
                    .split(',')
                    .mapNotNull { it.trim().toIntOrNull() }
                if (parsedHours.isNotEmpty()) {
                    setReminderHours(parsedHours)
                }
            }
        }
    }

    private fun getPendingTransactionsJsonArray(): JSONArray {
        val raw = prefs.getString(KEY_PENDING_TRANSACTIONS, "[]") ?: "[]"
        return runCatching { JSONArray(raw) }.getOrElse { JSONArray() }
    }
}
