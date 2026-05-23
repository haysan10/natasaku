package com.natasaku.app.presentation.screen.setup

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.natasaku.app.domain.validation.NominalInputValidator
import com.natasaku.app.presentation.component.MoneyText
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton
import com.natasaku.app.presentation.component.NominalInputField
import java.time.LocalDate
import kotlinx.coroutines.launch

@Composable
fun SetupWelcomeRoute(onNextRoute: () -> Unit, vm: SetupViewModel) {
    val state by vm.uiState.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { vm.onEvent(SetupUiEvent.SetStep(SetupStep.WELCOME)) }
    SetupWelcomeScreen(
        error = state.errorMessage,
        warning = state.warningMessage,
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
        warning = state.warningMessage,
        onBack = {
            vm.onEvent(SetupUiEvent.Back)
            onBackRoute()
        },
        onSkip = {
            vm.onEvent(SetupUiEvent.Next)
            onNextRoute()
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
private fun SetupWelcomeScreen(error: String?, warning: String?, onNext: () -> Unit) {
    SetupScaffold("Selamat datang di NataSaku", error, warning) {
        Text("Atur gaji, tentukan jatah harian, dan pantau pengeluaranmu dengan lebih tenang.")
        NataPrimaryButton(text = "Mulai Atur Budget", onClick = onNext, modifier = Modifier.fillMaxWidth())
    }
}

@Composable
private fun SetupOnboardingScreen(
    error: String?,
    warning: String?,
    onBack: () -> Unit,
    onSkip: () -> Unit,
    onNext: () -> Unit,
) {
    val pages = listOf(
        "Tahu jatah aman setiap hari",
        "Dapat warning saat melewati budget",
        "Laporan bulanan yang jelas",
    )
    val pagerState = rememberPagerState(pageCount = { pages.size })
    val coroutineScope = rememberCoroutineScope()

    SetupScaffold("Onboarding", error, warning) {
        HorizontalPager(
            state = pagerState,
            modifier = Modifier
                .fillMaxWidth()
                .height(140.dp),
        ) { index ->
            Box(modifier = Modifier.fillMaxSize()) {
                Text(
                    text = pages[index],
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(8.dp),
                )
            }
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
        ) {
            repeat(pages.size) { index ->
                Box(
                    modifier = Modifier
                        .padding(horizontal = 4.dp)
                        .size(if (index == pagerState.currentPage) 10.dp else 8.dp)
                        .background(
                            color = if (index == pagerState.currentPage) {
                                MaterialTheme.colorScheme.primary
                            } else {
                                MaterialTheme.colorScheme.outlineVariant
                            },
                            shape = CircleShape,
                        ),
                )
            }
        }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack, modifier = Modifier.weight(1f))
            NataSecondaryButton(text = "Lewati", onClick = onSkip, modifier = Modifier.weight(1f))
            NataPrimaryButton(
                text = if (pagerState.currentPage == pages.lastIndex) "Lanjut" else "Berikutnya",
                onClick = {
                    if (pagerState.currentPage == pages.lastIndex) {
                        onNext()
                    } else {
                        coroutineScope.launch {
                            pagerState.animateScrollToPage(pagerState.currentPage + 1)
                        }
                    }
                },
                modifier = Modifier.weight(1f),
            )
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
    var startInput by remember(state.startDate) { mutableStateOf(state.startDate?.toString().orEmpty()) }
    var endInput by remember(state.endDate) { mutableStateOf(state.endDate?.toString().orEmpty()) }

    SetupScaffold("Setup Periode", state.errorMessage, state.warningMessage) {
        OutlinedTextField(
            value = state.periodName,
            onValueChange = onNameChange,
            label = { Text("Nama periode") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
        )
        OutlinedTextField(
            value = startInput,
            onValueChange = { startInput = it },
            label = { Text("Tanggal mulai (YYYY-MM-DD)") },
            placeholder = { Text(LocalDate.now().toString()) },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
        )
        OutlinedTextField(
            value = endInput,
            onValueChange = { endInput = it },
            label = { Text("Tanggal akhir (YYYY-MM-DD)") },
            placeholder = { Text(LocalDate.now().plusDays(30).toString()) },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
        )
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack, modifier = Modifier.weight(1f))
            NataPrimaryButton(
                text = "Lanjut",
                onClick = {
                    runCatching { LocalDate.parse(startInput) }.getOrNull()?.let(onStartDateSet)
                    runCatching { LocalDate.parse(endInput) }.getOrNull()?.let(onEndDateSet)
                    onNext()
                },
                modifier = Modifier.weight(1f),
            )
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
    var amountField by remember { mutableStateOf(TextFieldValue("")) }
    val nominalFocus = remember { FocusRequester() }
    val amountValidation = NominalInputValidator.validate(amountField.text)
    LaunchedEffect(Unit) { nominalFocus.requestFocus() }

    SetupScaffold("Setup Penghasilan", state.errorMessage, state.warningMessage) {
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Nama penghasilan") },
            placeholder = { Text("Contoh: Gaji utama") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
        )
        NominalInputField(
            value = amountField,
            onValueChange = { amountField = it },
            label = "Nominal",
            placeholder = "Rp 0",
            modifier = Modifier.focusRequester(nominalFocus),
            autofocusRequester = nominalFocus,
        )
        NataPrimaryButton(
            text = "Tambah Penghasilan",
            onClick = {
                onAddIncome(name, amountValidation.amount)
                if (amountValidation.isValid) {
                    name = ""
                    amountField = TextFieldValue("")
                }
            },
            enabled = name.isNotBlank() && amountValidation.isValid,
            modifier = Modifier.fillMaxWidth(),
        )
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.height(180.dp)) {
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
            NataSecondaryButton(text = "Kembali", onClick = onBack, modifier = Modifier.weight(1f))
            NataPrimaryButton(text = "Lanjut", onClick = onNext, modifier = Modifier.weight(1f))
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
    var amountField by remember { mutableStateOf(TextFieldValue("")) }
    val nominalFocus = remember { FocusRequester() }
    val amountValidation = NominalInputValidator.validate(amountField.text)
    LaunchedEffect(Unit) { nominalFocus.requestFocus() }

    SetupScaffold("Setup Pengeluaran Tetap", state.errorMessage, state.warningMessage) {
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Nama pengeluaran (opsional)") },
            placeholder = { Text("Kos / kontrakan") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
        )
        NominalInputField(
            value = amountField,
            onValueChange = { amountField = it },
            label = "Nominal",
            placeholder = "Rp 0",
            modifier = Modifier.focusRequester(nominalFocus),
            autofocusRequester = nominalFocus,
        )
        NataPrimaryButton(
            text = "Tambah Pengeluaran",
            onClick = {
                onAddItem(name, amountValidation.amount)
                if (amountValidation.isValid) {
                    name = ""
                    amountField = TextFieldValue("")
                }
            },
            enabled = amountValidation.isValid,
            modifier = Modifier.fillMaxWidth(),
        )
        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.height(180.dp)) {
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
            NataSecondaryButton(text = "Kembali", onClick = onBack, modifier = Modifier.weight(1f))
            NataPrimaryButton(text = "Lanjut", onClick = onNext, modifier = Modifier.weight(1f))
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
    var amountField by remember(state.savingTarget) {
        mutableStateOf(TextFieldValue(if (state.savingTarget == 0L) "" else state.savingTarget.toString()))
    }
    val nominalFocus = remember { FocusRequester() }
    val amountValidation = NominalInputValidator.validate(amountField.text)
    LaunchedEffect(Unit) { nominalFocus.requestFocus() }

    SetupScaffold("Setup Target Tabungan", state.errorMessage, state.warningMessage) {
        NominalInputField(
            value = amountField,
            onValueChange = { amountField = it },
            label = "Target tabungan (opsional)",
            placeholder = "Rp 0",
            modifier = Modifier.focusRequester(nominalFocus),
            autofocusRequester = nominalFocus,
        )
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NataSecondaryButton(text = "Kembali", onClick = onBack, modifier = Modifier.weight(1f))
            NataSecondaryButton(text = "Lewati", onClick = onSkip, modifier = Modifier.weight(1f))
            NataPrimaryButton(
                text = "Lanjut",
                onClick = {
                    onUpdateSaving(if (amountValidation.isEmpty) 0L else amountValidation.amount)
                    onNext()
                },
                modifier = Modifier.weight(1f),
                enabled = amountValidation.isEmpty || amountValidation.isValid,
            )
        }
    }
}

@Composable
private fun SetupReviewScreen(state: SetupUiState, onBack: () -> Unit, onFinish: () -> Unit) {
    val review = state.review
    SetupScaffold("Review Budget", state.errorMessage, state.warningMessage) {
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
            NataSecondaryButton(text = "Kembali", onClick = onBack, modifier = Modifier.weight(1f))
            NataPrimaryButton(
                text = "Mulai Gunakan NataSaku",
                onClick = onFinish,
                modifier = Modifier.weight(1f),
                isLoading = state.isSaving,
            )
        }
    }
}

@Composable
private fun SetupScaffold(
    title: String,
    error: String?,
    warning: String?,
    content: @Composable () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text(title, style = MaterialTheme.typography.titleLarge)
        if (!error.isNullOrBlank()) {
            Text(error, color = MaterialTheme.colorScheme.error)
        }
        if (!warning.isNullOrBlank()) {
            Text(warning, color = MaterialTheme.colorScheme.tertiary)
        }
        content()
    }
}
