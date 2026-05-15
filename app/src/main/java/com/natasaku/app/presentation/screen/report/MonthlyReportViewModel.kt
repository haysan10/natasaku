package com.natasaku.app.presentation.screen.report

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.export.MonthlyReportExporters
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.domain.calculator.DailyBudgetCalculator
import com.natasaku.app.domain.calculator.MonthlyReportCalculator
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.LocalDate
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@HiltViewModel
class MonthlyReportViewModel @Inject constructor(
    private val budgetPeriodDao: BudgetPeriodDao,
    private val incomeSourceDao: IncomeSourceDao,
    private val transactionDao: ExpenseTransactionDao,
    private val fixedExpenseDao: FixedExpenseDao,
    private val savingAllocationDao: SavingAllocationDao,
    private val monthlyReportCalculator: MonthlyReportCalculator,
    private val dailyBudgetCalculator: DailyBudgetCalculator,
    private val exporters: MonthlyReportExporters,
) : ViewModel() {
    private val _uiState = MutableStateFlow(MonthlyReportUiState())
    val uiState = _uiState.asStateFlow()

    fun onEvent(event: MonthlyReportUiEvent) {
        when (event) {
            MonthlyReportUiEvent.Load -> load()
            MonthlyReportUiEvent.ExportCsv -> exportCsv()
            MonthlyReportUiEvent.ExportPdf -> exportPdf()
            MonthlyReportUiEvent.ClearExport -> _uiState.update { it.copy(exportedFile = null, errorMessage = null) }
        }
    }

    private fun load() = viewModelScope.launch {
        _uiState.update { it.copy(isLoading = true, errorMessage = null) }
        val period = budgetPeriodDao.observeActivePeriod().first()
        if (period == null) {
            _uiState.update { it.copy(isLoading = false, errorMessage = "Budget aktif belum tersedia.") }
            return@launch
        }
        val txs = transactionDao.observeByPeriod(period.id).first()
        val totalIncome = incomeSourceDao.observeByPeriod(period.id).first().sumOf { it.amount }
        val fixed = fixedExpenseDao.observeByPeriod(period.id).first().sumOf { it.amount }
        val totalExpense = txs.sumOf { it.amount }
        val totalSaving = savingAllocationDao.observeByPeriod(period.id).first().sumOf { it.amount }
        val periodDays = period.startDate.datesUntil(period.endDate.plusDays(1)).count().toInt()

        val flexibleFund = totalIncome - fixed - totalSaving
        val baseDailyAllowance = dailyBudgetCalculator.calculateBaseDailyAllowance(
            flexibleFund = flexibleFund,
            startDate = period.startDate,
            endDate = period.endDate,
        )
        val allDates = period.startDate.datesUntil(period.endDate.plusDays(1)).toList()
        val byDate = txs.groupBy { it.date }
        val dailyTotals = allDates.associateWith { date -> byDate[date].orEmpty().sumOf { it.amount } }
        val overbudgetDays = dailyTotals.count { (_, total) ->
            dailyBudgetCalculator.calculateDailySummary(baseDailyAllowance, total).status == BudgetStatus.OVER_BUDGET
        }
        val summary = monthlyReportCalculator.calculate(totalIncome, totalExpense, totalSaving, periodDays, overbudgetDays)
        val endingBalance = totalIncome - fixed - totalSaving - totalExpense

        val biggestCategory = txs.groupBy { it.category }.maxByOrNull { it.value.sumOf { tx -> tx.amount } }?.key ?: "-"
        val mostExpensiveDay = dailyTotals.maxByOrNull { it.value }?.key?.toString() ?: "-"
        val mostFrugalDay = dailyTotals.entries
            .sortedWith(compareBy<Map.Entry<LocalDate, Long>> { it.value }.thenBy { it.key })
            .firstOrNull()
            ?.key
            ?.toString()
            ?: "-"

        _uiState.update {
            it.copy(
                isLoading = false,
                periodLabel = "${period.startDate} s/d ${period.endDate}",
                totalIncome = summary.totalIncome,
                totalExpense = summary.totalExpense,
                totalSaving = summary.totalSaving,
                endingBalance = endingBalance,
                overbudgetDays = summary.overbudgetDays,
                averageDailyExpense = summary.averageDailyExpense,
                biggestCategory = biggestCategory,
                mostExpensiveDay = mostExpensiveDay,
                mostFrugalDay = mostFrugalDay,
                recommendation = recommendation(endingBalance, summary.overbudgetDays),
            )
        }
    }

    private fun exportCsv() = viewModelScope.launch {
        runExport { period -> exporters.exportCsv(period, transactionDao.observeByPeriod(period.id).first()) }
    }

    private fun exportPdf() = viewModelScope.launch {
        val snapshot = uiState.value
        runExport { period -> exporters.exportPdf(period, snapshot) }
    }

    private suspend fun runExport(block: suspend (com.natasaku.app.data.local.entity.BudgetPeriodEntity) -> com.natasaku.app.domain.model.ExportedFileUiModel) {
        _uiState.update { it.copy(isLoading = true, errorMessage = null) }
        val period = budgetPeriodDao.observeActivePeriod().first()
        if (period == null) {
            _uiState.update { it.copy(isLoading = false, errorMessage = "Budget aktif belum tersedia.") }
            return
        }
        try {
            val file = withContext(Dispatchers.IO) { block(period) }
            _uiState.update { it.copy(isLoading = false, exportedFile = file) }
        } catch (e: Exception) {
            _uiState.update { it.copy(isLoading = false, errorMessage = "File belum berhasil dibuat. Coba lagi atau pilih lokasi penyimpanan lain.") }
        }
    }

    private fun recommendation(endingBalance: Long, overbudgetDays: Int): String {
        return when {
            endingBalance < 0 -> "Kurangi pengeluaran kategori terbesar di bulan depan agar saldo tidak minus."
            overbudgetDays >= 7 -> "Coba set batas harian lebih ketat untuk mengurangi hari overbudget."
            else -> "Pertahankan ritme bulan ini dan tambah porsi tabungan secara bertahap."
        }
    }
}
