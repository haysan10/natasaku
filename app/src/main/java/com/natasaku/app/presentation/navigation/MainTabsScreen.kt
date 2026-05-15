package com.natasaku.app.presentation.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.presentation.screen.budget.BudgetRoute
import com.natasaku.app.presentation.screen.home.HomeRoute
import com.natasaku.app.presentation.screen.report.MonthlyReportRoute
import com.natasaku.app.presentation.screen.saving.SavingRoute
import com.natasaku.app.presentation.screen.transaction.TransactionHistoryRoute

private enum class MainTab(val label: String) {
    HOME("Beranda"),
    TRANSACTION("Transaksi"),
    BUDGET("Budget"),
    SAVING("Tabungan"),
    REPORT("Laporan"),
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun MainTabsRoute(
    onOpenSettings: () -> Unit,
    onOpenExportSuccess: (ExportedFileUiModel) -> Unit,
) {
    var selectedTab by rememberSaveable { mutableStateOf(MainTab.HOME) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(selectedTab.label) },
                actions = {
                    TextButton(onClick = onOpenSettings) {
                        Text("Pengaturan")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(),
            )
        },
        bottomBar = {
            NavigationBar {
                MainTab.entries.forEach { tab ->
                    NavigationBarItem(
                        selected = selectedTab == tab,
                        onClick = { selectedTab = tab },
                        icon = { Text(tab.label.take(1)) },
                        label = { Text(tab.label) },
                    )
                }
            }
        },
    ) { padding ->
        when (selectedTab) {
            MainTab.HOME -> HomeRoute(
                onOpenHistory = { selectedTab = MainTab.TRANSACTION },
                onOpenSaving = { selectedTab = MainTab.SAVING },
                onOpenBudget = { selectedTab = MainTab.BUDGET },
                onOpenSettings = onOpenSettings,
                onOpenMonthlyReport = { selectedTab = MainTab.REPORT },
                modifier = Modifier.padding(padding),
            )

            MainTab.TRANSACTION -> TransactionHistoryRoute(modifier = Modifier.padding(padding))
            MainTab.BUDGET -> BudgetRoute(modifier = Modifier.padding(padding))
            MainTab.SAVING -> SavingRoute(modifier = Modifier.padding(padding))
            MainTab.REPORT -> MonthlyReportRoute(
                onBack = { selectedTab = MainTab.HOME },
                onExportSuccess = onOpenExportSuccess,
                modifier = Modifier.padding(padding),
            )
        }
    }
}
