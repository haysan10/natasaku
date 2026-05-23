# prompts/run-qa.md

## Target

Antigravity

## Use When

Gunakan prompt ini untuk menjalankan QA menyeluruh atau QA setelah beberapa track selesai.

## Prompt

```text
Jalankan QA readiness review untuk project Android NataSaku.

Sebelum QA, baca:

1. README.md
2. DO_NOT_BUILD.md
3. MVP_CHECKLIST.md
4. PROJECT_STRUCTURE.md
5. conductor/index.md
6. conductor/product.md
7. conductor/product-guidelines.md
8. conductor/tech-stack.md
9. conductor/workflow.md
10. conductor/tracks.md
11. docs/README.md
12. docs/testing-checklist.md
13. docs/release-checklist.md
14. docs/accessibility-guidelines.md
15. docs/copywriting.md
16. docs/calculation-rules.md
17. docs/data-model.md
18. docs/export-spec.md
19. docs/backup-restore-spec.md
20. GRAPHIC_ASSETS.md

QA scope:

1. MVP completeness:
   - Splash.
   - Welcome.
   - Onboarding.
   - Setup Period.
   - Setup Income.
   - Setup Fixed Expense.
   - Setup Saving Target.
   - Review Budget.
   - Home Dashboard.
   - Add Expense.
   - Overbudget Warning.
   - Transaction History.
   - Budget Screen.
   - Saving Screen.
   - Monthly Report.
   - Export Success.
   - Settings.
   - Backup.
   - Restore.

2. Calculation:
   - Flexible fund.
   - Daily allowance.
   - Daily status.
   - Overbudget adjustment.
   - Leftover allocation.
   - Monthly report metrics.

3. Data:
   - Room persistence.
   - DataStore preferences.
   - Soft delete if implemented.
   - Backup JSON.
   - Restore validation.

4. Export:
   - CSV.
   - PDF.
   - File share.
   - File open.
   - Error handling.

5. UI/UX:
   - Material Design 3.
   - Light/dark mode.
   - Design tokens.
   - Dashboard readability.
   - Add Expense speed.

6. Accessibility:
   - Touch targets.
   - contentDescription.
   - Labels.
   - Status text.
   - Progress text summary.
   - Text scaling.

7. Graphic assets:
   - Asset branding tersedia.
   - Illustration penting tersedia atau TODO jelas.
   - Icon fungsi umum memakai Material Icons / Material Symbols.
   - Folder penyimpanan asset sesuai `GRAPHIC_ASSETS.md`.

8. Copywriting:
   - Indonesian.
   - Friendly.
   - Non-judgmental.
   - No forbidden copy.

9. Forbidden features:
   - No login.
   - No backend.
   - No cloud sync.
   - No bank integration.
   - No analytics.
   - No ads.
   - No online-only feature.

Run relevant tests if the environment supports it. If tests cannot be run, inspect test files and report that runtime verification was not possible.

Do not implement fixes unless explicitly asked. This is QA/reporting only.

Output format:

QA Status:
Ready / Not Ready

Summary:
- ...

Passed Areas:
- ...

Blockers:
1. Severity:
   Area:
   Problem:
   Required fix:

High Priority Issues:
- ...

Medium Priority Issues:
- ...

Testing Performed:
- ...

Testing Not Performed:
- ...

Forbidden Feature Check:
- Login:
- Backend:
- Cloud sync:
- Bank integration:
- Analytics:
- Ads:
- Online-only:

MVP Checklist Result:
- Completed:
- Missing:

Recommendation:
- ...
```
```
