package com.natasaku.app.presentation.screen.budget

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.presentation.component.FinanceSummaryCard
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataSecondaryButton

@Composable
fun BudgetRoute(
    modifier: Modifier = Modifier,
    viewModel: BudgetViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onEvent(BudgetUiEvent.Load) }
    BudgetScreen(uiState = uiState, modifier = modifier)
}

@Composable
fun BudgetScreen(
    uiState: BudgetUiState,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text("Budget", style = MaterialTheme.typography.headlineSmall)
        Text(uiState.periodLabel, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)

        FinanceSummaryCard(
            title = "Jatah kamu hari ini",
            amount = uiState.finalDailyAllowance,
            description = "Jatah harian dasar + penyesuaian hari ini.",
        )

        MetricRow("Total penghasilan", uiState.totalIncome, onEdit = {})
        MetricRow("Total pengeluaran tetap", uiState.totalFixedExpense, onEdit = {})
        MetricRow("Target tabungan", uiState.totalSavingTarget, onEdit = {})
        MetricRow("Dana fleksibel", uiState.flexibleFund)
        MetricRow("Jatah harian dasar", uiState.baseDailyAllowance)
        MetricRow("Penyesuaian", uiState.adjustment)
        MetricRow("Sudah terpakai hari ini", uiState.spentToday)
        if (uiState.fixedExpenseHighWarning) {
            Text(
                text = "Pengeluaran tetapmu sudah lebih dari 80% penghasilan.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.error,
            )
        }

        if (uiState.overbudgetAmount > 0L) {
            Text(
                text = "Budget akan disesuaikan agar tetap aman.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.error,
            )
        } else {
            Text(
                text = "Aman. Pengeluaranmu masih terkendali.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.primary,
            )
        }
    }
}

@Composable
private fun MetricRow(
    label: String,
    amount: Long,
    onEdit: (() -> Unit)? = null,
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        Text(label, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        MoneyText(amount)
        if (onEdit != null) {
            NataSecondaryButton(
                text = "Edit",
                onClick = onEdit,
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}
