package com.natasaku.app.presentation.screen.report

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.data.export.MonthlyReportExporters
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.domain.model.ReportFilter
import com.natasaku.app.domain.model.ReportGranularity
import com.natasaku.app.domain.model.ReportState
import com.natasaku.app.domain.usecase.GenerateUnifiedReportUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.Year
import java.time.YearMonth
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class MonthlyReportViewModel @Inject constructor(
    private val budgetPeriodDao: BudgetPeriodDao,
    private val generateUnifiedReportUseCase: GenerateUnifiedReportUseCase,
    private val exporters: MonthlyReportExporters,
) : ViewModel() {
    private val _uiState = MutableStateFlow(MonthlyReportUiState())
    val uiState = _uiState.asStateFlow()

    private var latestReportFilter: ReportFilter = ReportFilter(granularity = ReportGranularity.MONTHLY, month = YearMonth.now())
    private var reportJob: Job? = null

    fun onEvent(event: MonthlyReportUiEvent) {
        when (event) {
            MonthlyReportUiEvent.Load -> load()
            is MonthlyReportUiEvent.ChangeGranularity -> changeGranularity(event.granularity)
            MonthlyReportUiEvent.PrevPeriod -> shiftPeriod(-1)
            MonthlyReportUiEvent.NextPeriod -> shiftPeriod(1)
            is MonthlyReportUiEvent.SelectPeriod -> {
                _uiState.update { it.copy(selectedPeriodId = event.periodId) }
                refreshReport()
            }
            MonthlyReportUiEvent.ExportCsv -> exportCsv()
            MonthlyReportUiEvent.ExportPdf -> exportPdf()
            MonthlyReportUiEvent.ClearExport -> _uiState.update { it.copy(exportedFile = null, errorMessage = null) }
        }
    }

    private fun load() = viewModelScope.launch {
        val periods = budgetPeriodDao.observeAll().first()
        val periodOptions = periods.map {
            ReportPeriodOption(
                id = it.id,
                label = "${it.startDate} – ${it.endDate}",
                startDate = it.startDate,
                endDate = it.endDate,
            )
        }
        val active = budgetPeriodDao.observeActivePeriod().first()
        _uiState.update {
            it.copy(
                availablePeriods = periodOptions,
                selectedPeriodId = active?.id ?: periodOptions.firstOrNull()?.id,
                granularity = ReportGranularity.MONTHLY,
                anchorDate = LocalDate.now(),
            )
        }
        refreshReport()
    }

    private fun changeGranularity(granularity: ReportGranularity) {
        _uiState.update { state ->
            state.copy(
                granularity = granularity,
                anchorDate = LocalDate.now(),
                errorMessage = null,
            )
        }
        refreshReport()
    }

    private fun shiftPeriod(direction: Int) {
        val state = _uiState.value
        val nextAnchor = when (state.granularity) {
            ReportGranularity.DAILY -> state.anchorDate.plusDays(direction.toLong())
            ReportGranularity.WEEKLY -> state.anchorDate.plusWeeks(direction.toLong())
            ReportGranularity.MONTHLY -> state.anchorDate.plusMonths(direction.toLong())
            ReportGranularity.YEARLY -> state.anchorDate.plusYears(direction.toLong())
            ReportGranularity.BY_PERIOD -> state.anchorDate
        }
        _uiState.update { it.copy(anchorDate = nextAnchor) }
        refreshReport()
    }

    private fun refreshReport() = viewModelScope.launch {
        reportJob?.cancel()
        val state = _uiState.value
        val filter = when (state.granularity) {
            ReportGranularity.DAILY -> ReportFilter(
                granularity = ReportGranularity.DAILY,
                targetDate = state.anchorDate,
            )
            ReportGranularity.WEEKLY -> ReportFilter(
                granularity = ReportGranularity.WEEKLY,
                weekStartDate = state.anchorDate.with(DayOfWeek.MONDAY),
            )
            ReportGranularity.MONTHLY -> ReportFilter(
                granularity = ReportGranularity.MONTHLY,
                month = YearMonth.from(state.anchorDate),
            )
            ReportGranularity.YEARLY -> ReportFilter(
                granularity = ReportGranularity.YEARLY,
                year = Year.of(state.anchorDate.year),
            )
            ReportGranularity.BY_PERIOD -> ReportFilter(
                granularity = ReportGranularity.BY_PERIOD,
                periodId = state.selectedPeriodId,
                periodStartDate = state.availablePeriods.firstOrNull { it.id == state.selectedPeriodId }?.startDate,
                periodEndDate = state.availablePeriods.firstOrNull { it.id == state.selectedPeriodId }?.endDate,
            )
        }
        latestReportFilter = filter
        reportJob = viewModelScope.launch {
            generateUnifiedReportUseCase.execute(filter).collect { reportState ->
                when (reportState) {
                    ReportState.Loading -> _uiState.update { it.copy(isLoading = true, errorMessage = null) }
                    is ReportState.Error -> _uiState.update { it.copy(isLoading = false, errorMessage = reportState.message) }
                    is ReportState.Success -> {
                        val report = reportState.report
                        _uiState.update {
                            it.copy(
                                isLoading = false,
                                title = report.title,
                                periodLabel = report.periodLabel,
                                totalIncome = report.totalIncome,
                                totalExpense = report.totalSpent,
                                totalSaving = report.totalSavingAllocated,
                                totalFixedExpense = report.totalFixedExpense,
                                flexibleBudget = report.flexibleBudget,
                                remainingBudget = report.remainingBudget,
                                endingBalance = report.remainingBudget,
                                overbudgetDays = report.overbudgetDaysCount,
                                averageDailyExpense = report.averageDailySpend,
                                biggestCategory = report.categoryBreakdown.firstOrNull()?.categoryName ?: "-",
                                mostExpensiveDay = report.highestSpendDay?.toString() ?: "-",
                                mostFrugalDay = report.lowestSpendDay?.toString() ?: "-",
                                recommendation = report.recommendation,
                                errorMessage = null,
                            )
                        }
                    }
                }
            }
        }
    }

    private fun exportCsv() = viewModelScope.launch {
        _uiState.update { it.copy(isLoading = true, errorMessage = null) }
        runCatching {
            exporters.exportCsv(
                filter = latestReportFilter,
                uiState = _uiState.value,
            )
        }.onSuccess { file ->
            _uiState.update { it.copy(isLoading = false, exportedFile = file) }
        }.onFailure {
            _uiState.update {
                it.copy(
                    isLoading = false,
                    errorMessage = "File belum berhasil dibuat. Coba lagi atau pilih lokasi penyimpanan lain.",
                )
            }
        }
    }

    private fun exportPdf() = viewModelScope.launch {
        _uiState.update { it.copy(isLoading = true, errorMessage = null) }
        runCatching {
            exporters.exportPdf(
                filter = latestReportFilter,
                uiState = _uiState.value,
            )
        }.onSuccess { file ->
            _uiState.update { it.copy(isLoading = false, exportedFile = file) }
        }.onFailure {
            _uiState.update {
                it.copy(
                    isLoading = false,
                    errorMessage = "File belum berhasil dibuat. Coba lagi atau pilih lokasi penyimpanan lain.",
                )
            }
        }
    }
}
