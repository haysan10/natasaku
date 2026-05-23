package com.natasaku.app.presentation.screen.budget

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.domain.calculator.BudgetCalculator
import com.natasaku.app.domain.calculator.DailyBudgetCalculator
import com.natasaku.app.domain.calculator.OverbudgetCalculator
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.LocalDate
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class BudgetUiState(
    val periodLabel: String = "Budget belum dibuat",
    val totalIncome: Long = 0L,
    val totalFixedExpense: Long = 0L,
    val totalSavingTarget: Long = 0L,
    val flexibleFund: Long = 0L,
    val baseDailyAllowance: Long = 0L,
    val adjustment: Long = 0L,
    val finalDailyAllowance: Long = 0L,
    val spentToday: Long = 0L,
    val overbudgetAmount: Long = 0L,
    val fixedExpenseHighWarning: Boolean = false,
)

sealed interface BudgetUiEvent {
    data object Load : BudgetUiEvent
}

@HiltViewModel
class BudgetViewModel @Inject constructor(
    private val budgetPeriodDao: BudgetPeriodDao,
    private val incomeSourceDao: IncomeSourceDao,
    private val fixedExpenseDao: FixedExpenseDao,
    private val savingTargetDao: SavingTargetDao,
    private val transactionDao: ExpenseTransactionDao,
    private val budgetCalculator: BudgetCalculator,
    private val dailyBudgetCalculator: DailyBudgetCalculator,
    private val overbudgetCalculator: OverbudgetCalculator,
) : ViewModel() {
    private val _uiState = MutableStateFlow(BudgetUiState())
    val uiState = _uiState.asStateFlow()

    fun onEvent(event: BudgetUiEvent) {
        when (event) {
            BudgetUiEvent.Load -> load()
        }
    }

    private fun load() = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first() ?: return@launch
        val totalIncome = budgetCalculator.totalIncome(incomeSourceDao.observeByPeriod(period.id).first().map { it.amount })
        val totalFixedExpense = budgetCalculator.totalFixedExpense(fixedExpenseDao.observeByPeriod(period.id).first().map { it.amount })
        val totalSavingTarget = budgetCalculator.totalSavingTarget(listOf(savingTargetDao.observeByPeriod(period.id).first()?.targetAmount ?: 0L))
        val flexibleFund = budgetCalculator.flexibleFund(totalIncome, totalFixedExpense, totalSavingTarget)
        val baseDailyAllowance = dailyBudgetCalculator.calculateBaseDailyAllowance(
            flexibleFund = flexibleFund,
            startDate = period.startDate,
            endDate = period.endDate,
        )

        val today = LocalDate.now()
        val spentToday = transactionDao.observeByPeriod(period.id).first().filter { it.date == today }.sumOf { it.amount }
        val remainingDays = overbudgetCalculator.remainingDaysForAdjustment(today, period.endDate)
        val overbudget = overbudgetCalculator.calculate(baseDailyAllowance, spentToday, remainingDays)
        val adjustment = if (overbudget.overbudgetAmount > 0L && remainingDays > 0) -overbudget.adjustmentPerDay else 0L

        _uiState.update {
            it.copy(
                periodLabel = "${period.startDate} s/d ${period.endDate}",
                totalIncome = totalIncome,
                totalFixedExpense = totalFixedExpense,
                totalSavingTarget = totalSavingTarget,
                flexibleFund = flexibleFund,
                baseDailyAllowance = baseDailyAllowance,
                adjustment = adjustment,
                finalDailyAllowance = baseDailyAllowance + adjustment,
                spentToday = spentToday,
                overbudgetAmount = overbudget.overbudgetAmount,
                fixedExpenseHighWarning = totalIncome > 0L && (totalFixedExpense * 100 / totalIncome) > 80L,
            )
        }
    }
}
