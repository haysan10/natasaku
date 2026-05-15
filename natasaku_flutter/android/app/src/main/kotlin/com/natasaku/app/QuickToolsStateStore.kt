package com.natasaku.app

import android.content.Context
import java.text.NumberFormat
import java.time.Instant
import java.util.Locale
import kotlin.math.roundToLong
import org.json.JSONArray
import org.json.JSONObject

data class QuickToolsState(
    val dailySafeBudgetText: String,
    val dailyStatus: String,
    val periodStatus: String,
    val remainingFundText: String,
    val todayExpenseText: String,
    val tomorrowBudgetText: String,
    val advice: String,
    val remainingDays: String,
    val usagePercent: Int,
    val dailySafeBudgetAmount: Long,
    val remainingFundAmount: Long,
    val todayExpenseAmount: Long
)

object QuickToolsStateStore {
    private val localeId = Locale("id", "ID")
    private val currencyFormatter = NumberFormat.getCurrencyInstance(localeId).apply {
        maximumFractionDigits = 0
    }

    private fun defaultState(): QuickToolsState {
        return QuickToolsState(
            dailySafeBudgetText = "Rp0",
            dailyStatus = "Belum aktif",
            periodStatus = "Belum aktif",
            remainingFundText = "Rp0",
            todayExpenseText = "Rp0",
            tomorrowBudgetText = "Rp0",
            advice = "Atur periode agar Quick Tools aktif.",
            remainingDays = "Sisa -",
            usagePercent = 0,
            dailySafeBudgetAmount = 0L,
            remainingFundAmount = 0L,
            todayExpenseAmount = 0L
        )
    }

    fun isNotificationEnabled(context: Context): Boolean {
        val prefs = context.getSharedPreferences(QuickToolsContract.prefsName, Context.MODE_PRIVATE)
        return prefs.getBoolean(QuickToolsContract.keyNotificationEnabled, true)
    }

    fun setNotificationEnabled(context: Context, enabled: Boolean) {
        val prefs = context.getSharedPreferences(QuickToolsContract.prefsName, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(QuickToolsContract.keyNotificationEnabled, enabled).apply()
    }

    fun load(context: Context): QuickToolsState {
        val defaults = defaultState()
        val prefs = context.getSharedPreferences(QuickToolsContract.prefsName, Context.MODE_PRIVATE)

        return QuickToolsState(
            dailySafeBudgetText = prefs.getString(QuickToolsContract.keyDailySafeBudget, defaults.dailySafeBudgetText)
                ?: defaults.dailySafeBudgetText,
            dailyStatus = prefs.getString(QuickToolsContract.keyDailyStatus, defaults.dailyStatus)
                ?: defaults.dailyStatus,
            periodStatus = prefs.getString(QuickToolsContract.keyPeriodStatus, defaults.periodStatus)
                ?: defaults.periodStatus,
            remainingFundText = prefs.getString(QuickToolsContract.keyRemainingFund, defaults.remainingFundText)
                ?: defaults.remainingFundText,
            todayExpenseText = prefs.getString(QuickToolsContract.keyTodayExpense, defaults.todayExpenseText)
                ?: defaults.todayExpenseText,
            tomorrowBudgetText = prefs.getString(QuickToolsContract.keyTomorrowBudget, defaults.tomorrowBudgetText)
                ?: defaults.tomorrowBudgetText,
            advice = prefs.getString(QuickToolsContract.keyAdvice, defaults.advice)
                ?: defaults.advice,
            remainingDays = prefs.getString(QuickToolsContract.keyRemainingDays, defaults.remainingDays)
                ?: defaults.remainingDays,
            usagePercent = prefs.getInt(QuickToolsContract.keyUsagePercent, defaults.usagePercent).coerceIn(0, 100),
            dailySafeBudgetAmount = prefs.getLong(
                QuickToolsContract.keyDailySafeBudgetAmount,
                defaults.dailySafeBudgetAmount
            ),
            remainingFundAmount = prefs.getLong(
                QuickToolsContract.keyRemainingFundAmount,
                defaults.remainingFundAmount
            ),
            todayExpenseAmount = prefs.getLong(
                QuickToolsContract.keyTodayExpenseAmount,
                defaults.todayExpenseAmount
            )
        )
    }

    fun save(context: Context, state: QuickToolsState) {
        val prefs = context.getSharedPreferences(QuickToolsContract.prefsName, Context.MODE_PRIVATE)
        prefs.edit()
            .putString(QuickToolsContract.keyDailySafeBudget, state.dailySafeBudgetText)
            .putString(QuickToolsContract.keyDailyStatus, state.dailyStatus)
            .putString(QuickToolsContract.keyPeriodStatus, state.periodStatus)
            .putString(QuickToolsContract.keyRemainingFund, state.remainingFundText)
            .putString(QuickToolsContract.keyTodayExpense, state.todayExpenseText)
            .putString(QuickToolsContract.keyTomorrowBudget, state.tomorrowBudgetText)
            .putString(QuickToolsContract.keyAdvice, state.advice)
            .putString(QuickToolsContract.keyRemainingDays, state.remainingDays)
            .putInt(QuickToolsContract.keyUsagePercent, state.usagePercent.coerceIn(0, 100))
            .putLong(QuickToolsContract.keyDailySafeBudgetAmount, state.dailySafeBudgetAmount)
            .putLong(QuickToolsContract.keyRemainingFundAmount, state.remainingFundAmount)
            .putLong(QuickToolsContract.keyTodayExpenseAmount, state.todayExpenseAmount)
            .apply()
    }

    fun saveFromMap(context: Context, args: Map<*, *>): QuickToolsState {
        val current = load(context)

        val dailySafeBudgetAmount = parseMoneyAmount(args[QuickToolsContract.keyDailySafeBudgetAmount], current.dailySafeBudgetAmount)
        val remainingFundAmount = parseMoneyAmount(args[QuickToolsContract.keyRemainingFundAmount], current.remainingFundAmount)
        val todayExpenseAmount = parseMoneyAmount(args[QuickToolsContract.keyTodayExpenseAmount], current.todayExpenseAmount)

        val updated = QuickToolsState(
            dailySafeBudgetText = args[QuickToolsContract.keyDailySafeBudget]?.toString() ?: current.dailySafeBudgetText,
            dailyStatus = args[QuickToolsContract.keyDailyStatus]?.toString() ?: current.dailyStatus,
            periodStatus = args[QuickToolsContract.keyPeriodStatus]?.toString() ?: current.periodStatus,
            remainingFundText = args[QuickToolsContract.keyRemainingFund]?.toString() ?: current.remainingFundText,
            todayExpenseText = args[QuickToolsContract.keyTodayExpense]?.toString() ?: current.todayExpenseText,
            tomorrowBudgetText = args[QuickToolsContract.keyTomorrowBudget]?.toString() ?: current.tomorrowBudgetText,
            advice = args[QuickToolsContract.keyAdvice]?.toString() ?: current.advice,
            remainingDays = args[QuickToolsContract.keyRemainingDays]?.toString() ?: current.remainingDays,
            usagePercent = parseInt(args[QuickToolsContract.keyUsagePercent], current.usagePercent).coerceIn(0, 100),
            dailySafeBudgetAmount = dailySafeBudgetAmount,
            remainingFundAmount = remainingFundAmount,
            todayExpenseAmount = todayExpenseAmount
        )

        save(context, updated)
        return updated
    }

    fun registerQuickExpense(context: Context, amount: Long): QuickToolsState {
        val current = load(context)
        val newTodayExpense = current.todayExpenseAmount + amount
        val newRemainingFund = current.remainingFundAmount - amount

        val usage = if (current.dailySafeBudgetAmount <= 0L) {
            0
        } else {
            ((newTodayExpense.toDouble() / current.dailySafeBudgetAmount.toDouble()) * 100.0)
                .roundToLong()
                .toInt()
                .coerceIn(0, 100)
        }

        val nextStatus = when {
            current.dailySafeBudgetAmount <= 0L -> "Belum aktif"
            usage == 0 -> "Belum Ada Pengeluaran"
            usage < 80 -> "Aman Terkendali"
            usage < 100 -> "Mendekati Batas"
            usage < 120 -> "Melebihi Sedikit"
            else -> "Boros"
        }

        val updated = current.copy(
            todayExpenseAmount = newTodayExpense,
            remainingFundAmount = newRemainingFund,
            todayExpenseText = formatCurrency(newTodayExpense),
            remainingFundText = formatCurrency(newRemainingFund),
            usagePercent = usage,
            dailyStatus = nextStatus,
            advice = if (usage >= 100) {
                "Batas hari ini terlewati, tahan dulu belanja non-prioritas."
            } else {
                "Transaksi cepat tercatat dari notifikasi."
            }
        )

        save(context, updated)
        appendExpenseToFlutterStorage(context, amount)
        return updated
    }

    private fun appendExpenseToFlutterStorage(context: Context, amount: Long) {
        val prefs = context.getSharedPreferences(QuickToolsContract.flutterPrefsName, Context.MODE_PRIVATE)
        val raw = prefs.getString(QuickToolsContract.flutterTransactionsKey, "[]") ?: "[]"
        val items = try {
            JSONArray(raw)
        } catch (_: Exception) {
            JSONArray()
        }

        val now = Instant.now().toString()
        val tx = JSONObject()
            .put("id", System.currentTimeMillis().toString())
            .put("date", now)
            .put("amount", amount.toDouble())
            .put("isExpense", true)
            .put("note", "Catat Cepat (Notifikasi)")
            .put("category", "Lainnya")

        items.put(tx)
        prefs.edit().putString(QuickToolsContract.flutterTransactionsKey, items.toString()).apply()
    }

    private fun parseInt(value: Any?, fallback: Int): Int {
        return when (value) {
            is Int -> value
            is Long -> value.toInt()
            is Double -> value.roundToLong().toInt()
            is Float -> value.roundToLong().toInt()
            else -> value?.toString()?.toIntOrNull() ?: fallback
        }
    }

    private fun parseMoneyAmount(value: Any?, fallback: Long): Long {
        return when (value) {
            is Long -> value
            is Int -> value.toLong()
            is Double -> value.roundToLong()
            is Float -> value.roundToLong()
            else -> value?.toString()?.toDoubleOrNull()?.roundToLong() ?: fallback
        }
    }

    private fun formatCurrency(amount: Long): String {
        val normalized = currencyFormatter.format(amount)
        return normalized
            .replace("Rp", "Rp")
            .replace("\u00A0", "")
            .replace(" ", "")
    }
}
