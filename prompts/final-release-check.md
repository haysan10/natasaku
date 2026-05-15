# prompts/final-release-check.md

## Target

Antigravity

## Use When

Gunakan prompt ini sebelum menganggap NataSaku siap MVP release.

## Prompt

```text
Lakukan final release readiness check untuk NataSaku MVP.

Ini adalah review terakhir sebelum aplikasi dianggap siap MVP. Jangan menambahkan fitur baru. Jangan melakukan refactor besar. Fokus hanya pada verifikasi, blocker, dan perbaikan kecil yang benar-benar diperlukan.

Sebelum review, baca:

1. README.md
2. DO_NOT_BUILD.md
3. MVP_CHECKLIST.md
4. IMPLEMENTATION_ORDER.md
5. PROJECT_STRUCTURE.md
6. conductor/index.md
7. conductor/product.md
8. conductor/product-guidelines.md
9. conductor/tech-stack.md
10. conductor/workflow.md
11. conductor/tracks.md
12. docs/README.md
13. docs/release-checklist.md
14. docs/testing-checklist.md
15. docs/accessibility-guidelines.md
16. docs/copywriting.md
17. docs/calculation-rules.md
18. docs/export-spec.md
19. docs/backup-restore-spec.md

Final release criteria:

1. Product:
   - MVP scope complete.
   - No forbidden features.
   - Offline-first preserved.
   - Local data only.

2. Core flows:
   - First-time setup works.
   - Home Dashboard works.
   - Add Expense works.
   - Overbudget warning works.
   - Transaction History works.
   - Budget Screen works.
   - Saving Screen works.
   - Monthly Report works.
   - Export PDF works.
   - Export CSV works.
   - Settings works.
   - Backup works.
   - Restore works.

3. Calculation:
   - Money uses Long.
   - No Float/Double for currency.
   - Daily allowance correct.
   - Status correct.
   - Overbudget adjustment correct.
   - Leftover allocation correct.
   - Monthly report correct.

4. Architecture:
   - Presentation/domain/data boundaries respected.
   - No Room entity exposed to UI.
   - No business logic in Composable.
   - File/database operations not on main thread.

5. UI/UX:
   - Material Design 3.
   - Design tokens used.
   - Light mode works.
   - Dark mode works.
   - Dashboard readable.
   - Add Expense fast.
   - Professional but friendly look.

6. Copy:
   - Indonesian.
   - Friendly.
   - Calm.
   - Non-judgmental.
   - No forbidden wording.

7. Accessibility:
   - 48dp touch target.
   - contentDescription for icon actions.
   - Input labels.
   - Status text labels.
   - Progress text summary.
   - Text scaling acceptable.

8. Testing:
   - Unit tests for calculation.
   - DAO tests where applicable.
   - UI tests for critical flows where applicable.
   - Manual QA checklist complete or gaps documented.

Run tests/build if environment supports it. If not, inspect project files and report clearly that execution was not possible.

Stop and ask before:
- deleting files,
- changing database schema,
- adding dependencies,
- changing architecture,
- removing features,
- adding permissions,
- adding internet permission.

Output format:

Final Release Status:
Ready / Not Ready

Executive Summary:
- ...

Release Blockers:
1. Severity:
   Area:
   Problem:
   Required fix:

MVP Completion:
- Complete:
- Missing:
- Deferred:

Forbidden Feature Audit:
- Login:
- Backend:
- Cloud sync:
- Bank integration:
- Analytics:
- Ads:
- Payment:
- Online-only:

Architecture Audit:
- ...

Calculation Audit:
- ...

UI/UX Audit:
- ...

Accessibility Audit:
- ...

Copywriting Audit:
- ...

Testing Summary:
- Tests run:
- Tests passed:
- Tests failed:
- Tests not run:

Final Recommendation:
- ...
```
```
