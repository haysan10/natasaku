package com.natasaku.app.presentation.screen.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.presentation.component.FinanceSummaryCard
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton
import com.natasaku.app.presentation.component.StatusChip
import com.natasaku.app.presentation.theme.BudgetStatus as UiBudgetStatus
import java.time.LocalDate

private val QuickExpenseCategories = listOf(
    "Makan",
    "Transportasi",
    "Belanja",
    "Tagihan",
    "Hiburan",
    "Lainnya",
)

@Composable
fun HomeRoute(
    onOpenHistory: () -> Unit,
    onOpenSaving: () -> Unit,
    onOpenBudget: () -> Unit,
    onOpenSettings: () -> Unit,
    onOpenMonthlyReport: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: HomeViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onEvent(HomeUiEvent.Load) }
    HomeDashboardScreen(
        uiState = uiState,
        onEvent = viewModel::onEvent,
        onOpenHistory = onOpenHistory,
        onOpenSaving = onOpenSaving,
        onOpenBudget = onOpenBudget,
        onOpenSettings = onOpenSettings,
        onOpenMonthlyReport = onOpenMonthlyReport,
        modifier = modifier,
    )
}

@Composable
fun HomeDashboardScreen(
    uiState: HomeUiState,
    onEvent: (HomeUiEvent) -> Unit,
    onOpenHistory: () -> Unit,
    onOpenSaving: () -> Unit,
    onOpenBudget: () -> Unit,
    onOpenSettings: () -> Unit,
    onOpenMonthlyReport: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(uiState.addExpenseMessage) {
        val message = uiState.addExpenseMessage ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(message)
        onEvent(HomeUiEvent.ClearMessage)
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { onEvent(HomeUiEvent.OpenAddExpense) },
                modifier = Modifier.semantics { contentDescription = "Catat pengeluaran" },
            ) { Text("+") }
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Text(uiState.greeting, style = MaterialTheme.typography.titleLarge)
            Text(uiState.activePeriodName, style = MaterialTheme.typography.bodyMedium)

            FinanceSummaryCard(
                title = "Jatah kamu hari ini",
                amount = uiState.dailyAllowance,
                description = uiState.insight,
            )

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Column {
                    Text("Sudah terpakai")
                    MoneyText(uiState.spentToday)
                }
                Column {
                    Text("Sisa hari ini")
                    MoneyText(uiState.remainingToday)
                }
            }

            StatusChip(
                status = when (uiState.status) {
                    BudgetStatus.SAFE -> UiBudgetStatus.SAFE
                    BudgetStatus.WARNING -> UiBudgetStatus.WARNING
                    BudgetStatus.OVER_BUDGET -> UiBudgetStatus.OVER_BUDGET
                },
            )

            Text("Penyesuaian jatah")
            MoneyText(uiState.adjustmentAmount, style = MaterialTheme.typography.titleMedium)

            Text("Progres bulan ini")
            Text(uiState.monthlyProgressLabel)
            Text("Kategori utama hari ini")
            Text(uiState.categorySummaryLabel)
            if (uiState.remainingToday > 0L) {
                NataSecondaryButton(
                    text = "Kamu masih punya sisa. Atur alokasinya",
                    onClick = onOpenSaving,
                )
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                NataSecondaryButton(text = "Transaksi", onClick = onOpenHistory)
                NataSecondaryButton(text = "Budget", onClick = onOpenBudget)
                NataSecondaryButton(text = "Tabungan", onClick = onOpenSaving)
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                NataSecondaryButton(text = "Laporan", onClick = onOpenMonthlyReport)
                NataSecondaryButton(text = "Pengaturan", onClick = onOpenSettings)
            }
        }
    }

    if (uiState.showAddExpenseSheet) {
        AddExpenseBottomSheet(
            errorMessage = uiState.addExpenseError,
            onDismiss = { onEvent(HomeUiEvent.CloseAddExpense) },
            onSave = { amount, category, note -> onEvent(HomeUiEvent.SaveExpense(amount, category, note)) },
        )
    }

    if (uiState.showOverbudgetDialog) {
        AlertDialog(
            onDismissRequest = { onEvent(HomeUiEvent.DismissOverbudget) },
            title = { Text("Jatah hari ini terlewati") },
            text = {
                Text(
                    if (uiState.overbudgetAmount > 0L) {
                        "Pengeluaran hari ini melebihi jatah sebesar ${com.natasaku.app.core.money.RupiahFormatter().format(uiState.overbudgetAmount)}. Budget akan disesuaikan agar tetap aman."
                    } else {
                        "Budget akan disesuaikan agar tetap aman."
                    },
                )
            },
            confirmButton = {
                TextButton(onClick = { onEvent(HomeUiEvent.DismissOverbudget) }) {
                    Text("Saya Mengerti")
                }
            },
            dismissButton = {
                TextButton(onClick = {
                    onEvent(HomeUiEvent.DismissOverbudget)
                    onOpenBudget()
                }) {
                    Text("Lihat Detail")
                }
            },
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddExpenseBottomSheet(
    errorMessage: String?,
    onDismiss: () -> Unit,
    onSave: (Long, String, String?) -> Unit,
) {
    var amountText by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(QuickExpenseCategories.first()) }
    var note by remember { mutableStateOf("") }
    val focusRequester = remember { FocusRequester() }
    val todayLabel = remember { LocalDate.now().toString() }

    LaunchedEffect(Unit) { focusRequester.requestFocus() }

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text("Catat pengeluaran", style = MaterialTheme.typography.titleLarge)
            if (!errorMessage.isNullOrBlank()) {
                Text(errorMessage, color = MaterialTheme.colorScheme.error)
            }
            OutlinedTextField(
                value = amountText,
                onValueChange = { amountText = it.filter { ch -> ch.isDigit() } },
                label = { Text("Nominal") },
                modifier = Modifier
                    .fillMaxWidth()
                    .focusRequester(focusRequester),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true,
            )

            Text("Kategori")
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                QuickExpenseCategories.take(3).forEach { category ->
                    FilterChip(
                        selected = selectedCategory == category,
                        onClick = { selectedCategory = category },
                        label = { Text(category) },
                    )
                }
            }
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                QuickExpenseCategories.drop(3).forEach { category ->
                    FilterChip(
                        selected = selectedCategory == category,
                        onClick = { selectedCategory = category },
                        label = { Text(category) },
                    )
                }
            }

            OutlinedTextField(
                value = todayLabel,
                onValueChange = {},
                label = { Text("Tanggal") },
                modifier = Modifier.fillMaxWidth(),
                readOnly = true,
                enabled = false,
            )
            OutlinedTextField(
                value = note,
                onValueChange = { note = it },
                label = { Text("Catatan (opsional)") },
                modifier = Modifier.fillMaxWidth(),
            )
            NataPrimaryButton(
                text = "Simpan Pengeluaran",
                onClick = { onSave(amountText.toLongOrNull() ?: 0L, selectedCategory, note.ifBlank { null }) },
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}
