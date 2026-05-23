# Track 008 — Saving and Leftover Spec

## Goal

Implement Saving screen and leftover allocation flow.

## Requirements

1. Show saving target.
2. Show progress bar.
3. Show total collected.
4. Show saving allocation history.
5. Show empty state if no target.
6. Leftover dialog appears when remainingToday > 0 and not allocated.
7. User can choose allocation:
   - Add to tomorrow.
   - Add to saving.
   - Auto split.
   - Free balance.
8. Allocation is saved locally.

## Acceptance Criteria

- Saving progress correct.
- Allocation history correct.
- Leftover allocation only happens once per day unless edited.
- If no saving target, add-to-saving is handled safely.
- Copywriting is friendly.

## Out of Scope

- Investment features.
- Bank savings account integration.
