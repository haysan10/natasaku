package com.natasaku.app.presentation.screen.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.ScheduledPaymentDao
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.domain.calculator.BudgetCalculator
import com.natasaku.app.domain.calculator.DailyBudgetCalculator
import com.natasaku.app.domain.calculator.OverbudgetCalculator
import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.model.FixedExpenseStatus
import com.natasaku.app.domain.repository.SettingsRepository
import com.natasaku.app.domain.validation.ScheduleDueCalculator
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.domain.validation.TransactionInputValidator
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale
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
    private val savingAllocationDao: SavingAllocationDao,
    private val scheduledPaymentDao: ScheduledPaymentDao,
    private val settingsRepository: SettingsRepository,
    private val dailyBudgetSnapshotDao: DailyBudgetSnapshotDao,
    private val budgetCalculator: BudgetCalculator,
    private val dailyBudgetCalculator: DailyBudgetCalculator,
    private val overbudgetCalculator: OverbudgetCalculator,
) : ViewModel() {
    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState = _uiState.asStateFlow()
    private var lastSaveExpenseAt: Long = 0L

    fun onEvent(event: HomeUiEvent) {
        when (event) {
            HomeUiEvent.Load -> loadDashboard()
            HomeUiEvent.OpenAddExpense -> _uiState.update { it.copy(showAddExpenseSheet = true, addExpenseError = null, addExpenseWarning = null, addExpenseMessage = null) }
            HomeUiEvent.CloseAddExpense -> _uiState.update { it.copy(showAddExpenseSheet = false, addExpenseError = null, addExpenseWarning = null) }
            HomeUiEvent.DismissOverbudget -> _uiState.update { it.copy(showOverbudgetDialog = false) }
            is HomeUiEvent.SaveExpense -> saveExpense(event.amount, event.category, event.note, event.date)
            HomeUiEvent.ClearMessage -> _uiState.update { it.copy(addExpenseMessage = null, addExpenseWarning = null) }
            is HomeUiEvent.MarkFixedExpensePaid -> markFixedExpensePaid(event.id)
            is HomeUiEvent.SnoozeFixedExpense -> snoozeFixedExpense(event.id)
            is HomeUiEvent.RescheduleFixedExpense -> rescheduleFixedExpense(event.id, event.dueDay)
            HomeUiEvent.ToggleBalanceVisibility -> _uiState.update { it.copy(isBalanceHidden = !it.isBalanceHidden) }
            HomeUiEvent.ToggleAutoAmankanSisa -> _uiState.update { it.copy(isAutoAmankanSisaEnabled = !it.isAutoAmankanSisaEnabled) }
            is HomeUiEvent.ManualAmankanSisa -> manualAmankanSisa(event.amount)
            HomeUiEvent.DismissBackupReminder -> dismissBackupReminder()
        }
    }

    private fun loadDashboard() = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first()
        if (period == null) {
            _uiState.update {
                it.copy(
                    activePeriodName = "Budget belum dibuat",
                    periodLabel = "",
                    greeting = buildGreeting(),
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

        val savingTargetObj = savingTargetDao.observeByPeriod(period.id).first()
        val savingTargetAmount = savingTargetObj?.targetAmount ?: 0L
        val savingTargetName = savingTargetObj?.name ?: "Dana Darurat 🛡️"

        val savingAllocations = savingAllocationDao.observeByPeriod(period.id).first()
        val savingCollectedAmount = savingAllocations.sumOf { it.amount }

        val totalIncome = budgetCalculator.totalIncome(incomes.map { it.amount })
        val totalFixedExpense = budgetCalculator.totalFixedExpense(refreshedFixedExpenses.map { it.amount })
        val totalSaving = budgetCalculator.totalSavingTarget(listOf(savingTargetAmount))
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
        val preferences = settingsRepository.observePreferences().first()
        val shouldShowBackupReminder = shouldShowBackupReminder(
            lastBackupAtEpochMillis = preferences.lastBackupAtEpochMillis,
            lastDismissedAtEpochMillis = preferences.lastBackupReminderDismissedAtEpochMillis,
            nowEpochMillis = Instant.now().toEpochMilli(),
        )
        val scheduledDueCount = countDueScheduledPayments()

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
        val totalPeriodDays = (period.startDate.datesUntil(period.endDate.plusDays(1)).count().toInt()).coerceAtLeast(1)
        val elapsedDays = period.startDate.datesUntil(LocalDate.now().plusDays(1)).count().toInt()
            .coerceIn(0, totalPeriodDays)
        val periodProgressPct = ((elapsedDays * 100f) / totalPeriodDays).toInt()

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

        // 7 days spending chart calculation
        val past7Days = (0..6).map { LocalDate.now().minusDays(it.toLong()) }.reversed()
        val past7DaysExpenses = past7Days.map { date ->
            transactions.filter { it.date == date && it.deletedAt == null }.sumOf { it.amount }
        }
        val past7DaysLabels = past7Days.map { date ->
            val dayName = date.dayOfWeek.name.lowercase().replaceFirstChar { it.uppercase() }
            when (dayName) {
                "Monday" -> "Sen"
                "Tuesday" -> "Sel"
                "Wednesday" -> "Rab"
                "Thursday" -> "Kam"
                "Friday" -> "Jum"
                "Saturday" -> "Sab"
                "Sunday" -> "Min"
                else -> dayName.take(3)
            }
        }

        // Category breakdowns for today
        val categoryExpenses = transactionsToday.groupBy { it.category }
            .mapValues { it.value.sumOf { tx -> tx.amount } }

        _uiState.update {
            it.copy(
                activePeriodName = period.name,
                periodLabel = formatPeriodLabel(period.startDate, period.endDate),
                greeting = buildGreeting(),
                dailyAllowance = daily.finalDailyAllowance,
                baseDailyAllowance = baseDailyAllowance,
                adjustmentAmount = adjustment,
                spentToday = daily.spentToday,
                remainingToday = daily.remainingToday,
                overbudgetAmount = overbudget.overbudgetAmount,
                status = daily.status,
                monthlyProgressLabel = "Progres periode: $periodProgressPct% • ${transactions.size} transaksi",
                monthlyProgressPercent = periodProgressPct,
                categorySummaryLabel = transactionsToday.groupBy { tx -> tx.category }
                    .maxByOrNull { entry -> entry.value.sumOf { tx -> tx.amount } }
                    ?.key ?: "Belum ada pengeluaran",
                scheduledDueCount = scheduledDueCount,
                showBackupReminderBanner = shouldShowBackupReminder,
                fixedExpenses = refreshedFixedExpenses.map { item ->
                    FixedExpenseUi(
                        id = item.id,
                        name = item.name,
                        amount = item.amount,
                        dueDay = item.dueDay,
                        status = item.status,
                    )
                },
                recentTransactions = transactions.take(5),
                categoryExpenses = categoryExpenses,
                savingTargetAmount = savingTargetAmount,
                savingCollectedAmount = savingCollectedAmount,
                savingTargetName = savingTargetName,
                past7DaysExpenses = past7DaysExpenses,
                past7DaysLabels = past7DaysLabels,
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

    private fun saveExpense(amount: Long, category: String, note: String?, date: LocalDate) {
        val nowMs = System.currentTimeMillis()
        if (nowMs - lastSaveExpenseAt < 500L || _uiState.value.isSavingExpense) {
            return
        }
        lastSaveExpenseAt = nowMs

        val nominalValidation = NominalInputValidator.validate(amount.toString())
        if (!nominalValidation.isValid) {
            _uiState.update { it.copy(addExpenseError = nominalValidation.errorMessage ?: "Nominal belum valid", addExpenseWarning = null) }
            return
        }
        val categoryValidation = TransactionInputValidator.validateCategory(category)
        if (!categoryValidation.isValid) {
            _uiState.update { it.copy(addExpenseError = categoryValidation.blockingError, addExpenseWarning = null) }
            return
        }
        val trimmedNote = TransactionInputValidator.trimNoteToMaxLength(note.orEmpty()).ifBlank { null }

        viewModelScope.launch {
            _uiState.update { it.copy(isSavingExpense = true, addExpenseError = null, addExpenseWarning = null) }
            val period = budgetPeriodDao.observeActivePeriod().first()
            if (period == null) {
                _uiState.update { it.copy(addExpenseError = "Budget aktif belum tersedia.", isSavingExpense = false) }
                return@launch
            }
            val dateValidation = TransactionInputValidator.validateDate(
                transactionDate = date,
                today = LocalDate.now(),
                activePeriodStartDate = period.startDate,
            )
            if (!dateValidation.isValid) {
                _uiState.update { it.copy(addExpenseError = dateValidation.blockingError, isSavingExpense = false) }
                return@launch
            }

            val incomes = incomeSourceDao.observeByPeriod(period.id).first()
            val fixedExpenses = fixedExpenseDao.observeByPeriod(period.id).first()
            val savingTargetAmount = savingTargetDao.observeByPeriod(period.id).first()?.targetAmount ?: 0L
            val totalIncome = budgetCalculator.totalIncome(incomes.map { it.amount })
            val totalFixedExpense = budgetCalculator.totalFixedExpense(fixedExpenses.map { it.amount })
            val flexibleFund = budgetCalculator.flexibleFund(totalIncome, totalFixedExpense, savingTargetAmount)
            val overFlexibleWarning = TransactionInputValidator.validateSingleExpenseAmount(
                amount = nominalValidation.amount,
                flexibleFundTotal = flexibleFund,
            ).warning

            transactionDao.upsert(
                ExpenseTransactionEntity(
                    id = UUID.randomUUID().toString(),
                    periodId = period.id,
                    amount = nominalValidation.amount,
                    category = category.trim(),
                    date = date,
                    note = trimmedNote,
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
                    addExpenseWarning = overFlexibleWarning,
                    addExpenseMessage = "Transaksi dicatat ✓",
                    isSavingExpense = false,
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

    private fun dismissBackupReminder() = viewModelScope.launch {
        val current = settingsRepository.observePreferences().first()
        settingsRepository.updatePreferences(
            current.copy(
                lastBackupReminderDismissedAtEpochMillis = Instant.now().toEpochMilli(),
            ),
        )
        _uiState.update { it.copy(showBackupReminderBanner = false) }
    }

    private suspend fun countDueScheduledPayments(today: LocalDate = LocalDate.now()): Int {
        return scheduledPaymentDao.getActiveNow().count { payment ->
            ScheduleDueCalculator.isScheduledPaymentDue(
                startDate = payment.startDate,
                endDate = payment.endDate,
                frequency = payment.frequency,
                dayOfMonth = payment.dayOfMonth,
                customIntervalDays = payment.customIntervalDays,
                targetDate = today,
            ) || ScheduleDueCalculator.isScheduledPaymentDue(
                startDate = payment.startDate,
                endDate = payment.endDate,
                frequency = payment.frequency,
                dayOfMonth = payment.dayOfMonth,
                customIntervalDays = payment.customIntervalDays,
                targetDate = today.plusDays(1),
            )
        }
    }

    private fun shouldShowBackupReminder(
        lastBackupAtEpochMillis: Long,
        lastDismissedAtEpochMillis: Long,
        nowEpochMillis: Long,
    ): Boolean {
        val thirtyDaysMs = 30L * 24L * 60L * 60L * 1000L
        val fourteenDaysMs = 14L * 24L * 60L * 60L * 1000L
        val staleBackup = nowEpochMillis - lastBackupAtEpochMillis >= thirtyDaysMs
        val canReshow = nowEpochMillis - lastDismissedAtEpochMillis >= fourteenDaysMs
        return staleBackup && canReshow
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

    private fun manualAmankanSisa(amount: Long) = viewModelScope.launch {
        val period = budgetPeriodDao.observeActivePeriod().first() ?: return@launch
        savingAllocationDao.upsert(
            SavingAllocationEntity(
                id = UUID.randomUUID().toString(),
                periodId = period.id,
                amount = amount,
                date = LocalDate.now(),
                source = "MANUAL_SWEEP"
            )
        )
        transactionDao.upsert(
            ExpenseTransactionEntity(
                id = UUID.randomUUID().toString(),
                periodId = period.id,
                amount = amount,
                category = "Tabungan",
                date = LocalDate.now(),
                note = "Amankan sisa jatah harian 🚀",
                createdAt = Instant.now(),
                updatedAt = Instant.now(),
                deletedAt = null,
                source = ExpenseSource.MANUAL,
                fixedExpenseId = null,
            )
        )
        loadDashboard()
    }

    private fun buildGreeting(now: LocalTime = LocalTime.now()): String {
        return when {
            now.isBefore(LocalTime.NOON) -> "Selamat Pagi"
            now.isBefore(LocalTime.of(15, 0)) -> "Selamat Siang"
            now.isBefore(LocalTime.of(19, 0)) -> "Selamat Sore"
            else -> "Selamat Malam"
        }
    }

    private fun formatPeriodLabel(startDate: LocalDate, endDate: LocalDate): String {
        val formatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale("id", "ID"))
        return "${startDate.format(formatter)} – ${endDate.format(formatter)}"
    }
}
