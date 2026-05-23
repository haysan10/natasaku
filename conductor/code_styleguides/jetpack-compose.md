# conductor/code_styleguides/jetpack-compose.md — Jetpack Compose Style Guide for NataSaku

## General Principles

1. Use Material Design 3.
2. Keep Composables stateless where practical.
3. Use state hoisting.
4. Use `UiState` from ViewModel.
5. Send `UiEvent` to ViewModel.
6. Do not put financial formulas in Composables.
7. Use theme tokens.
8. Support light and dark mode.
9. Support accessibility.
10. Keep Home dashboard clean and readable.

---

## Naming

Screens:
```kotlin
HomeDashboardScreen
SetupIncomeScreen
MonthlyReportScreen
```

Components:
```kotlin
NataPrimaryButton
FinanceSummaryCard
StatusChip
MoneyText
TransactionRow
```

ViewModels:
```kotlin
HomeViewModel
SetupBudgetViewModel
TransactionHistoryViewModel
```

UiState:
```kotlin
HomeUiState
SetupIncomeUiState
```

UiEvent:
```kotlin
HomeUiEvent
SetupIncomeUiEvent
```

---

## Screen Pattern

Preferred:

```kotlin
@Composable
fun HomeRoute(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    HomeDashboardScreen(
        uiState = uiState,
        onEvent = viewModel::onEvent
    )
}

@Composable
fun HomeDashboardScreen(
    uiState: HomeUiState,
    onEvent: (HomeUiEvent) -> Unit
) {
    // UI only
}
```

If not using Hilt, inject ViewModel according to project setup.

---

## State Rules

Use:
- `rememberSaveable` for form field state.
- `collectAsStateWithLifecycle` for ViewModel StateFlow.
- `LaunchedEffect` for one-time events.
- `derivedStateOf` only when useful.

Avoid:
- mutable global state.
- business calculation in Composable.
- direct database calls.
- heavy work during recomposition.

---

## UI Components

### Buttons

Use shared buttons:
- `NataPrimaryButton`.
- `NataSecondaryButton`.

### Cards

Use:
- Material 3 `Card`.
- Rounded corners 20–28dp.
- Clean padding.
- No heavy shadow.

### Inputs

Use:
- `OutlinedTextField`.
- Label always visible.
- Error near input.
- Keyboard type numeric for money.

### Bottom Sheet

Use:
- `ModalBottomSheet`.
- Radius top 28dp.
- Sticky save action if possible.

### Dialog

Use:
- `AlertDialog`.
- Clear title.
- Friendly body.
- Clear primary and secondary actions.

---

## Home Dashboard Requirements

The visual hierarchy must be:

1. Greeting.
2. Active period.
3. Daily allowance hero card.
4. Used and remaining today.
5. Status chip.
6. Monthly progress.
7. Category summary.
8. Insight.
9. FAB.

Do not crowd the dashboard with too many charts.

---

## Add Expense Bottom Sheet Requirements

Must support fast input:

1. Nominal input at top.
2. Autofocus nominal.
3. Numeric keyboard.
4. Category chips/grid.
5. Date default today.
6. Note optional.
7. Save button visible.

---

## Accessibility Rules

1. Minimum touch target 48dp.
2. Icon-only buttons require contentDescription.
3. Decorative icons use `contentDescription = null`.
4. Status must include text, not color only.
5. Form inputs require labels.
6. Error messages must be readable by screen readers.
7. Chart/progress needs text summary.
8. Dialog should have clear title and action labels.

---

## Preview Rules

Create previews for:

- Home dashboard light.
- Home dashboard dark.
- Add expense bottom sheet.
- Warning dialog.
- Leftover dialog.
- Empty state.
- Finance summary card.
- Status chips.

Preview data should not be used as production data.

---

## Theme Rules

Use:
```kotlin
MaterialTheme.colorScheme.primary
MaterialTheme.typography.titleLarge
MaterialTheme.shapes.large
```

Avoid:
```kotlin
Color(0xFF0F9F8C)
TextStyle(fontSize = 17.sp)
RoundedCornerShape(23.dp)
```

except inside theme/token definitions.

---

## Error and Empty States

Every important screen should have:
- Loading state.
- Empty state.
- Error state.
- Content state.

---

## Anti-Patterns

Avoid:
- Giant Composable with all UI and logic.
- Repeated hardcoded colors.
- Business formulas in UI.
- Non-scrollable screen with too much content.
- Small touch targets.
- Overly complex charts in MVP.
- UI copy that blames user.

---

## Definition of Good Compose Code

Good Compose code in NataSaku is:
- simple,
- previewable,
- accessible,
- theme-based,
- state-driven,
- offline-friendly,
- easy to test,
- consistent with Material 3.
