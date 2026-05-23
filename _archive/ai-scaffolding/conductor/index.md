# conductor/index.md — NataSaku Project Context

## Purpose

Folder `conductor/` adalah pusat konteks project NataSaku untuk Antigravity dan agent AI. Semua agent harus membaca dokumen ini sebelum mulai mengubah kode.

NataSaku adalah aplikasi Android offline-first untuk budgeting penghasilan pribadi. Aplikasi membantu user mengatur penghasilan menjadi pengeluaran tetap, target tabungan, jatah harian otomatis, pencatatan pengeluaran, warning overbudget, alokasi sisa jatah harian, laporan bulanan, export PDF/CSV, dan backup/restore lokal.

---

## Required Reading Order

Sebelum coding, baca file berikut secara berurutan:

1. `conductor/index.md`
2. `conductor/product.md`
3. `conductor/product-guidelines.md`
4. `conductor/tech-stack.md`
5. `conductor/workflow.md`
6. `conductor/tracks.md`
7. Track aktif:
   - `conductor/tracks/<track-id>/spec.md`
   - `conductor/tracks/<track-id>/plan.md`
   - `conductor/tracks/<track-id>/metadata.json`

Untuk coding Kotlin:
- Baca `conductor/code_styleguides/kotlin.md`

Untuk coding Jetpack Compose:
- Baca `conductor/code_styleguides/jetpack-compose.md`

---

## Source of Truth

| Topic | File |
|---|---|
| Product vision, users, features | `product.md` |
| Brand voice, copywriting, terminology | `product-guidelines.md` |
| Tech stack and architecture constraints | `tech-stack.md` |
| Development workflow and DoD | `workflow.md` |
| Work registry and status | `tracks.md` |
| Kotlin style | `code_styleguides/kotlin.md` |
| Jetpack Compose style | `code_styleguides/jetpack-compose.md` |
| Feature specs and plans | `tracks/*/spec.md`, `tracks/*/plan.md` |

---

## Global Non-Negotiables

NataSaku must remain:

- Android native.
- Kotlin-based.
- Jetpack Compose UI.
- Material Design 3.
- Offline-first.
- Local data only.
- No login.
- No backend.
- No cloud sync.
- No bank integration.
- No analytics SDK.
- No ads.
- No payment gateway.
- No online-only feature.

---

## Recommended Agent Workflow

For every task:

1. Read this `index.md`.
2. Read global context files.
3. Read relevant track spec and plan.
4. Make a short implementation plan.
5. Implement only the assigned scope.
6. Run relevant tests.
7. Update track progress if instructed.
8. Report changed files, tests, risks, and TODO.

---

## Project Completion Goal

The app is considered MVP-ready when these flows work offline:

1. First-time setup flow.
2. Budget calculation.
3. Home dashboard.
4. Add expense.
5. Overbudget warning.
6. Transaction history.
7. Budget detail.
8. Saving and leftover allocation.
9. Monthly report.
10. Export PDF.
11. Export CSV.
12. Settings.
13. Backup.
14. Restore.
15. Light/dark mode.
16. Basic accessibility.
