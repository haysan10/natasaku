package com.natasaku.app.presentation.screen.home

import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.domain.model.FixedExpenseStatus

data class FixedExpenseUi(
    val id: String,
    val name: String,
    val amount: Long,
    val dueDay: Int,
    val status: FixedExpenseStatus,
)

data class HomeUiState(
    val greeting: String = "Halo, Ini",
    val activePeriodName: String = "",
    val dailyAllowance: Long = 0L,
    val baseDailyAllowance: Long = 0L,
    val adjustmentAmount: Long = 0L,
    val spentToday: Long = 0L,
    val remainingToday: Long = 0L,
    val overbudgetAmount: Long = 0L,
    val status: BudgetStatus = BudgetStatus.SAFE,
    val monthlyProgressLabel: String = "Belum ada progres",
    val monthlyProgressPercent: Int = 0,
    val categorySummaryLabel: String = "Belum ada pengeluaran",
    val insight: String = "Aman. Pengeluaranmu masih terkendali.",
    val periodLabel: String = "",
    val scheduledDueCount: Int = 0,
    val showBackupReminderBanner: Boolean = false,
    val showAddExpenseSheet: Boolean = false,
    val showOverbudgetDialog: Boolean = false,
    val addExpenseError: String? = null,
    val addExpenseWarning: String? = null,
    val addExpenseMessage: String? = null,
    val isSavingExpense: Boolean = false,
    val fixedExpenses: List<FixedExpenseUi> = emptyList(),
    val recentTransactions: List<com.natasaku.app.data.local.entity.ExpenseTransactionEntity> = emptyList(),
    val categoryExpenses: Map<String, Long> = emptyMap(),
    val savingTargetAmount: Long = 0L,
    val savingCollectedAmount: Long = 0L,
    val savingTargetName: String = "",
    val past7DaysExpenses: List<Long> = emptyList(),
    val past7DaysLabels: List<String> = emptyList(),
    val isBalanceHidden: Boolean = false,
    val isAutoAmankanSisaEnabled: Boolean = false,
)

sealed interface HomeUiEvent {
    data object Load : HomeUiEvent
    data object OpenAddExpense : HomeUiEvent
    data object CloseAddExpense : HomeUiEvent
    data object DismissOverbudget : HomeUiEvent
    data class SaveExpense(
        val amount: Long,
        val category: String,
        val note: String?,
        val date: java.time.LocalDate,
    ) : HomeUiEvent
    data object ClearMessage : HomeUiEvent
    data class MarkFixedExpensePaid(val id: String) : HomeUiEvent
    data class SnoozeFixedExpense(val id: String) : HomeUiEvent
    data class RescheduleFixedExpense(val id: String, val dueDay: Int) : HomeUiEvent
    data object ToggleBalanceVisibility : HomeUiEvent
    data object ToggleAutoAmankanSisa : HomeUiEvent
    data class ManualAmankanSisa(val amount: Long) : HomeUiEvent
    data object DismissBackupReminder : HomeUiEvent
}
