package com.natasaku.app.presentation.screen.report

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton

@Composable
fun MonthlyReportRoute(
    onBack: () -> Unit,
    onExportSuccess: (ExportedFileUiModel) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: MonthlyReportViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onEvent(MonthlyReportUiEvent.Load) }
    LaunchedEffect(uiState.exportedFile) {
        val file = uiState.exportedFile ?: return@LaunchedEffect
        onExportSuccess(file)
        viewModel.onEvent(MonthlyReportUiEvent.ClearExport)
    }
    MonthlyReportScreen(uiState, viewModel::onEvent, onBack, modifier)
}

@Composable
fun MonthlyReportScreen(
    uiState: MonthlyReportUiState,
    onEvent: (MonthlyReportUiEvent) -> Unit,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Scaffold(modifier = modifier) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Text("Laporan bulanan", style = MaterialTheme.typography.headlineSmall)
            Text(uiState.periodLabel)
            if (uiState.totalExpense == 0L && uiState.biggestCategory == "-") {
                Text("Laporan belum tersedia")
                Text("Laporan akan tersedia setelah ada transaksi dalam periode ini.")
            }
            Metric("Total penghasilan", uiState.totalIncome)
            Metric("Total pengeluaran", uiState.totalExpense)
            Metric("Total tabungan", uiState.totalSaving)
            Metric("Sisa akhir bulan", uiState.endingBalance)
            Text("Kategori terbesar: ${uiState.biggestCategory}")
            Text("Hari paling boros: ${uiState.mostExpensiveDay}")
            Text("Hari paling hemat: ${uiState.mostFrugalDay}")
            Text("Jumlah hari overbudget: ${uiState.overbudgetDays}")
            Metric("Rata-rata pengeluaran harian", uiState.averageDailyExpense)
            Text("Rekomendasi: ${uiState.recommendation}")
            if (uiState.errorMessage != null) {
                Text(uiState.errorMessage, color = MaterialTheme.colorScheme.error)
            }
            NataPrimaryButton(
                "Export CSV",
                onClick = { onEvent(MonthlyReportUiEvent.ExportCsv) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !uiState.isLoading,
            )
            NataPrimaryButton(
                "Download PDF",
                onClick = { onEvent(MonthlyReportUiEvent.ExportPdf) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !uiState.isLoading,
            )
            NataSecondaryButton("Kembali", onClick = onBack, modifier = Modifier.fillMaxWidth())
        }
    }
}

@Composable
private fun Metric(label: String, amount: Long) {
    Text(label)
    MoneyText(amount)
}
