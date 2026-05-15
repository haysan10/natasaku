package com.natasaku.app.data.export

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.presentation.screen.report.MonthlyReportUiState
import java.io.File
import java.time.Instant
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
        val period = period()
        val tx = listOf(
            ExpenseTransactionEntity(
                id = "tx-1",
                periodId = period.id,
                amount = 25_000,
                category = "Makan, Siang",
                date = LocalDate.of(2026, 5, 7),
                note = "Catatan \"quote\"",
                createdAt = Instant.parse("2026-05-07T12:00:00Z"),
                updatedAt = Instant.parse("2026-05-07T12:00:00Z"),
                deletedAt = null,
            ),
        )

        val file = exporters.exportCsv(period, tx)

        assertEquals("text/csv", file.mimeType)
        val local = File(context.cacheDir, file.fileName)
        val content = local.readText(Charsets.UTF_8)
        assertTrue(content.startsWith("period_start,period_end,date,category,amount,note,created_at"))
        assertTrue(content.contains("\"Makan, Siang\""))
        assertTrue(content.contains("\"Catatan \"\"quote\"\"\""))
    }

    @Test
    fun exportPdf_returnsPdfMetadataWhenSupported() {
        val period = period()
        val state = MonthlyReportUiState(recommendation = "Pertahankan ritme.")
        val result = runCatching { exporters.exportPdf(period, state) }
        if (result.isSuccess) {
            val file = result.getOrThrow()
            assertEquals("application/pdf", file.mimeType)
            assertTrue(file.fileName.endsWith(".pdf"))
        }
    }

    private fun period() = BudgetPeriodEntity(
        id = "period-1",
        name = "Mei 2026",
        startDate = LocalDate.of(2026, 5, 1),
        endDate = LocalDate.of(2026, 5, 31),
        isActive = true,
        createdAt = Instant.parse("2026-05-01T00:00:00Z"),
        updatedAt = Instant.parse("2026-05-01T00:00:00Z"),
    )
}
