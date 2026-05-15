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
    val categorySummaryLabel: String = "Belum ada pengeluaran",
    val insight: String = "Aman. Pengeluaranmu masih terkendali.",
    val showAddExpenseSheet: Boolean = false,
    val showOverbudgetDialog: Boolean = false,
    val addExpenseError: String? = null,
    val addExpenseMessage: String? = null,
    val fixedExpenses: List<FixedExpenseUi> = emptyList(),
)

sealed interface HomeUiEvent {
    data object Load : HomeUiEvent
    data object OpenAddExpense : HomeUiEvent
    data object CloseAddExpense : HomeUiEvent
    data object DismissOverbudget : HomeUiEvent
    data class SaveExpense(val amount: Long, val category: String, val note: String?) : HomeUiEvent
    data object ClearMessage : HomeUiEvent
    data class MarkFixedExpensePaid(val id: String) : HomeUiEvent
    data class SnoozeFixedExpense(val id: String) : HomeUiEvent
    data class RescheduleFixedExpense(val id: String, val dueDay: Int) : HomeUiEvent
}
