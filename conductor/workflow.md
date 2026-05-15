# conductor/workflow.md — NataSaku Development Workflow

## Development Philosophy

NataSaku should be built with context-driven, track-based development.

Rules:
1. Context before code.
2. Small tracks.
3. Clear acceptance criteria.
4. Test business logic.
5. Keep app offline-first.
6. Preserve architecture boundaries.
7. Avoid scope creep.
8. Keep UI friendly and accessible.

---

## Standard Work Cycle

For every task:

1. Read `conductor/index.md`.
2. Read `product.md`.
3. Read `product-guidelines.md`.
4. Read `tech-stack.md`.
5. Read active track `spec.md`.
6. Read active track `plan.md`.
7. Write short implementation plan.
8. Implement.
9. Run relevant tests.
10. Update progress if instructed.
11. Report results.

---

## Track Status Values

Use these statuses in `tracks.md` and `metadata.json`:

- planned
- ready
- in_progress
- blocked
- review
- done
- deferred

---

## Task Status Symbols

In `plan.md`:

- `[ ]` Not started.
- `[~]` In progress.
- `[x]` Done.
- `[!]` Blocked.
- `[-]` Deferred.

---

## Required Output After Work

Every agent should report:

```text
Summary:
- ...

Files changed:
- ...

Tests:
- ...

Risks / TODO:
- ...
```

---

## Definition of Done for Any Feature

A feature is done when:

1. Requirement is implemented.
2. Data persists locally if required.
3. Business logic is not inside UI.
4. Unit tests exist for important logic.
5. UI handles loading/empty/error/success where relevant.
6. Light and dark mode are not broken.
7. Accessibility basics are considered.
8. Copywriting follows NataSaku tone.
9. Feature works offline.
10. No forbidden feature was added.

---

## Quality Gates

### Before Merge / Completion

- Project builds.
- Relevant unit tests pass.
- No forbidden dependency added.
- No backend/login/cloud introduced.
- No money stored as Double/Float.
- No business formula hidden inside Composable.
- No major accessibility issue in main flow.
- No shame-based copy.

### Before MVP Release

- First-time flow works.
- Daily dashboard works.
- Add expense works.
- Overbudget warning works.
- Transaction history works.
- Budget detail works.
- Saving works.
- Monthly report works.
- CSV export works.
- PDF export works.
- Settings works.
- Backup works.
- Restore works.
- Dark mode works.
- Offline mode works.

---

## Testing Strategy

### Unit Tests

Required for:
- Budget calculation.
- Daily allowance.
- Daily status.
- Overbudget adjustment.
- Leftover allocation.
- Monthly report calculation.
- CSV generation.
- Backup validation.

### DAO Tests

Required for:
- Insert/read/update.
- Active period.
- Transaction search/filter.
- Soft delete.
- Snapshot upsert.

### ViewModel Tests

Required for:
- Setup validation.
- Add expense.
- Dashboard state.
- Warning events.
- Export states.

### Compose UI Tests

Required for:
- Setup flow.
- Add expense bottom sheet.
- Overbudget dialog.
- Transaction history.
- Settings.

---

## Git / Commit Guidance

Use small commits.

Suggested commit prefixes:
- `feat:`
- `fix:`
- `test:`
- `refactor:`
- `docs:`
- `chore:`
- `style:`

Examples:
- `feat: add budget calculation use cases`
- `test: cover daily status calculation`
- `feat: implement add expense bottom sheet`
- `docs: update conductor track status`

---

## Dependency Management

If adding a dependency:
1. Explain why.
2. Ensure it is compatible with offline-first.
3. Ensure it does not collect data.
4. Add to `tech-stack.md`.
5. Keep dependency count low.

---

## Anti-Patterns to Avoid

Do not:
- Build everything in one giant screen.
- Put calculation logic in Composables.
- Query Room from UI directly.
- Add backend “just in case”.
- Add login “for future sync”.
- Add cloud backup.
- Use aggressive error tone.
- Use hardcoded design values everywhere.
- Ignore test coverage for money logic.
- Make Home dashboard crowded.

---

## Session Handoff

At the end of a work session, note:

1. What was completed.
2. What is partially done.
3. What is blocked.
4. What files were changed.
5. What tests were run.
6. What should be done next.
