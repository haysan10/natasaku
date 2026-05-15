package com.natasaku.app.data.export

import android.content.Context
import android.graphics.Paint
import android.graphics.pdf.PdfDocument
import android.net.Uri
import androidx.core.content.FileProvider
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.presentation.screen.report.MonthlyReportUiState
import java.io.File
import java.time.Instant
import java.time.LocalDate
import java.time.format.DateTimeFormatter

private const val AUTHORITY_SUFFIX = ".fileprovider"

class MonthlyReportExporters(private val context: Context) {
    fun exportCsv(period: BudgetPeriodEntity, transactions: List<ExpenseTransactionEntity>): ExportedFileUiModel {
        val fileName = "NataSaku_Transaksi_${period.startDate.year}_${period.startDate.monthValue.toString().padStart(2, '0')}.csv"
        val file = File(context.cacheDir, fileName)
        val header = "period_start,period_end,date,category,amount,note,created_at\n"
        val rows = transactions.joinToString("\n") { tx ->
            listOf(
                period.startDate.toString(),
                period.endDate.toString(),
                tx.date.toString(),
                escapeCsv(tx.category),
                tx.amount.toString(),
                escapeCsv(tx.note.orEmpty()),
                tx.createdAt.toString(),
            ).joinToString(",")
        }
        file.writeText(header + rows + if (rows.isNotEmpty()) "\n" else "", Charsets.UTF_8)
        return file.toUiModel("text/csv")
    }

    fun exportPdf(period: BudgetPeriodEntity, state: MonthlyReportUiState): ExportedFileUiModel {
        val fileName = "NataSaku_Laporan_${period.startDate.year}_${period.startDate.monthValue.toString().padStart(2, '0')}.pdf"
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
        canvas.drawText("Laporan Bulanan", 40f, y, titlePaint)
        y += 24f
        canvas.drawText("Periode: ${period.startDate} s/d ${period.endDate}", 40f, y, bodyPaint)
        y += 18f
        canvas.drawText("Dibuat: ${LocalDate.now()}", 40f, y, bodyPaint)
        y += 28f

        val lines = listOf(
            "Total penghasilan: ${state.totalIncome}",
            "Total pengeluaran: ${state.totalExpense}",
            "Total tabungan: ${state.totalSaving}",
            "Sisa akhir bulan: ${state.endingBalance}",
            "Kategori terbesar: ${state.biggestCategory}",
            "Hari paling boros: ${state.mostExpensiveDay}",
            "Hari paling hemat: ${state.mostFrugalDay}",
            "Jumlah hari overbudget: ${state.overbudgetDays}",
            "Rata-rata pengeluaran harian: ${state.averageDailyExpense}",
            "Rekomendasi: ${state.recommendation}",
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
}
