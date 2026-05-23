package com.natasaku.app.data.export

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.natasaku.app.domain.model.ReportFilter
import com.natasaku.app.domain.model.ReportGranularity
import com.natasaku.app.presentation.screen.report.MonthlyReportUiState
import java.io.File
import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MonthlyReportExportersTest {
    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val exporters = MonthlyReportExporters(context)

    @Test
    fun exportCsv_createsUtf8CsvWithEscaping() {
        val state = MonthlyReportUiState(
            title = "Mei 2026",
            periodLabel = "2026-05-01 – 2026-05-31",
            totalIncome = 5_000_000L,
            totalFixedExpense = 2_000_000L,
            totalSaving = 500_000L,
            totalExpense = 1_200_000L,
            remainingBudget = 1_300_000L,
            overbudgetDays = 3,
            averageDailyExpense = 38_709L,
        )
        val filter = ReportFilter(
            granularity = ReportGranularity.MONTHLY,
            month = java.time.YearMonth.of(2026, 5),
        )

        val file = exporters.exportCsv(filter, state)

        assertEquals("text/csv", file.mimeType)
        val local = File(context.cacheDir, file.fileName)
        val content = local.readText(Charsets.UTF_8)
        assertTrue(content.startsWith("title,period_label,total_income,total_fixed,total_saving,total_spent,remaining,overbudget_days,average_daily"))
        assertTrue(content.contains("Mei 2026"))
        assertTrue(content.contains("2026-05-01 – 2026-05-31"))
    }

    @Test
    fun exportPdf_returnsPdfMetadataWhenSupported() {
        val filter = ReportFilter(
            granularity = ReportGranularity.DAILY,
            targetDate = LocalDate.of(2026, 5, 23),
        )
        val state = MonthlyReportUiState(
            periodLabel = "2026-05-23 – 2026-05-23",
            recommendation = "Pertahankan ritme.",
        )
        val result = runCatching { exporters.exportPdf(filter, state) }
        if (result.isSuccess) {
            val file = result.getOrThrow()
            assertEquals("application/pdf", file.mimeType)
            assertTrue(file.fileName.endsWith(".pdf"))
        }
    }
}
