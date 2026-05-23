# docs/release-checklist.md - NataSaku MVP Release Checklist

## Purpose

Use this checklist before declaring NataSaku MVP complete.

## Product Scope

- [ ] App is Android native.
- [ ] App uses Kotlin.
- [ ] App uses Jetpack Compose.
- [ ] App uses Material Design 3.
- [ ] App works offline.
- [ ] App stores data locally.
- [ ] No login.
- [ ] No backend.
- [ ] No cloud sync.
- [ ] No bank integration.
- [ ] No ads.
- [ ] No analytics SDK.

## Core User Flows

### First-Time Setup

- [ ] Splash works.
- [ ] Welcome works.
- [ ] Onboarding works.
- [ ] Setup Period works.
- [ ] Setup Income works.
- [ ] Setup Fixed Expense works.
- [ ] Setup Saving Target works.
- [ ] Review Budget works.
- [ ] Home opens after setup.

### Daily Usage

- [ ] Home dashboard shows daily allowance.
- [ ] Add Expense Bottom Sheet opens.
- [ ] Expense can be saved.
- [ ] Dashboard updates.
- [ ] Status updates.
- [ ] Overbudget warning appears.
- [ ] Leftover allocation works if implemented.

### Transactions

- [ ] History shows transactions.
- [ ] Transactions grouped by date.
- [ ] Search works.
- [ ] Category filter works.
- [ ] Edit works.
- [ ] Delete works.
- [ ] Delete recalculates dashboard/report.

### Budget

- [ ] Budget screen shows active period.
- [ ] Shows income.
- [ ] Shows fixed expenses.
- [ ] Shows saving target.
- [ ] Shows daily allowance.
- [ ] Shows adjustment.

### Saving

- [ ] Saving screen shows target.
- [ ] Progress correct.
- [ ] Allocation history visible.
- [ ] Empty state works.

### Report

- [ ] Monthly report shows all required metrics.
- [ ] Recommendation is friendly.
- [ ] Empty state works.

### Export

- [ ] CSV export works.
- [ ] PDF export works.
- [ ] Export success screen works.
- [ ] Share file works.
- [ ] Open file works.
- [ ] Export error handled.

### Settings

- [ ] Currency setting visible.
- [ ] Theme setting works.
- [ ] Default leftover allocation works.
- [ ] Reminder setting works if implemented.
- [ ] Backup works.
- [ ] Restore works.
- [ ] About app visible.

## Calculation Quality

- [ ] Flexible fund correct.
- [ ] Daily allowance correct.
- [ ] Inclusive period day count correct.
- [ ] Status safe/warning/overbudget correct.
- [ ] Overbudget adjustment correct.
- [ ] Leftover allocation correct.
- [ ] Monthly report metrics correct.
- [ ] Money uses Long, not Double/Float.

## UI Quality

- [ ] Light mode polished.
- [ ] Dark mode polished.
- [ ] Design tokens used.
- [ ] No random hardcoded colors.
- [ ] Cards consistent.
- [ ] Buttons consistent.
- [ ] Typography readable.
- [ ] Dashboard not crowded.
- [ ] Add expense fast to use.

## Copywriting

- [ ] Indonesian copy.
- [ ] Friendly tone.
- [ ] Non-judgmental.
- [ ] No “kamu boros”.
- [ ] No “budget gagal”.
- [ ] No shame-based copy.
- [ ] Error messages explain recovery.
- [ ] Warning copy is calm.

## Accessibility

- [ ] Touch targets 48dp.
- [ ] Icon buttons labelled.
- [ ] Inputs labelled.
- [ ] Status not color-only.
- [ ] Progress has text summary.
- [ ] Text scaling acceptable.
- [ ] Dark mode contrast acceptable.
- [ ] Dialogs have clear titles/actions.

## Release Blockers

Do not release if:

- [ ] Wrong money calculation exists.
- [ ] App crashes in setup flow.
- [ ] App crashes when adding expense.
- [ ] Data loss occurs in normal use.
- [ ] Export generates corrupt files.
- [ ] Restore corrupts data.
- [ ] App requires internet.
- [ ] Login/backend/cloud was added.
- [ ] Main dashboard is unreadable.
- [ ] Overbudget copy is judgmental.
- [ ] Accessibility critical issue remains.
