package com.natasaku.app.presentation.screen.home

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.TrendingUp
import androidx.compose.material.icons.outlined.Visibility
import androidx.compose.material.icons.outlined.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.domain.validation.TransactionInputValidator
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataAnimatedCounter
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataProgressBar
import com.natasaku.app.presentation.component.NataSecondaryButton
import com.natasaku.app.presentation.component.NataStatusChip
import com.natasaku.app.presentation.component.NominalInputField
import com.natasaku.app.core.money.RupiahFormatter
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

private val QuickExpenseCategories = listOf(
    "Makan",
    "Transportasi",
    "Belanja",
    "Tagihan",
    "Hiburan",
    "Lainnya",
)

@Composable
private fun formatAmount(amount: Long, isHidden: Boolean): String {
    return if (isHidden) "Rp ••••••" else RupiahFormatter().format(amount)
}

@Composable
fun HomeRoute(
    onOpenHistory: () -> Unit,
    onOpenSaving: () -> Unit,
    onOpenBudget: () -> Unit,
    onOpenSettings: () -> Unit,
    onOpenMonthlyReport: () -> Unit,
    modifier: Modifier = Modifier,
    onHeroBoundsChanged: ((Rect) -> Unit)? = null,
    onStatusBoundsChanged: ((Rect) -> Unit)? = null,
    onFabBoundsChanged: ((Rect) -> Unit)? = null,
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
        onHeroBoundsChanged = onHeroBoundsChanged,
        onStatusBoundsChanged = onStatusBoundsChanged,
        onFabBoundsChanged = onFabBoundsChanged,
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
    onHeroBoundsChanged: ((Rect) -> Unit)? = null,
    onStatusBoundsChanged: ((Rect) -> Unit)? = null,
    onFabBoundsChanged: ((Rect) -> Unit)? = null,
) {
    val snackbarHostState = remember { SnackbarHostState() }
    val haptic = androidx.compose.ui.platform.LocalHapticFeedback.current
    val context = androidx.compose.ui.platform.LocalContext.current

    LaunchedEffect(uiState.addExpenseMessage) {
        val message = uiState.addExpenseMessage ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(message)
        haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
        runCatching {
            val effect = VibrationEffect.createOneShot(50L, VibrationEffect.DEFAULT_AMPLITUDE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                manager.defaultVibrator.vibrate(effect)
            } else {
                @Suppress("DEPRECATION")
                val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                @Suppress("DEPRECATION")
                vibrator.vibrate(effect)
            }
        }
        onEvent(HomeUiEvent.ClearMessage)
    }

    LaunchedEffect(uiState.addExpenseWarning) {
        val warning = uiState.addExpenseWarning ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(warning)
        onEvent(HomeUiEvent.ClearMessage)
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { onEvent(HomeUiEvent.OpenAddExpense) },
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = Color.White,
                modifier = Modifier
                    .semantics { contentDescription = "Catat pengeluaran" }
                    .onGloballyPositioned { coordinates ->
                        onFabBoundsChanged?.invoke(coordinates.boundsInWindow())
                    },
            ) {
                Icon(imageVector = Icons.Default.Add, contentDescription = "Add Expense")
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Spacer(modifier = Modifier.height(10.dp))

            // 1. Premium Header (Greetings + Hide Balance eye toggle)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = uiState.greeting + " 👋",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = uiState.activePeriodName,
                        style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    if (uiState.periodLabel.isNotBlank()) {
                        Text(
                            text = uiState.periodLabel,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                    if (uiState.scheduledDueCount > 0) {
                        Text(
                            text = "Ada ${uiState.scheduledDueCount} jadwal jatuh tempo hari ini/besok",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.primary,
                        )
                    }
                }
                
                IconButton(
                    onClick = { onEvent(HomeUiEvent.ToggleBalanceVisibility) }
                ) {
                    Icon(
                        imageVector = if (uiState.isBalanceHidden) Icons.Outlined.VisibilityOff else Icons.Outlined.Visibility,
                        contentDescription = "Hide/Show Balance",
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
            }

            // 2. Lihat Sisa Jatah (Central Interactive Gradient Card + Smart Status)
            PremiumDailyAllowanceCard(
                dailyAllowance = uiState.dailyAllowance,
                spentToday = uiState.spentToday,
                remainingToday = uiState.remainingToday,
                insight = uiState.insight,
                status = uiState.status,
                isHidden = uiState.isBalanceHidden,
                onCardBoundsChanged = onHeroBoundsChanged,
                onStatusBoundsChanged = onStatusBoundsChanged,
            )
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(
                    text = uiState.monthlyProgressLabel,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                NataProgressBar(progress = (uiState.monthlyProgressPercent / 100f).coerceIn(0f, 1f))
            }

            if (uiState.showBackupReminderBanner) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(onClick = onOpenSettings),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.tertiaryContainer,
                    ),
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text(
                            text = "Sudah 30 hari kamu belum backup. Lindungi datamu sekarang.",
                            modifier = Modifier.weight(1f),
                            style = MaterialTheme.typography.bodySmall,
                        )
                        TextButton(onClick = { onEvent(HomeUiEvent.DismissBackupReminder) }) {
                            Text("Tutup")
                        }
                    }
                }
            }
            if (uiState.spentToday == 0L) {
                Text(
                    text = "Belum ada transaksi hari ini. Yuk mulai catat!",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            // 3. Quick Action Buttons Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                NataSecondaryButton(
                    text = "Transaksi 📝", 
                    onClick = onOpenHistory,
                    modifier = Modifier.weight(1f)
                )
                NataSecondaryButton(
                    text = "Budget 📊", 
                    onClick = onOpenBudget,
                    modifier = Modifier.weight(1f)
                )
                NataSecondaryButton(
                    text = "Celengan 🐷", 
                    onClick = onOpenSaving,
                    modifier = Modifier.weight(1f)
                )
            }

            // 4. Piggy Bank Sweeper Card (Leftover piggy-bank sweep if remaining > 0)
            if (uiState.remainingToday > 0L) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .shadow(4.dp, shape = RoundedCornerShape(24.dp)),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.08f)
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("🚀", style = MaterialTheme.typography.titleLarge)
                            Column {
                                Text(
                                    text = "Amankan Sisa Jatah!",
                                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                    color = MaterialTheme.colorScheme.primary
                                )
                                Text(
                                    text = "Kamu punya sisa jatah Rp ${formatAmount(uiState.remainingToday, uiState.isBalanceHidden)} hari ini.",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                        
                        Text(
                            text = "Amankan sisa jatah ini ke tabungan sekarang agar tidak digunakan belanja sembarangan!",
                            style = MaterialTheme.typography.bodyMedium
                        )

                        NataPrimaryButton(
                            text = "Amankan ke Tabungan 💰",
                            onClick = { onEvent(HomeUiEvent.ManualAmankanSisa(uiState.remainingToday)) },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }

            // 5. Auto Sweep Config Toggle
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("🛡️", style = MaterialTheme.typography.titleMedium)
                        Column {
                            Text(
                                text = "Otomatis Amankan Sisa",
                                style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                            )
                            Text(
                                text = "Simpan sisa jatah harian ke tabungan",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                    
                    Switch(
                        checked = uiState.isAutoAmankanSisaEnabled,
                        onCheckedChange = { onEvent(HomeUiEvent.ToggleAutoAmankanSisa) },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = Color.White,
                            checkedTrackColor = MaterialTheme.colorScheme.primary
                        )
                    )
                }
            }

            // 6. Interactive 7-Day Spending Chart
            SevenDaySpendingChart(
                expenses = uiState.past7DaysExpenses,
                labels = uiState.past7DaysLabels,
                isHidden = uiState.isBalanceHidden
            )

            // 7. Celengan / Saving Goal progress
            CelenganProgressWidget(
                goalName = uiState.savingTargetName,
                targetAmount = uiState.savingTargetAmount,
                collectedAmount = uiState.savingCollectedAmount,
                isHidden = uiState.isBalanceHidden,
                onOpenSaving = onOpenSaving
            )

            // 8. Kategori Pengeluaran breakdown
            CategorySpendingBreakdown(
                categoryExpenses = uiState.categoryExpenses,
                isHidden = uiState.isBalanceHidden
            )

            // 9. Transaksi Terbaru
            RecentTransactionsWidget(
                transactions = uiState.recentTransactions,
                isHidden = uiState.isBalanceHidden,
                onOpenHistory = onOpenHistory
            )

            // 10. Secondary Navigation links
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                NataSecondaryButton(
                    text = "Laporan Bulanan 📊", 
                    onClick = onOpenMonthlyReport,
                    modifier = Modifier.weight(1f)
                )
                NataSecondaryButton(
                    text = "Pengaturan ⚙️", 
                    onClick = onOpenSettings,
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }

    if (uiState.showAddExpenseSheet) {
        AddExpenseBottomSheet(
            errorMessage = uiState.addExpenseError,
            isSaving = uiState.isSavingExpense,
            onDismiss = { onEvent(HomeUiEvent.CloseAddExpense) },
            onSave = { amount, category, note, date ->
                onEvent(
                    HomeUiEvent.SaveExpense(
                        amount = amount,
                        category = category,
                        note = note,
                        date = date,
                    ),
                )
            },
        )
    }

    if (uiState.showOverbudgetDialog) {
        AlertDialog(
            onDismissRequest = { onEvent(HomeUiEvent.DismissOverbudget) },
            title = { Text("Jatah hari ini terlewati") },
            text = {
                Text(
                    if (uiState.overbudgetAmount > 0L) {
                        "Pengeluaran hari ini melebihi jatah sebesar ${formatAmount(uiState.overbudgetAmount, uiState.isBalanceHidden)}. Budget akan disesuaikan agar tetap aman."
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

@Composable
fun PremiumDailyAllowanceCard(
    dailyAllowance: Long,
    spentToday: Long,
    remainingToday: Long,
    insight: String,
    status: BudgetStatus,
    isHidden: Boolean,
    modifier: Modifier = Modifier,
    onCardBoundsChanged: ((Rect) -> Unit)? = null,
    onStatusBoundsChanged: ((Rect) -> Unit)? = null,
) {
    val targetProgress = if (dailyAllowance > 0) (spentToday.toFloat() / dailyAllowance.toFloat()).coerceIn(0f, 1f) else 0f
    val progress by animateFloatAsState(targetValue = targetProgress, animationSpec = tween(durationMillis = 300), label = "progress")
    var showYesterday by remember { mutableStateOf(false) }
    val displayAmount = if (showYesterday) dailyAllowance else remainingToday
    var dragSum by remember { mutableStateOf(0f) }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .shadow(elevation = 4.dp, shape = RoundedCornerShape(16.dp))
            .onGloballyPositioned { coordinates -> onCardBoundsChanged?.invoke(coordinates.boundsInWindow()) }
            .clickable { showYesterday = !showYesterday },
            .pointerInput(Unit) {
                detectHorizontalDragGestures(
                    onHorizontalDrag = { _, dragAmount ->
                        dragSum += dragAmount
                    },
                    onDragEnd = {
                        if (kotlin.math.abs(dragSum) > 24f) {
                            showYesterday = dragSum > 0f
                        }
                        dragSum = 0f
                    },
                )
            },
        shape = RoundedCornerShape(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (showYesterday) "Jatah Kemarin" else "Jatah kamu hari ini",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Box(
                    modifier = Modifier.onGloballyPositioned { coordinates ->
                        onStatusBoundsChanged?.invoke(coordinates.boundsInWindow())
                    },
                ) {
                    NataStatusChip(status = status)
                }
            }

            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                NataAnimatedCounter(
                    targetValue = displayAmount,
                    durationMs = 300,
                    formatter = { value -> formatAmount(value, isHidden) },
                )
                Text(
                    text = if (showYesterday) "Geser lagi untuk kembali ke hari ini" else "Geser kiri/kanan untuk lihat perbandingan",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                NataProgressBar(progress = progress)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "Terpakai: ${formatAmount(spentToday, isHidden)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = "Jatah Maks: ${formatAmount(dailyAllowance, isHidden)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Text(
                text = insight,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
            )
        }
    }
}

@Composable
fun SevenDaySpendingChart(
    expenses: List<Long>,
    labels: List<String>,
    isHidden: Boolean,
    modifier: Modifier = Modifier
) {
    if (expenses.isEmpty() || labels.isEmpty()) return
    
    val maxExpense = maxOf(1L, expenses.maxOrNull() ?: 1L)
    var selectedBarIndex by remember { mutableStateOf(-1) }
    
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Chart Pengeluaran 7 Hari 📊",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.onSurface
                )
                if (selectedBarIndex != -1) {
                    Text(
                        text = formatAmount(expenses[selectedBarIndex], isHidden),
                        style = MaterialTheme.typography.labelLarge,
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold
                    )
                } else {
                    Text(
                        text = "Ketuk bar untuk detail",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(130.dp)
                    .padding(horizontal = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Bottom
            ) {
                expenses.forEachIndexed { index, amount ->
                    val progress = (amount.toFloat() / maxExpense.toFloat()).coerceIn(0.05f, 1f)
                    val label = labels.getOrNull(index) ?: ""
                    val isToday = index == expenses.lastIndex
                    
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier
                            .weight(1f)
                            .clickable {
                                selectedBarIndex = if (selectedBarIndex == index) -1 else index
                            }
                    ) {
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .fillMaxWidth()
                                .padding(horizontal = 6.dp),
                            contentAlignment = Alignment.BottomCenter
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxHeight(progress)
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(
                                        if (isToday) {
                                            Brush.verticalGradient(
                                                colors = listOf(
                                                    MaterialTheme.colorScheme.primary,
                                                    MaterialTheme.colorScheme.primary.copy(alpha = 0.6f)
                                                )
                                            )
                                        } else {
                                            Brush.verticalGradient(
                                                colors = listOf(
                                                    MaterialTheme.colorScheme.secondary.copy(alpha = 0.8f),
                                                    MaterialTheme.colorScheme.secondary.copy(alpha = 0.3f)
                                                )
                                            )
                                        }
                                    )
                            )
                        }
                        
                        Spacer(modifier = Modifier.height(8.dp))
                        
                        Text(
                            text = label,
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = if (isToday) FontWeight.Bold else FontWeight.Normal
                            ),
                            color = if (isToday) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun CelenganProgressWidget(
    goalName: String,
    targetAmount: Long,
    collectedAmount: Long,
    isHidden: Boolean,
    onOpenSaving: () -> Unit,
    modifier: Modifier = Modifier
) {
    if (targetAmount <= 0L) return
    val progress = (collectedAmount.toFloat() / targetAmount.toFloat()).coerceIn(0f, 1f)
    
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Text("🐷", style = MaterialTheme.typography.titleLarge)
            }
            
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(
                    text = "Celengan: $goalName",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                )
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "${(progress * 100).toInt()}% tercapai",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.primary
                    )
                    Text(
                        text = "${formatAmount(collectedAmount, isHidden)} / ${formatAmount(targetAmount, isHidden)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                NataProgressBar(progress = progress)
            }
            
            IconButton(onClick = onOpenSaving) {
                Icon(
                    imageVector = Icons.Default.TrendingUp,
                    contentDescription = "Buka Tabungan",
                    tint = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}

@Composable
fun CategorySpendingBreakdown(
    categoryExpenses: Map<String, Long>,
    isHidden: Boolean,
    modifier: Modifier = Modifier
) {
    if (categoryExpenses.isEmpty()) return
    
    val totalSpending = categoryExpenses.values.sum()
    
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Text(
                text = "Kategori Pengeluaran Hari Ini 🏷️",
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
            )
            
            val categoryItems = categoryExpenses.entries.sortedByDescending { it.value }
            if (categoryItems.size > 3) {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    items(categoryItems) { (category, amount) ->
                        val percentage = if (totalSpending > 0) (amount.toFloat() / totalSpending.toFloat()) else 0f
                        CategoryProgressCard(
                            category = category,
                            amount = amount,
                            percentage = percentage,
                            isHidden = isHidden,
                            modifier = Modifier.width(190.dp),
                        )
                    }
                }
            } else {
                categoryItems.forEach { (category, amount) ->
                    val percentage = if (totalSpending > 0) (amount.toFloat() / totalSpending.toFloat()) else 0f
                    CategoryProgressCard(
                        category = category,
                        amount = amount,
                        percentage = percentage,
                        isHidden = isHidden,
                    )
                }
            }
        }
    }
}

@Composable
private fun CategoryProgressCard(
    category: String,
    amount: Long,
    percentage: Float,
    isHidden: Boolean,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = category,
                style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Text(
                text = "${(percentage * 100).toInt()}%",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.primary,
            )
        }
        Text(
            text = formatAmount(amount, isHidden),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        NataProgressBar(
            progress = percentage,
            height = 6.dp,
        )
    }
}

@Composable
fun RecentTransactionsWidget(
    transactions: List<ExpenseTransactionEntity>,
    isHidden: Boolean,
    onOpenHistory: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f))
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Transaksi Terbaru 📝",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                )
                TextButton(onClick = onOpenHistory) {
                    Text("Lihat Semua")
                }
            }
            
            if (transactions.isEmpty()) {
                Text(
                    text = "Belum ada transaksi dalam periode ini.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            } else {
                transactions.forEach { tx ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        val categoryEmoji = when (tx.category.lowercase()) {
                            "makan", "makanan", "minum", "kuliner" -> "🍔"
                            "transportasi", "transport", "ojek", "bensin" -> "🚗"
                            "belanja", "shopping", "kebutuhan" -> "🛍️"
                            "tagihan", "listrik", "pulsa", "wifi" -> "💳"
                            "hiburan", "nonton", "game", "refreshing" -> "🍿"
                            "tabungan", "investasi", "celengan" -> "💰"
                            else -> "📦"
                        }
                        
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(MaterialTheme.colorScheme.surfaceVariant),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(categoryEmoji, style = MaterialTheme.typography.titleMedium)
                        }
                        
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = tx.note ?: tx.category,
                                style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            Text(
                                text = tx.category + " • " + tx.date.toString(),
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        
                        Text(
                            text = "- ${formatAmount(tx.amount, isHidden)}",
                            style = MaterialTheme.typography.bodyMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.error
                            )
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddExpenseBottomSheet(
    errorMessage: String?,
    isSaving: Boolean,
    onDismiss: () -> Unit,
    onSave: (Long, String, String?, LocalDate) -> Unit,
) {
    var amountText by remember { mutableStateOf(TextFieldValue("")) }
    var selectedCategory by remember { mutableStateOf(QuickExpenseCategories.first()) }
    var note by remember { mutableStateOf("") }
    var selectedDate by remember { mutableStateOf(LocalDate.now()) }
    var showDateMenu by remember { mutableStateOf(false) }
    val focusRequester = remember { FocusRequester() }
    val amountValidation = NominalInputValidator.validate(amountText.text)
    val dateOptions = remember { (0..30).map { LocalDate.now().minusDays(it.toLong()) } }
    val noteText = TransactionInputValidator.trimNoteToMaxLength(note)
    val noteCounter = TransactionInputValidator.noteCounter(noteText)
    val formatter = remember { DateTimeFormatter.ofPattern("d MMM yyyy", Locale("id", "ID")) }

    LaunchedEffect(Unit) { focusRequester.requestFocus() }

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text("Catat Pengeluaran 📝", style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold))
            if (!errorMessage.isNullOrBlank()) {
                Text(errorMessage, color = MaterialTheme.colorScheme.error)
            }
            NominalInputField(
                value = amountText,
                onValueChange = { amountText = it },
                label = "Nominal (Rp)",
                modifier = Modifier.focusRequester(focusRequester),
                autofocusRequester = focusRequester,
            )

            Text("Kategori", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold))
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

            ExposedDropdownMenuBox(
                expanded = showDateMenu,
                onExpandedChange = { showDateMenu = !showDateMenu },
            ) {
                OutlinedTextField(
                    value = selectedDate.format(formatter),
                    onValueChange = {},
                    label = { Text("Tanggal transaksi") },
                    modifier = Modifier
                        .fillMaxWidth()
                        .menuAnchor(),
                    readOnly = true,
                )
                ExposedDropdownMenu(
                    expanded = showDateMenu,
                    onDismissRequest = { showDateMenu = false },
                ) {
                    dateOptions.forEach { option ->
                        DropdownMenuItem(
                            text = { Text(option.format(formatter)) },
                            onClick = {
                                selectedDate = option
                                showDateMenu = false
                            },
                        )
                    }
                }
            }
            OutlinedTextField(
                value = noteText,
                onValueChange = { note = TransactionInputValidator.trimNoteToMaxLength(it) },
                label = { Text("Catatan") },
                placeholder = { Text("Opsional") },
                modifier = Modifier.fillMaxWidth(),
            )
            Text(noteCounter, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            NataPrimaryButton(
                text = "Simpan Pengeluaran 💾",
                onClick = {
                    onSave(
                        amountValidation.amount,
                        selectedCategory,
                        noteText.ifBlank { null },
                        selectedDate,
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = amountValidation.isValid,
                isLoading = isSaving,
                pulseWhenEnabled = amountValidation.isValid && !isSaving,
            )
        }
    }
}
