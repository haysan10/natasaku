package com.natasaku.app.domain.usecase

import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.ScheduledPaymentExecutionDao
import com.natasaku.app.domain.model.CategorySpend
import com.natasaku.app.domain.model.DailySpend
import com.natasaku.app.domain.model.DailyStatus
import com.natasaku.app.domain.model.ExpenseTransaction
import com.natasaku.app.domain.model.ExecutionStatus
import com.natasaku.app.domain.model.ReportFilter
import com.natasaku.app.domain.model.ReportGranularity
import com.natasaku.app.domain.model.ReportState
import com.natasaku.app.domain.model.ScheduledPaymentExecution
import com.natasaku.app.domain.model.UnifiedReport
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.YearMonth
import kotlinx.coroutines.flow.first
import javax.inject.Inject

class GenerateUnifiedReportUseCase @Inject constructor(
    private val transactionDao: ExpenseTransactionDao,
    private val budgetPeriodDao: BudgetPeriodDao,
    private val incomeSourceDao: IncomeSourceDao,
    private val fixedExpenseDao: FixedExpenseDao,
    private val savingAllocationDao: SavingAllocationDao,
    private val scheduledPaymentExecutionDao: ScheduledPaymentExecutionDao,
) {
    fun execute(filter: ReportFilter): Flow<ReportState> = flow {
        emit(ReportState.Loading)
        runCatching {
            val activePeriod = budgetPeriodDao.observeActivePeriod().first()
            val selectedPeriod = filter.periodId?.let { budgetPeriodDao.getById(it) }
            val fallbackStart = selectedPeriod?.startDate ?: activePeriod?.startDate ?: LocalDate.now()
            val fallbackEnd = selectedPeriod?.endDate ?: activePeriod?.endDate ?: LocalDate.now()
            val (startDate, endDate) = filter.toDateRange(fallbackStart, fallbackEnd)
            val periodId = when {
                filter.periodId != null -> filter.periodId
                else -> activePeriod?.id
            }

            val tx = if (periodId == null) {
                emptyList()
            } else {
                transactionDao.observeByPeriod(periodId).first().filter { it.date in startDate..endDate }
            }
            val income = if (periodId == null) 0L else incomeSourceDao.observeByPeriod(periodId).first().sumOf { it.amount }
            val fixed = if (periodId == null) 0L else fixedExpenseDao.observeByPeriod(periodId).first().sumOf { it.amount }
            val saving = if (periodId == null) {
                0L
            } else {
                savingAllocationDao.observeByPeriod(periodId).first().filter { it.date in startDate..endDate }.sumOf { it.amount }
            }

            val spent = tx.sumOf { it.amount }
            val flexible = income - fixed - saving
            val remaining = flexible - spent
            val totalDays = (startDate.datesUntil(endDate.plusDays(1)).count().toInt()).coerceAtLeast(1)
            val avgDaily = spent / totalDays
            val byDate = tx.groupBy { it.date }.mapValues { it.value.sumOf { item -> item.amount } }
            val highest = byDate.maxByOrNull { it.value }?.key
            val lowest = byDate.minByOrNull { it.value }?.key
            val allowanceBase = if (flexible <= 0L) 0L else (flexible / totalDays).coerceAtLeast(0L)

            val categoryBreakdown = tx.groupBy { it.category }.entries.mapIndexed { index, entry ->
                val sum = entry.value.sumOf { it.amount }
                CategorySpend(
                    categoryId = index.toLong() + 1,
                    categoryName = entry.key,
                    categoryIcon = "•",
                    totalAmount = sum,
                    transactionCount = entry.value.size,
                    percentage = if (spent <= 0) 0f else (sum * 100f / spent.toFloat()),
                )
            }.sortedByDescending { it.totalAmount }

            val dailySpend = startDate.datesUntil(endDate.plusDays(1)).map { date ->
                val amount = byDate[date] ?: 0L
                DailySpend(
                    date = date,
                    amount = amount,
                    status = when {
                        allowanceBase == 0L && amount > 0L -> DailyStatus.MELEWATI_BATAS
                        allowanceBase == 0L -> DailyStatus.AMAN
                        amount > allowanceBase -> DailyStatus.MELEWATI_BATAS
                        amount > (allowanceBase * 70L / 100L) -> DailyStatus.WASPADA
                        else -> DailyStatus.AMAN
                    },
                )
            }.toList()

            val scheduledExecutions = scheduledPaymentExecutionDao.getByDateRange(startDate, endDate).map {
                ScheduledPaymentExecution(
                    id = it.id,
                    scheduledPaymentId = it.scheduledPaymentId,
                    executedDate = it.executedDate,
                    transactionId = it.transactionId,
                    status = it.status,
                )
            }

            UnifiedReport(
                filter = filter,
                title = buildTitle(filter, startDate, endDate),
                periodLabel = "$startDate – $endDate",
                totalIncome = income,
                totalFixedExpense = fixed,
                totalSavingAllocated = saving,
                totalSpent = spent,
                flexibleBudget = flexible,
                remainingBudget = remaining,
                averageDailySpend = avgDaily,
                highestSpendDay = highest,
                lowestSpendDay = lowest,
                overbudgetDaysCount = dailySpend.count { it.status == DailyStatus.MELEWATI_BATAS },
                categoryBreakdown = categoryBreakdown,
                dailySpendData = dailySpend,
                transactions = tx.map {
                    ExpenseTransaction(
                        id = it.id,
                        periodId = it.periodId,
                        amount = it.amount,
                        category = it.category,
                        date = it.date,
                        note = it.note,
                        createdAt = it.createdAt,
                        updatedAt = it.updatedAt,
                        deletedAt = it.deletedAt,
                    )
                },
                scheduledPaymentsExecuted = scheduledExecutions,
                recommendation = when {
                    remaining < 0 -> "Pengeluaran melebihi dana fleksibel. Coba turunkan pengeluaran kategori terbesar."
                    scheduledExecutions.any { it.status == ExecutionStatus.SKIPPED_NO_ACTIVE_PERIOD } -> "Ada jadwal pembayaran yang terlewat karena periode aktif tidak tersedia."
                    else -> "Pengeluaran masih terkendali. Kamu bisa lanjutkan ritme ini."
                },
            )
        }.onSuccess { report ->
            emit(ReportState.Success(report))
        }.onFailure { error ->
            emit(ReportState.Error(error.localizedMessage ?: "Laporan belum berhasil dibuat."))
        }
    }
        .flowOn(Dispatchers.IO)

    private fun buildTitle(filter: ReportFilter, startDate: LocalDate, endDate: LocalDate): String {
        return when (filter.granularity) {
            ReportGranularity.DAILY -> startDate.toString()
            ReportGranularity.WEEKLY -> "Minggu $startDate – $endDate"
            ReportGranularity.MONTHLY -> YearMonth.from(startDate).toString()
            ReportGranularity.YEARLY -> startDate.year.toString()
            ReportGranularity.BY_PERIOD -> "$startDate – $endDate"
        }
    }
}

private fun ReportFilter.toDateRange(defaultStart: LocalDate, defaultEnd: LocalDate): Pair<LocalDate, LocalDate> {
    return when (granularity) {
        ReportGranularity.DAILY -> {
            val date = targetDate ?: defaultStart
            date to date
        }
        ReportGranularity.WEEKLY -> {
            val start = weekStartDate ?: defaultStart.with(DayOfWeek.MONDAY)
            start to start.plusDays(6)
        }
        ReportGranularity.MONTHLY -> {
            val m = month ?: YearMonth.from(defaultStart)
            m.atDay(1) to m.atEndOfMonth()
        }
        ReportGranularity.YEARLY -> {
            val y = year?.value ?: defaultStart.year
            LocalDate.of(y, 1, 1) to LocalDate.of(y, 12, 31)
        }
        ReportGranularity.BY_PERIOD -> {
            val start = periodStartDate ?: defaultStart
            val end = periodEndDate ?: defaultEnd
            start to end
        }
    }
}
