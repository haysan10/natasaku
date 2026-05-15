package com.natasaku.app.presentation.screen.report

import com.natasaku.app.domain.model.ExportedFileUiModel

data class MonthlyReportUiState(
    val isLoading: Boolean = false,
    val periodLabel: String = "",
    val totalIncome: Long = 0L,
    val totalExpense: Long = 0L,
    val totalSaving: Long = 0L,
    val endingBalance: Long = 0L,
    val biggestCategory: String = "-",
    val mostExpensiveDay: String = "-",
    val mostFrugalDay: String = "-",
    val overbudgetDays: Int = 0,
    val averageDailyExpense: Long = 0L,
    val recommendation: String = "Belum ada rekomendasi.",
    val errorMessage: String? = null,
    val exportedFile: ExportedFileUiModel? = null,
)

sealed interface MonthlyReportUiEvent {
    data object Load : MonthlyReportUiEvent
    data object ExportCsv : MonthlyReportUiEvent
    data object ExportPdf : MonthlyReportUiEvent
    data object ClearExport : MonthlyReportUiEvent
}
