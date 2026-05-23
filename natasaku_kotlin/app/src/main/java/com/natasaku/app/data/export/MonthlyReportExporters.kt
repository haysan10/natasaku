package com.natasaku.app.data.export

import android.content.Context
import android.graphics.Paint
import android.graphics.pdf.PdfDocument
import android.net.Uri
import androidx.core.content.FileProvider
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.domain.model.ReportFilter
import com.natasaku.app.domain.model.ReportGranularity
import com.natasaku.app.presentation.screen.report.MonthlyReportUiState
import java.io.File
import java.time.Instant
import java.time.LocalDate
import java.time.temporal.WeekFields
import java.util.Locale

private const val AUTHORITY_SUFFIX = ".fileprovider"

class MonthlyReportExporters(private val context: Context) {
    fun exportCsv(filter: ReportFilter, uiState: MonthlyReportUiState): ExportedFileUiModel {
        val fileName = buildFileName(filter, "csv")
        val file = File(context.cacheDir, fileName)
        val header = "title,period_label,total_income,total_fixed,total_saving,total_spent,remaining,overbudget_days,average_daily\n"
        val rows = listOf(
            listOf(
                escapeCsv(uiState.title),
                escapeCsv(uiState.periodLabel),
                uiState.totalIncome.toString(),
                uiState.totalFixedExpense.toString(),
                uiState.totalSaving.toString(),
                uiState.totalExpense.toString(),
                uiState.remainingBudget.toString(),
                uiState.overbudgetDays.toString(),
                uiState.averageDailyExpense.toString(),
            ).joinToString(","),
        ).joinToString("\n")
        file.writeText(header + rows + if (rows.isNotEmpty()) "\n" else "", Charsets.UTF_8)
        return file.toUiModel("text/csv")
    }

    fun exportPdf(filter: ReportFilter, uiState: MonthlyReportUiState): ExportedFileUiModel {
        val fileName = buildFileName(filter, "pdf")
        val file = File(context.cacheDir, fileName)
        val doc = PdfDocument()
        val pageInfo = PdfDocument.PageInfo.Builder(595, 842, 1).create()
        val page = doc.startPage(pageInfo)
        val canvas = page.canvas
        val titlePaint = Paint().apply { textSize = 20f; isFakeBoldText = true }
        val bodyPaint = Paint().apply { textSize = 12f }

        var y = 50f
        canvas.drawText("NataSaku", 40f, y, titlePaint)
        y += 24f
        canvas.drawText("Laporan Keuangan", 40f, y, titlePaint)
        y += 24f
        canvas.drawText("Periode: ${uiState.periodLabel}", 40f, y, bodyPaint)
        y += 18f
        canvas.drawText("Dibuat: ${LocalDate.now()}", 40f, y, bodyPaint)
        y += 28f

        val lines = listOf(
            "Total penghasilan: ${uiState.totalIncome}",
            "Total pengeluaran tetap: ${uiState.totalFixedExpense}",
            "Total pengeluaran: ${uiState.totalExpense}",
            "Total tabungan: ${uiState.totalSaving}",
            "Sisa budget: ${uiState.remainingBudget}",
            "Kategori terbesar: ${uiState.biggestCategory}",
            "Hari paling boros: ${uiState.mostExpensiveDay}",
            "Hari paling hemat: ${uiState.mostFrugalDay}",
            "Jumlah hari overbudget: ${uiState.overbudgetDays}",
            "Rata-rata pengeluaran harian: ${uiState.averageDailyExpense}",
            "Rekomendasi: ${uiState.recommendation}",
        )
        lines.forEach {
            canvas.drawText(it, 40f, y, bodyPaint)
            y += 18f
        }

        doc.finishPage(page)
        file.outputStream().use { out -> doc.writeTo(out) }
        doc.close()
        return file.toUiModel("application/pdf")
    }

    private fun escapeCsv(value: String): String {
        if (value.none { it == ',' || it == '"' || it == '\n' || it == '\r' }) return value
        return '"' + value.replace("\"", "\"\"") + '"'
    }

    private fun File.toUiModel(mimeType: String): ExportedFileUiModel {
        val uri = runCatching {
            FileProvider.getUriForFile(context, context.packageName + AUTHORITY_SUFFIX, this)
        }.getOrElse {
            Uri.fromFile(this)
        }
        return ExportedFileUiModel(
            fileName = name,
            uri = uri,
            mimeType = mimeType,
            fileSizeBytes = length(),
            createdAt = Instant.now(),
        )
    }

    private fun buildFileName(filter: ReportFilter, extension: String): String {
        return when (filter.granularity) {
            ReportGranularity.DAILY -> {
                val date = filter.targetDate ?: LocalDate.now()
                "natasaku-daily-${date}.${extension}"
            }
            ReportGranularity.WEEKLY -> {
                val start = filter.weekStartDate ?: LocalDate.now()
                val week = start.get(WeekFields.of(Locale.getDefault()).weekOfWeekBasedYear())
                "natasaku-weekly-${start.year}-W${week.toString().padStart(2, '0')}.${extension}"
            }
            ReportGranularity.MONTHLY -> {
                val month = filter.month ?: java.time.YearMonth.now()
                "natasaku-monthly-${month.year}-${month.monthValue.toString().padStart(2, '0')}.${extension}"
            }
            ReportGranularity.YEARLY -> {
                val year = filter.year?.value ?: LocalDate.now().year
                "natasaku-yearly-${year}.${extension}"
            }
            ReportGranularity.BY_PERIOD -> {
                val start = filter.periodStartDate ?: LocalDate.now()
                val end = filter.periodEndDate ?: start
                "natasaku-period-${start.toString().replace("-", "")}-${end.toString().replace("-", "")}.${extension}"
            }
        }
    }
}
