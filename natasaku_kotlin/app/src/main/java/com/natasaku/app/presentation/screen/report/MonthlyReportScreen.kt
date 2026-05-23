package com.natasaku.app.presentation.screen.report

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.FilterChip
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
import com.natasaku.app.domain.model.ReportGranularity
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataShimmerBox
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
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            if (uiState.isLoading) {
                repeat(4) {
                    NataShimmerBox(
                        width = 340.dp,
                        height = 88.dp,
                        shape = MaterialTheme.shapes.medium,
                    )
                }
                return@Column
            }
            Text("Laporan", style = MaterialTheme.typography.headlineSmall)
            if (uiState.title.isNotBlank()) {
                Text(uiState.title, style = MaterialTheme.typography.titleMedium)
            }
            Text(uiState.periodLabel)
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(ReportGranularity.entries) { granularity ->
                    FilterChip(
                        selected = uiState.granularity == granularity,
                        onClick = { onEvent(MonthlyReportUiEvent.ChangeGranularity(granularity)) },
                        label = {
                            Text(
                                when (granularity) {
                                    ReportGranularity.DAILY -> "Harian"
                                    ReportGranularity.WEEKLY -> "Mingguan"
                                    ReportGranularity.MONTHLY -> "Bulanan"
                                    ReportGranularity.YEARLY -> "Tahunan"
                                    ReportGranularity.BY_PERIOD -> "Per Periode"
                                },
                            )
                        },
                    )
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
                NataSecondaryButton(
                    text = "< Sebelumnya",
                    onClick = { onEvent(MonthlyReportUiEvent.PrevPeriod) },
                    modifier = Modifier.weight(1f),
                )
                NataSecondaryButton(
                    text = "Berikutnya >",
                    onClick = { onEvent(MonthlyReportUiEvent.NextPeriod) },
                    modifier = Modifier.weight(1f),
                )
            }
            if (uiState.granularity == ReportGranularity.BY_PERIOD && uiState.availablePeriods.isNotEmpty()) {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(uiState.availablePeriods) { period ->
                        FilterChip(
                            selected = uiState.selectedPeriodId == period.id,
                            onClick = { onEvent(MonthlyReportUiEvent.SelectPeriod(period.id)) },
                            label = { Text(period.label) },
                        )
                    }
                }
            }
            if (uiState.totalExpense == 0L && uiState.biggestCategory == "-") {
                val emptyText = when (uiState.granularity) {
                    ReportGranularity.DAILY -> "Belum ada transaksi hari ini. Yuk mulai catat!"
                    ReportGranularity.WEEKLY -> "Belum ada transaksi minggu ini."
                    ReportGranularity.MONTHLY -> "Belum ada data untuk bulan ini."
                    ReportGranularity.YEARLY -> "Belum ada data untuk tahun ini."
                    ReportGranularity.BY_PERIOD -> "Pilih periode untuk melihat laporannya."
                }
                Text(emptyText)
            }
            Metric("Total penghasilan", uiState.totalIncome)
            Metric("Total pengeluaran tetap", uiState.totalFixedExpense)
            Metric("Total pengeluaran", uiState.totalExpense)
            Metric("Total tabungan", uiState.totalSaving)
            Metric("Dana fleksibel", uiState.flexibleBudget)
            Metric("Sisa budget", uiState.remainingBudget)
            Metric("Sisa akhir bulan", uiState.endingBalance)
            Text("Kategori terbesar: ${uiState.biggestCategory}")
            Text("Hari paling boros: ${uiState.mostExpensiveDay}")
            Text("Hari paling hemat: ${uiState.mostFrugalDay}")
            Text("Jumlah hari overbudget: ${uiState.overbudgetDays}")
            Metric("Rata-rata pengeluaran harian", uiState.averageDailyExpense)
            Text("Ringkasan visual tersedia pada data harian per periode ini.")
            Text("Rekomendasi: ${uiState.recommendation}")
            if (uiState.errorMessage != null) {
                Text(uiState.errorMessage, color = MaterialTheme.colorScheme.error)
            }
            NataPrimaryButton(
                "Export CSV",
                onClick = { onEvent(MonthlyReportUiEvent.ExportCsv) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !uiState.isLoading,
                isLoading = uiState.isLoading,
            )
            NataPrimaryButton(
                "Download PDF",
                onClick = { onEvent(MonthlyReportUiEvent.ExportPdf) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !uiState.isLoading,
                isLoading = uiState.isLoading,
            )
            NataSecondaryButton("Kembali", onClick = onBack, modifier = Modifier.fillMaxWidth())
        }
    }
}

@Composable
private fun Metric(label: String, amount: Long) {
    Card(
        shape = MaterialTheme.shapes.medium,
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(
                label,
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            MoneyText(amount, style = MaterialTheme.typography.titleLarge)
        }
    }
}
