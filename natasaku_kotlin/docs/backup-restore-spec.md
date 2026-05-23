# docs/backup-restore-spec.md - NataSaku Backup and Restore Specification

## Purpose

NataSaku supports local backup and restore so users can keep their data without cloud sync.

Backup and restore must be:
- Local.
- User-triggered.
- Offline.
- Schema-validated.
- Safe from accidental silent data loss.

## Backup File

Filename:

```text
NataSaku_Backup_YYYY_MM_DD.json
```

MIME:

```text
application/json
```

Root schema:

```json
{
  "app": "NataSaku",
  "schemaVersion": 1,
  "exportedAt": "2026-05-07T10:00:00Z",
  "data": {
    "budgetPeriods": [],
    "incomeSources": [],
    "fixedExpenses": [],
    "expenseTransactions": [],
    "savingTargets": [],
    "savingAllocations": [],
    "dailyBudgetSnapshots": [],
    "preferences": {}
  }
}
```

## Backup Must Include

1. Budget periods.
2. Income sources.
3. Fixed expenses.
4. Expense transactions.
5. Saving targets.
6. Saving allocations.
7. Daily budget snapshots.
8. Preferences.

Do not include:
- Device identifiers.
- Debug logs.
- Analytics data.
- Online account data.

## Restore Flow

```text
Settings
-> Restore Data
-> User picks JSON file
-> Parse JSON
-> Validate app name
-> Validate schema version
-> Validate required fields
-> Show confirmation
-> Replace local data
-> Restore preferences
-> Recalculate dashboard
-> Show success
```

## Restore Validation

Required checks:
1. JSON can be parsed.
2. `app == "NataSaku"`.
3. `schemaVersion` is supported.
4. `data` exists.
5. Required arrays exist.
6. Amount fields are not invalid.
7. Dates are parseable.
8. Entity IDs are valid or remapped safely.
9. Active period is valid or reset safely.

## Restore Confirmation

Title:
> Restore data?

Body:
> Restore akan mengganti data NataSaku saat ini dengan isi file backup. Lanjutkan?

Actions:
- Batal.
- Restore.

MVP rule:
- Use replace mode.
- Merge mode can be post-MVP.

## Restore Success

> Data berhasil dipulihkan.

## Restore Failure

> File backup tidak bisa dibaca. Pastikan file berasal dari NataSaku.

## Schema Versioning

Current:

```text
schemaVersion = 1
```

Rules:
- If schema changes, increment version.
- Add migration for restore if older supported version exists.
- Reject unsupported future version safely.

Unsupported version copy:
> Versi file backup belum didukung oleh aplikasi ini.

## Data Replacement Rules

MVP restore mode:
1. Start transaction.
2. Clear existing Room data.
3. Insert backup data.
4. Restore safe preferences.
5. Set active period if valid.
6. Recalculate snapshots.
7. Commit transaction.

If failure:
- Rollback.
- Existing data should remain safe.

## Security and Privacy

1. Backup file is user-controlled.
2. Do not upload backup.
3. Do not automatically share backup.
4. Do not log financial data.
5. Do not include secret keys.
6. Do not add cloud backup.
