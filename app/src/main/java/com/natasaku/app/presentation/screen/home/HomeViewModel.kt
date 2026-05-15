package com.natasaku.app.presentation.screen.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.domain.calculator.BudgetCalculator
import com.natasaku.app.domain.calculator.DailyBudgetCalculator
import com.natasaku.app.domain.calculator.OverbudgetCalculator
import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.model.FixedExpenseStatus
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.util.UUID
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val budgetPeriodDao: BudgetPeriodDao,
    private val transactionDao: ExpenseTransactionDao,
    private val incomeSourceDao: IncomeSourceDao,
    private val fixedExpenseDao: FixedExpenseDao,
    private val savingTargetDao: SavingTargetDao,
    private val dailyBudgetSnapshotDao: DailyBudgetSnapshotDao,
    private val budgetCalculator: BudgetCalculator,
    private val dailyBudgetCalculator: DailyBudgetCalculator,
    private val overbudgetCalculator: OverbudgetCalculator,
) : ViewModel() {
    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState = _uiState.asStateFlow()

    fun onEvent(event: HomeUiEvent) {
        when (event) {
            HomeUiEvent.Load -> loadDashboard()
            HomeUiEvent.OpenAddExpense -> _uiState.update { it.copy(showAddExpenseSheet = true, addExpenseError = null, addExpenseMessage = null) }
            HomeUiEvent.CloseAddExpense -> _uiState.update { it.copy(showAddExpenseSheet = false, addExpenseError = null) }
            HomeUiEvent.DismissOverbudget -> _uiState.update { it.copy(showOverbudgetDialog = false) }
            is HomeUiEvent.SaveExpense -> saveExpense(event.amount, event.category, event.note)
            HomeUiEvent.ClearMessage -> _uiState.update { it.copy(addExpenseMessage = null) }
            is HomeUiEvent.MarkFixedExpensePaid -> markFixedExpensePaid(event.id)
            is HomeUiEvent.SnoozeFixedExpense -> snoozeFixedExpense(event.id)
            is HomeUiEvent.RescheduleFixedExpense -> rescheduleFixedExpense(event.id, event.dueDay)
        }
    }

    private fun loadDashboard() = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first()
        if (period == null) {
            _uiState.update {
                it.copy(
                    activePeriodName = "Budget belum dibuat",
                    dailyAllowance = 0L,
                    baseDailyAllowance = 0L,
                    adjustmentAmount = 0L,
                    spentToday = 0L,
                    remainingToday = 0L,
                    overbudgetAmount = 0L,
                    status = BudgetStatus.SAFE,
                    monthlyProgressLabel = "Belum ada progres",
                    categorySummaryLabel = "Belum ada pengeluaran",
                    insight = "Atur budget dulu untuk mulai mencatat pengeluaran.",
                )
            }
            return@launch
        }

        val incomes = incomeSourceDao.observeByPeriod(period.id).first()
        val fixedExpenses = fixedExpenseDao.observeByPeriod(period.id).first()
        ensureDueFixedExpensesPending(fixedExpenses)
        val refreshedFixedExpenses = fixedExpenseDao.observeByPeriod(period.id).first()
        val savingTarget = savingTargetDao.observeByPeriod(period.id).first()?.targetAmount ?: 0L

        val totalIncome = budgetCalculator.totalIncome(incomes.map { it.amount })
        val totalFixedExpense = budgetCalculator.totalFixedExpense(refreshedFixedExpenses.map { it.amount })
        val totalSaving = budgetCalculator.totalSavingTarget(listOf(savingTarget))
        val flexibleFund = budgetCalculator.flexibleFund(
            totalIncome = totalIncome,
            totalFixedExpense = totalFixedExpense,
            totalSavingTarget = totalSaving,
        )

        val baseDailyAllowance = dailyBudgetCalculator.calculateBaseDailyAllowance(
            flexibleFund = flexibleFund,
            startDate = period.startDate,
            endDate = period.endDate,
        )

        val today = LocalDate.now()
        val transactions = transactionDao.observeByPeriod(period.id).first()
        val transactionsToday = transactions.filter { it.date == today }
        val spentToday = transactionsToday.sumOf { it.amount }

        val remainingDays = overbudgetCalculator.remainingDaysForAdjustment(
            today = today,
            periodEndDate = period.endDate,
        )
        val overbudget = overbudgetCalculator.calculate(
            finalDailyAllowance = baseDailyAllowance,
            spentToday = spentToday,
            remainingDays = remainingDays,
        )
        val adjustment = if (overbudget.overbudgetAmount > 0L && remainingDays > 0) {
            -overbudget.adjustmentPerDay
        } else {
            0L
        }
        val finalDailyAllowance = baseDailyAllowance + adjustment
        val daily = dailyBudgetCalculator.calculateDailySummary(finalDailyAllowance, spentToday)

        dailyBudgetSnapshotDao.upsert(
            DailyBudgetSnapshotEntity(
                id = "${period.id}_$today",
                periodId = period.id,
                date = today,
                finalDailyAllowance = finalDailyAllowance,
                spentToday = spentToday,
                remainingToday = daily.remainingToday,
            ),
        )

        _uiState.update {
            it.copy(
                activePeriodName = period.name,
                dailyAllowance = daily.finalDailyAllowance,
                baseDailyAllowance = baseDailyAllowance,
                adjustmentAmount = adjustment,
                spentToday = daily.spentToday,
                remainingToday = daily.remainingToday,
                overbudgetAmount = overbudget.overbudgetAmount,
                status = daily.status,
                monthlyProgressLabel = "Tercatat ${transactions.size} transaksi dalam periode ini",
                categorySummaryLabel = transactionsToday.groupBy { tx -> tx.category }
                    .maxByOrNull { entry -> entry.value.sumOf { tx -> tx.amount } }
                    ?.key ?: "Belum ada pengeluaran",
                fixedExpenses = refreshedFixedExpenses.map { item ->
                    FixedExpenseUi(
                        id = item.id,
                        name = item.name,
                        amount = item.amount,
                        dueDay = item.dueDay,
                        status = item.status,
                    )
                },
                insight = when (daily.status) {
                    BudgetStatus.SAFE -> "Aman. Pengeluaranmu masih terkendali."
                    BudgetStatus.WARNING -> "Waspada. Jatah hari ini hampir terpakai."
                    BudgetStatus.OVER_BUDGET -> "Jatah hari ini terlewati. Budget akan disesuaikan agar tetap aman."
                },
            )
        }
    }

    private suspend fun ensureDueFixedExpensesPending(fixedExpenses: List<com.natasaku.app.data.local.entity.FixedExpenseEntity>) {
        val todayDay = LocalDate.now().dayOfMonth
        fixedExpenses
            .filter { it.status == FixedExpenseStatus.COMMITTED && todayDay >= it.dueDay }
            .forEach { fixedExpenseDao.updateStatus(it.id, FixedExpenseStatus.PENDING) }
    }

    private fun saveExpense(amount: Long, category: String, note: String?) {
        if (amount <= 0L) {
            _uiState.update { it.copy(addExpenseError = "Nominal belum valid. Masukkan nominal lebih dari Rp0, ya.") }
            return
        }
        if (category.isBlank()) {
            _uiState.update { it.copy(addExpenseError = "Kategori perlu diisi dulu, ya.") }
            return
        }

        viewModelScope.launch {
            val period = budgetPeriodDao.observeActivePeriod().first()
            if (period == null) {
                _uiState.update { it.copy(addExpenseError = "Budget aktif belum tersedia.") }
                return@launch
            }

            transactionDao.upsert(
                ExpenseTransactionEntity(
                    id = UUID.randomUUID().toString(),
                    periodId = period.id,
                    amount = amount,
                    category = category.trim(),
                    date = LocalDate.now(),
                    note = note,
                    createdAt = Instant.now(),
                    updatedAt = Instant.now(),
                    deletedAt = null,
                    source = ExpenseSource.MANUAL,
                    fixedExpenseId = null,
                ),
            )

            _uiState.update {
                it.copy(
                    showAddExpenseSheet = false,
                    addExpenseError = null,
                    addExpenseMessage = "Pengeluaran berhasil dicatat.",
                )
            }
            loadDashboard()
            if (_uiState.value.status == BudgetStatus.OVER_BUDGET) {
                _uiState.update { it.copy(showOverbudgetDialog = true) }
            }
        }
    }

    private fun markFixedExpensePaid(id: String) = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first() ?: return@launch
        val item = fixedExpenseDao.observeByPeriod(period.id).first().firstOrNull { it.id == id } ?: return@launch
        if (item.status == FixedExpenseStatus.PAID) return@launch

        fixedExpenseDao.updatePaid(id = id, status = FixedExpenseStatus.PAID, paidAt = Instant.now())
        transactionDao.upsert(
            ExpenseTransactionEntity(
                id = UUID.randomUUID().toString(),
                periodId = period.id,
                amount = item.amount,
                category = "Fixed Expense",
                date = LocalDate.now(),
                note = "Pembayaran: ${item.name}",
                createdAt = Instant.now(),
                updatedAt = Instant.now(),
                deletedAt = null,
                source = ExpenseSource.FIXED_EXPENSE,
                fixedExpenseId = item.id,
            ),
        )
        loadDashboard()
    }

    private fun snoozeFixedExpense(id: String) = viewModelScope.launch {
        val now = java.time.ZonedDateTime.now()
        val proposed = now.plusHours(2)
        val next = if (proposed.toLocalTime().isAfter(LocalTime.of(18, 0))) {
            proposed.plusDays(1).withHour(7).withMinute(0).withSecond(0).withNano(0)
        } else {
            proposed
        }.withZoneSameInstant(ZoneId.systemDefault())
        fixedExpenseDao.updateSnooze(
            id = id,
            status = FixedExpenseStatus.PENDING,
            snoozedUntilTs = next.toInstant(),
        )
        loadDashboard()
    }

    private fun rescheduleFixedExpense(id: String, dueDay: Int) = viewModelScope.launch {
        fixedExpenseDao.reschedule(
            id = id,
            status = FixedExpenseStatus.PENDING,
            dueDay = dueDay.coerceIn(1, 31),
        )
        loadDashboard()
    }
}
