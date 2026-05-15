# Track 004 — Budget Calculation Spec

## Goal

Implement all domain calculation logic for budgeting, daily allowance, daily status, overbudget adjustment, leftover allocation, and monthly report summary.

## Scope

- Domain models.
- BudgetCalculator.
- DailyBudgetCalculator.
- OverbudgetCalculator.
- LeftoverAllocationCalculator.
- MonthlyReportCalculator.
- Validation.
- Unit tests.

## Requirements

1. Domain code must be pure Kotlin.
2. No Android Context.
3. No Compose.
4. No Room.
5. Money uses Long.
6. Date calculation uses LocalDate.
7. Period day count is inclusive.
8. Negative flexible fund handled safely.
9. Daily status calculated deterministically.
10. Unit tests cover edge cases.

## Acceptance Criteria

- Budget formulas produce expected results.
- Daily status is correct.
- Overbudget adjustment is correct.
- Leftover allocation is correct.
- Monthly report summary is correct.
- Tests pass.

## Out of Scope

- UI.
- Database entities.
- Export file rendering.
