package com.natasaku.app.presentation.navigation

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.presentation.component.NataSpotlightOverlay
import com.natasaku.app.presentation.screen.budget.BudgetRoute
import com.natasaku.app.presentation.screen.home.HomeRoute
import com.natasaku.app.presentation.screen.report.MonthlyReportRoute
import com.natasaku.app.presentation.screen.scheduled_payment.ScheduledPaymentRoute
import com.natasaku.app.presentation.screen.saving.SavingRoute
import com.natasaku.app.presentation.screen.transaction.TransactionHistoryRoute

private enum class MainTab(val label: String) {
    HOME("Beranda"),
    TRANSACTION("Transaksi"),
    BUDGET("Budget"),
    SAVING("Tabungan"),
    SCHEDULED("Jadwal"),
    REPORT("Laporan"),
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun MainTabsRoute(
    onOpenSettings: () -> Unit,
    onOpenExportSuccess: (ExportedFileUiModel) -> Unit,
    viewModel: MainTabsViewModel = hiltViewModel(),
) {
    var selectedTab by rememberSaveable { mutableStateOf(MainTab.HOME) }
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    var heroRect by remember { mutableStateOf<Rect?>(null) }
    var fabRect by remember { mutableStateOf<Rect?>(null) }
    var statusRect by remember { mutableStateOf<Rect?>(null) }
    var reportTabRect by remember { mutableStateOf<Rect?>(null) }
    var savingTabRect by remember { mutableStateOf<Rect?>(null) }

    LaunchedEffect(Unit) {
        viewModel.loadTourState()
    }

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
                        modifier = Modifier.onGloballyPositioned { coordinates ->
                            when (tab) {
                                MainTab.REPORT -> reportTabRect = coordinates.boundsInWindow()
                                MainTab.SAVING -> savingTabRect = coordinates.boundsInWindow()
                                else -> Unit
                            }
                        },
                    )
                }
            }
        },
    ) { padding ->
        AnimatedContent(
            targetState = selectedTab,
            transitionSpec = {
                (fadeIn(animationSpec = tween(200)) + slideInVertically(animationSpec = tween(200)) { it / 8 }) togetherWith
                    (fadeOut(animationSpec = tween(200)) + slideOutVertically(animationSpec = tween(200)) { -it / 8 })
            },
            label = "mainTabTransition",
        ) { tab ->
            when (tab) {
                MainTab.HOME -> HomeRoute(
                    onOpenHistory = { selectedTab = MainTab.TRANSACTION },
                    onOpenSaving = { selectedTab = MainTab.SAVING },
                    onOpenBudget = { selectedTab = MainTab.BUDGET },
                    onOpenSettings = onOpenSettings,
                    onOpenMonthlyReport = { selectedTab = MainTab.REPORT },
                    modifier = Modifier.padding(padding),
                    onHeroBoundsChanged = { heroRect = it },
                    onStatusBoundsChanged = { statusRect = it },
                    onFabBoundsChanged = { fabRect = it },
                )

                MainTab.TRANSACTION -> TransactionHistoryRoute(modifier = Modifier.padding(padding))
                MainTab.BUDGET -> BudgetRoute(modifier = Modifier.padding(padding))
                MainTab.SAVING -> SavingRoute(modifier = Modifier.padding(padding))
                MainTab.SCHEDULED -> ScheduledPaymentRoute(modifier = Modifier.padding(padding))
                MainTab.REPORT -> MonthlyReportRoute(
                    onBack = { selectedTab = MainTab.HOME },
                    onExportSuccess = onOpenExportSuccess,
                    modifier = Modifier.padding(padding),
                )
            }
        }

        if (uiState.isTourVisible && uiState.steps.isNotEmpty()) {
            val step = uiState.steps[uiState.currentStepIndex]
            val targetRect = when (step.anchor) {
                FeatureTourAnchor.HERO_CARD -> heroRect
                FeatureTourAnchor.FAB_ADD_EXPENSE -> fabRect
                FeatureTourAnchor.STATUS_CHIP -> statusRect
                FeatureTourAnchor.TAB_REPORTS -> reportTabRect
                FeatureTourAnchor.TAB_SAVING -> savingTabRect
            }

            LaunchedEffect(uiState.currentStepIndex) {
                when (step.anchor) {
                    FeatureTourAnchor.TAB_REPORTS -> selectedTab = MainTab.REPORT
                    FeatureTourAnchor.TAB_SAVING -> selectedTab = MainTab.SAVING
                    else -> if (selectedTab != MainTab.HOME) selectedTab = MainTab.HOME
                }
            }

            NataSpotlightOverlay(
                targetRect = targetRect,
                tooltipText = step.message,
                stepNumber = uiState.currentStepIndex + 1,
                totalSteps = uiState.steps.size,
                onNext = { viewModel.nextStep() },
                onSkip = { viewModel.skipTour() },
                modifier = Modifier.padding(padding),
            )
        }
    }
}
