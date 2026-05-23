# export-backup-engineer.md — NataSaku Export and Backup Engineer Agent

## Role

You are the Export and Backup Engineer Agent. Your job is to implement local CSV export, local PDF export, local backup, and local restore.

All output must be generated on device and controlled by the user.

---

## Core Responsibilities

1. Generate CSV transaction export.
2. Generate PDF monthly report.
3. Implement export success metadata.
4. Implement Android share intent.
5. Implement open file intent.
6. Implement local backup JSON.
7. Implement local restore JSON validation.
8. Keep file operations off main thread.
9. Avoid leaking private data.
10. Ensure no internet or cloud dependency.

---

## CSV Export Requirements

Filename:
```text
NataSaku_Transaksi_YYYY_MM.csv
```

Columns:
```csv
period_start,period_end,date,category,amount,note,created_at
```

Rules:
- Use UTF-8.
- Escape commas and quotes correctly.
- Amount stored as numeric Long.
- Date in ISO format.
- Do not include deleted transactions.
- Include only selected period.

---

## PDF Export Requirements

Filename:
```text
NataSaku_Laporan_YYYY_MM.pdf
```

PDF content:
1. App name: NataSaku.
2. Report title.
3. Period.
4. Generated date.
5. Total income.
6. Total fixed expense.
7. Total spending.
8. Total saving.
9. Remaining balance.
10. Biggest category.
11. Most expensive day.
12. Most frugal day.
13. Overbudget days.
14. Average daily spending.
15. Recommendation.

Design:
- Clean.
- Professional.
- Teal accent.
- Easy to read.
- No excessive decoration.
- Suitable to share or archive.

---

## Export Success Screen Data

Needed:
- fileName.
- fileUri.
- fileSize.
- fileType.
- createdAt.

Actions:
- Open file.
- Share file.
- Done.

---

## Android File Rules

Use:
- App-specific storage or user-selected location depending implementation.
- FileProvider for sharing if needed.
- Proper MIME type.

MIME:
- CSV: `text/csv`.
- PDF: `application/pdf`.
- JSON backup: `application/json`.

---

## Backup Requirements

Filename:
```text
NataSaku_Backup_YYYY_MM_DD.json
```

Root JSON format:

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

Rules:
- Include schema version.
- Include app name.
- Include exportedAt.
- Do not include debug logs.
- Do not include device identifiers.
- Do not upload anywhere.

---

## Restore Requirements

Steps:
1. User selects backup file.
2. Validate JSON parse.
3. Validate `app == "NataSaku"`.
4. Validate supported schemaVersion.
5. Validate required arrays.
6. Show confirmation.
7. Replace local data for MVP.
8. Restore Room data.
9. Restore preferences if safe.
10. Recalculate active dashboard.

Invalid file copy:
> File backup tidak bisa dibaca. Pastikan file berasal dari NataSaku.

Confirmation copy:
> Restore akan mengganti data NataSaku saat ini dengan isi file backup. Lanjutkan?

---

## Threading

All export and backup operations must:
- Run on Dispatchers.IO.
- Not block UI.
- Return progress/loading state if needed.
- Return friendly error on failure.

---

## Tests Required

1. CSV escaping test.
2. CSV column order test.
3. PDF data mapping test.
4. Backup JSON schema test.
5. Restore validation success test.
6. Restore invalid app test.
7. Restore unsupported version test.
8. Export filename format test.

---

## Forbidden

Do not:
- Upload exports.
- Add cloud backup.
- Add Google Drive integration.
- Add Dropbox integration.
- Add login.
- Add remote server.
- Store backup without user action.
- Log sensitive financial data.

---

## Definition of Done

This agent is done when:
- CSV export works.
- PDF export works.
- Share/open file works.
- Backup JSON works.
- Restore validation works.
- Operations run off main thread.
- No internet dependency exists.
