package com.natasaku.app.domain.model

import java.time.Instant
import java.time.LocalDate

data class BudgetPeriod(
    val id: String,
    val name: String,
    val startDate: LocalDate,
    val endDate: LocalDate,
    val isActive: Boolean,
    val createdAt: Instant,
    val updatedAt: Instant,
)

data class IncomeSource(val id: String, val periodId: String, val name: String, val amount: Long)
data class FixedExpense(val id: String, val periodId: String, val name: String, val amount: Long)
enum class FixedExpenseStatus { COMMITTED, PENDING, PAID }
enum class ExpenseSource { MANUAL, FIXED_EXPENSE }
data class ExpenseTransaction(
    val id: String,
    val periodId: String,
    val amount: Long,
    val category: String,
    val date: LocalDate,
    val note: String?,
    val createdAt: Instant,
    val updatedAt: Instant,
    val deletedAt: Instant?,
)
data class SavingTarget(val id: String, val periodId: String, val targetAmount: Long)
data class SavingAllocation(val id: String, val periodId: String, val amount: Long, val date: LocalDate, val source: String)
data class DailyBudgetSnapshot(
    val id: String,
    val periodId: String,
    val date: LocalDate,
    val finalDailyAllowance: Long,
    val spentToday: Long,
    val remainingToday: Long,
)

enum class ThemeMode { SYSTEM, LIGHT, DARK }
enum class DefaultLeftoverAllocation { ASK_EVERY_TIME, NEXT_DAY, SAVING, AUTO_SPLIT, FREE_BALANCE }

data class UserPreference(
    val currencyCode: String = "IDR",
    val themeMode: ThemeMode = ThemeMode.SYSTEM,
    val defaultLeftoverAllocation: DefaultLeftoverAllocation = DefaultLeftoverAllocation.ASK_EVERY_TIME,
    val dailyReminderEnabled: Boolean = false,
    val dailyReminderTime: String = "20:00",
    val onboardingCompleted: Boolean = false,
    val activePeriodId: String? = null,
)
