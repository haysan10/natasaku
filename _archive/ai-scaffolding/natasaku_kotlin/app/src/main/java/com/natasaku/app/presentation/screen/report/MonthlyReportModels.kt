package com.natasaku.app.presentation.screen.report

import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.domain.model.ReportGranularity
import java.time.LocalDate

data class MonthlyReportUiState(
    val isLoading: Boolean = false,
    val periodLabel: String = "",
    val title: String = "",
    val totalIncome: Long = 0L,
    val totalExpense: Long = 0L,
    val totalSaving: Long = 0L,
    val totalFixedExpense: Long = 0L,
    val flexibleBudget: Long = 0L,
    val remainingBudget: Long = 0L,
    val endingBalance: Long = 0L,
    val biggestCategory: String = "-",
    val mostExpensiveDay: String = "-",
    val mostFrugalDay: String = "-",
    val overbudgetDays: Int = 0,
    val averageDailyExpense: Long = 0L,
    val recommendation: String = "Belum ada rekomendasi.",
    val errorMessage: String? = null,
    val exportedFile: ExportedFileUiModel? = null,
    val granularity: ReportGranularity = ReportGranularity.MONTHLY,
    val anchorDate: LocalDate = LocalDate.now(),
    val selectedPeriodId: String? = null,
    val availablePeriods: List<ReportPeriodOption> = emptyList(),
)

data class ReportPeriodOption(
    val id: String,
    val label: String,
    val startDate: LocalDate,
    val endDate: LocalDate,
)

sealed interface MonthlyReportUiEvent {
    data object Load : MonthlyReportUiEvent
    data class ChangeGranularity(val granularity: ReportGranularity) : MonthlyReportUiEvent
    data object PrevPeriod : MonthlyReportUiEvent
    data object NextPeriod : MonthlyReportUiEvent
    data class SelectPeriod(val periodId: String) : MonthlyReportUiEvent
    data object ExportCsv : MonthlyReportUiEvent
    data object ExportPdf : MonthlyReportUiEvent
    data object ClearExport : MonthlyReportUiEvent
}
