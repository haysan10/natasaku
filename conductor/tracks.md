# conductor/tracks.md — NataSaku Work Tracks

## Track Registry

| Track ID | Name | Priority | Status | Depends On |
|---|---|---:|---|---|
| 001 | Project Foundation | P0 | done | none |
| 002 | Design System | P0 | done | 001 |
| 003 | Local Database | P0 | done | 001 |
| 004 | Budget Calculation | P0 | done | 001 |
| 005 | Setup Flow | P0 | done | 001, 002, 003, 004 |
| 006 | Home Dashboard | P0 | done | 002, 003, 004 |
| 007 | Transaction History | P0 | done | 003, 004, 006 |
| 008 | Saving and Leftover | P1 | done | 003, 004, 006 |
| 009 | Monthly Report Export | P1 | planned | 003, 004, 007 |
| 010 | Settings Backup Restore | P1 | planned | 003 |
| 011 | QA Accessibility Polish | P0 | planned | all MVP tracks |

---

## Recommended Implementation Order

1. 001 Project Foundation.
2. 002 Design System.
3. 004 Budget Calculation.
4. 003 Local Database.
5. 005 Setup Flow.
6. 006 Home Dashboard.
7. 007 Transaction History.
8. 008 Saving and Leftover.
9. 009 Monthly Report Export.
10. 010 Settings Backup Restore.
11. 011 QA Accessibility Polish.

---

## Updating Track Status

When starting work:
- Change status to `in_progress`.

When implementation is complete:
- Change status to `review`.

When tests and review pass:
- Change status to `done`.

When blocked:
- Change status to `blocked` and document blocker in the relevant `plan.md`.

---

## Track Directories

Each track has:

```text
conductor/tracks/<track-id-name>/
  spec.md
  plan.md
  metadata.json
```

Use the spec for requirements and the plan for step-by-step execution.
