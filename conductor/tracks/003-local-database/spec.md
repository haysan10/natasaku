# Track 003 — Local Database Spec

## Goal

Implement local data persistence using Room and DataStore for all NataSaku MVP data.

## Scope

- Room entities.
- DAO interfaces.
- Database class.
- Type converters.
- Repository implementations.
- DataStore preferences.
- Basic DAO tests.

## Required Entities

- BudgetPeriodEntity.
- IncomeSourceEntity.
- FixedExpenseEntity.
- ExpenseTransactionEntity.
- SavingTargetEntity.
- SavingAllocationEntity.
- DailyBudgetSnapshotEntity.

## Requirements

1. Store all financial data locally.
2. Use Long for money.
3. Use LocalDate converters.
4. Use Instant converters.
5. Use soft delete for transactions.
6. Expose Flow where screen needs reactive updates.
7. Do not expose entities to UI.
8. DataStore stores app preferences.

## Acceptance Criteria

- DAOs compile.
- Database compiles.
- Repository mapping exists.
- Active period can be stored and observed.
- Transactions can be inserted, edited, filtered, and soft deleted.
- DataStore preferences can be read and written.

## Out of Scope

- Cloud sync.
- Login.
- Online backup.
