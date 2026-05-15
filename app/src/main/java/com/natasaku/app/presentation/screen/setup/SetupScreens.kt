package com.natasaku.app.presentation.screen.setup

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton
import java.time.LocalDate

@Composable
fun SetupWelcomeRoute(onNextRoute: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.WELCOME)) }
    SetupWelcomeScreen(
        error = state.errorMessage,
        onNext = {
            vm.onEvent(SetupUiEvent.Next)
            onNextRoute()
        },
    )
}

@Composable
fun SetupOnboardingRoute(onNextRoute: () -> Unit, onBackRoute: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.ONBOARDING)) }
    SetupOnboardingScreen(
        error = state.errorMessage,
        onBack = {
            vm.onEvent(SetupUiEvent.Back)
            onBackRoute()
        },
        onNext = {
            vm.onEvent(SetupUiEvent.Next)
            onNextRoute()
        },
    )
}

@Composable
fun SetupPeriodRoute(onNextRoute: () -> Unit, onBackRoute: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.PERIOD)) }
    SetupPeriodScreen(
        state = state,
        onBack = {
            vm.onEvent(SetupUiEvent.Back)
            onBackRoute()
        },
        onNext = {
            vm.onEvent(SetupUiEvent.Next)
            if (vm.uiState.value.currentStep == SetupStep.INCOME) onNextRoute()
        },
        onNameChange = { vm.onEvent(SetupUiEvent.UpdatePeriodName(it)) },
        onStartDateSet = { vm.onEvent(SetupUiEvent.UpdateStartDate(it)) },
        onEndDateSet = { vm.onEvent(SetupUiEvent.UpdateEndDate(it)) },
    )
}

@Composable
fun SetupIncomeRoute(onNextRoute: () -> Unit, onBackRoute: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.INCOME)) }
    SetupIncomeScreen(
        state = state,
        onBack = {
            vm.onEvent(SetupUiEvent.Back)
            onBackRoute()
        },
        onNext = {
            vm.onEvent(SetupUiEvent.Next)
            if (vm.uiState.value.currentStep == SetupStep.FIXED_EXPENSE) onNextRoute()
        },
        onAddIncome = { name, amount -> vm.onEvent(SetupUiEvent.AddIncome(name, amount)) },
        onRemoveIncome = { vm.onEvent(SetupUiEvent.RemoveIncome(it)) },
    )
}

@Composable
fun SetupFixedExpenseRoute(onNextRoute: () -> Unit, onBackRoute: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.FIXED_EXPENSE)) }
    SetupFixedExpenseScreen(
        state = state,
        onBack = {
            vm.onEvent(SetupUiEvent.Back)
            onBackRoute()
        },
        onNext = {
            vm.onEvent(SetupUiEvent.Next)
            onNextRoute()
        },
        onAddItem = { name, amount -> vm.onEvent(SetupUiEvent.AddFixedExpense(name, amount)) },
        onRemoveItem = { vm.onEvent(SetupUiEvent.RemoveFixedExpense(it)) },
    )
}

@Composable
fun SetupSavingRoute(onNextRoute: () -> Unit, onBackRoute: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.SAVING)) }
    SetupSavingScreen(
        state = state,
        onBack = {
            vm.onEvent(SetupUiEvent.Back)
            onBackRoute()
        },
        onNext = {
            vm.onEvent(SetupUiEvent.Next)
            onNextRoute()
        },
        onSkip = {
            vm.onEvent(SetupUiEvent.UpdateSavingTarget(0))
            vm.onEvent(SetupUiEvent.Next)
            onNextRoute()
        },
        onUpdateSaving = { vm.onEvent(SetupUiEvent.UpdateSavingTarget(it)) },
    )
}

@Composable
fun SetupReviewRoute(onBackRoute: () -> Unit, onFinish: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.REVIEW)) }
    SetupReviewScreen(
        state = state,
        onBack = {
            vm.onEvent(SetupUiEvent.Back)
            onBackRoute()
        },
        onFinish = { vm.completeSetup(onFinish) },
    )
}

@Composable
private fun SetupWelcomeScreen(error: String?, onNext: () -> Unit) {
    SetupScaffold("Selamat datang di NataSaku", error) {
        Text("Atur gaji, tentukan jatah harian, dan pantau pengeluaranmu dengan lebih tenang.")
        NataPrimaryButton(text = "Mulai Atur Budget", onClick = onNext)
    }
}

@Composable
private fun SetupOnboardingScreen(error: String?, onBack: () -> Unit, onNext: () -> Unit) {
    SetupScaffold("Onboarding", error) {
        Text("Tahu jatah aman setiap hari")
        Text("Dapat warning saat melewati budget")
        Text("Laporan bulanan yang jelas")
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack)
            NataPrimaryButton(text = "Lanjut", onClick = onNext)
        }
    }
}

@Composable
private fun SetupPeriodScreen(
    state: SetupUiState,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onNameChange: (String) -> Unit,
    onStartDateSet: (LocalDate) -> Unit,
    onEndDateSet: (LocalDate) -> Unit,
) {
    var startInput by remember { mutableStateOf(state.startDate?.toString().orEmpty()) }
    var endInput by remember { mutableStateOf(state.endDate?.toString().orEmpty()) }

    SetupScaffold("Setup Periode", state.errorMessage) {
        OutlinedTextField(value = state.periodName, onValueChange = onNameChange, label = { Text("Nama periode") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(value = startInput, onValueChange = { startInput = it }, label = { Text("Tanggal mulai (YYYY-MM-DD)") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(value = endInput, onValueChange = { endInput = it }, label = { Text("Tanggal akhir (YYYY-MM-DD)") }, modifier = Modifier.fillMaxWidth())
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack)
            NataPrimaryButton(text = "Lanjut", onClick = {
                runCatching { LocalDate.parse(startInput) }.getOrNull()?.let(onStartDateSet)
                runCatching { LocalDate.parse(endInput) }.getOrNull()?.let(onEndDateSet)
                onNext()
            })
        }
    }
}

@Composable
private fun SetupIncomeScreen(
    state: SetupUiState,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onAddIncome: (String, Long) -> Unit,
    onRemoveIncome: (String) -> Unit,
) {
    var name by remember { mutableStateOf("") }
    var amount by remember { mutableLongStateOf(0L) }

    SetupScaffold("Setup Penghasilan", state.errorMessage) {
        OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("Nama penghasilan") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(value = if (amount == 0L) "" else amount.toString(), onValueChange = { amount = it.toLongOrNull() ?: 0L }, label = { Text("Nominal") }, modifier = Modifier.fillMaxWidth())
        NataPrimaryButton(text = "Tambah Penghasilan", onClick = { onAddIncome(name, amount); name = ""; amount = 0L })
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(state.incomes, key = { it.id }) { item ->
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(item.name)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        MoneyText(item.amount)
                        NataSecondaryButton(text = "Hapus", onClick = { onRemoveIncome(item.id) })
                    }
                }
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack)
            NataPrimaryButton(text = "Lanjut", onClick = onNext)
        }
    }
}

@Composable
private fun SetupFixedExpenseScreen(
    state: SetupUiState,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onAddItem: (String, Long) -> Unit,
    onRemoveItem: (String) -> Unit,
) {
    var name by remember { mutableStateOf("") }
    var amount by remember { mutableLongStateOf(0L) }

    SetupScaffold("Setup Pengeluaran Tetap", state.errorMessage) {
        OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("Nama pengeluaran") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(value = if (amount == 0L) "" else amount.toString(), onValueChange = { amount = it.toLongOrNull() ?: 0L }, label = { Text("Nominal") }, modifier = Modifier.fillMaxWidth())
        NataPrimaryButton(text = "Tambah Pengeluaran", onClick = { onAddItem(name, amount); name = ""; amount = 0L })
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(state.fixedExpenses, key = { it.id }) { item ->
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(item.name)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        MoneyText(item.amount)
                        NataSecondaryButton(text = "Hapus", onClick = { onRemoveItem(item.id) })
                    }
                }
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack)
            NataPrimaryButton(text = "Lanjut", onClick = onNext)
        }
    }
}

@Composable
private fun SetupSavingScreen(
    state: SetupUiState,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onSkip: () -> Unit,
    onUpdateSaving: (Long) -> Unit,
) {
    var amount by remember { mutableLongStateOf(state.savingTarget) }
    SetupScaffold("Setup Target Tabungan", state.errorMessage) {
        OutlinedTextField(value = if (amount == 0L) "" else amount.toString(), onValueChange = { amount = it.toLongOrNull() ?: 0L }, label = { Text("Target tabungan (opsional)") }, modifier = Modifier.fillMaxWidth())
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack)
            NataSecondaryButton(text = "Lewati", onClick = onSkip)
            NataPrimaryButton(text = "Lanjut", onClick = { onUpdateSaving(amount); onNext() })
        }
    }
}

@Composable
private fun SetupReviewScreen(state: SetupUiState, onBack: () -> Unit, onFinish: () -> Unit) {
    val review = state.review
    SetupScaffold("Review Budget", state.errorMessage) {
        Text("Total Penghasilan")
        MoneyText(review.totalIncome)
        Text("Total Pengeluaran Tetap")
        MoneyText(review.totalFixedExpense)
        Text("Target Tabungan")
        MoneyText(review.totalSavingTarget)
        Text("Dana Fleksibel")
        MoneyText(review.flexibleFund)
        Text("Jatah Harian")
        MoneyText(review.baseDailyAllowance)
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack)
            NataPrimaryButton(text = "Mulai Gunakan NataSaku", onClick = onFinish)
        }
    }
}

@Composable
private fun SetupScaffold(title: String, error: String?, content: @Composable () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text(title)
        if (!error.isNullOrBlank()) {
            Text(error)
        }
        content()
    }
}
