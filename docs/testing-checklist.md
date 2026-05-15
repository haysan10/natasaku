# docs/testing-checklist.md - NataSaku Testing Checklist

## Purpose

This checklist ensures NataSaku is correct, stable, offline-first, and safe for user financial data.

## Unit Tests

### Budget Calculation

- [ ] Total income from one source.
- [ ] Total income from multiple sources.
- [ ] Total fixed expense.
- [ ] Total saving target.
- [ ] Flexible fund normal.
- [ ] Flexible fund zero.
- [ ] Flexible fund negative.
- [ ] One-day period.
- [ ] Monthly period inclusive days.
- [ ] Daily allowance rounding down.

### Daily Status

- [ ] SAFE at 0%.
- [ ] SAFE at 70%.
- [ ] WARNING above 70%.
- [ ] WARNING at 100%.
- [ ] OVER_BUDGET above 100%.
- [ ] Zero allowance and zero spent = SAFE.
- [ ] Zero allowance and positive spent = OVER_BUDGET.

### Overbudget

- [ ] No overbudget if spent below allowance.
- [ ] Overbudget amount correct.
- [ ] Adjustment per day correct.
- [ ] Overbudget on last day creates no future adjustment.
- [ ] Remainder handling does not lose money.

### Leftover

- [ ] No allocation when leftover <= 0.
- [ ] Add to tomorrow.
- [ ] Add to saving.
- [ ] Auto split even amount.
- [ ] Auto split odd amount.
- [ ] Free balance.
- [ ] Add to saving without target handled safely.

### Monthly Report

- [ ] Total expense.
- [ ] Remaining balance.
- [ ] Biggest category.
- [ ] Most expensive day.
- [ ] Most frugal day.
- [ ] Overbudget day count.
- [ ] Average daily spending.
- [ ] Empty transaction report.

## DAO Tests

- [ ] Insert active period.
- [ ] Observe active period.
- [ ] Deactivate previous period.
- [ ] Insert income source.
- [ ] Insert fixed expense.
- [ ] Insert transaction.
- [ ] Observe transactions by period.
- [ ] Observe transactions by date.
- [ ] Search transactions by note.
- [ ] Filter transactions by category.
- [ ] Soft delete transaction.
- [ ] Insert saving target.
- [ ] Insert saving allocation.
- [ ] Upsert daily snapshot.

## ViewModel Tests

- [ ] Setup period validation.
- [ ] Setup income total.
- [ ] Setup fixed expense total.
- [ ] Saving skip.
- [ ] Review budget calculation state.
- [ ] Home dashboard load.
- [ ] Add expense validation.
- [ ] Add expense success.
- [ ] Overbudget event emitted.
- [ ] Transaction history search.
- [ ] Transaction delete.
- [ ] Settings update.
- [ ] Export loading/success/error.

## Compose UI Tests

### Setup

- [ ] Welcome CTA opens onboarding.
- [ ] Onboarding progresses.
- [ ] Setup period validates dates.
- [ ] Setup income adds source.
- [ ] Setup fixed expense accepts categories.
- [ ] Setup saving can be skipped.
- [ ] Review budget CTA opens Home.

### Home

- [ ] Daily allowance displayed.
- [ ] FAB opens bottom sheet.
- [ ] Add expense saves.
- [ ] Dashboard updates after save.
- [ ] Overbudget dialog appears.

### History

- [ ] Transactions list appears.
- [ ] Search filters list.
- [ ] Category chip filters list.
- [ ] Edit transaction works.
- [ ] Delete confirmation appears.

### Report

- [ ] Monthly report metrics visible.
- [ ] Download PDF button visible.
- [ ] Export CSV button visible.
- [ ] Export success screen appears.

### Settings

- [ ] Theme selector visible.
- [ ] Backup button visible.
- [ ] Restore button visible.

## Manual QA

- [ ] Fresh install opens Welcome.
- [ ] Onboarding works.
- [ ] Setup can be completed.
- [ ] Home appears after setup.
- [ ] Enable airplane mode.
- [ ] App opens offline.
- [ ] Add expense works offline.
- [ ] Export works offline.
- [ ] Backup works offline.
- [ ] Restore works offline.

## Accessibility QA

- [ ] Buttons have clear labels.
- [ ] Icon-only buttons have contentDescription.
- [ ] Touch targets are at least 48dp.
- [ ] Status uses text and color.
- [ ] Inputs have labels.
- [ ] Error messages are visible.
- [ ] Text scaling works.
- [ ] Dark mode contrast works.
- [ ] TalkBack order is logical.
