# docs/README.md - NataSaku Documentation Hub

## Purpose

Folder `docs/` berisi dokumentasi detail untuk membantu proses pembuatan aplikasi NataSaku di Antigravity.

Dokumen ini melengkapi folder `conductor/`.

- `conductor/` = konteks kerja, workflow, tracks, dan aturan agent.
- `docs/` = detail produk, UI, data, kalkulasi, testing, export, backup, dan release.

## Recommended Reading Order

Untuk agent engineering:

1. `docs/app-flow.md`
2. `docs/data-model.md`
3. `docs/calculation-rules.md`
4. `docs/ui-screen-spec.md`
5. `docs/design-tokens.md`
6. `docs/component-system.md`
7. `docs/testing-checklist.md`

Untuk agent UI/UX:

1. `docs/design-tokens.md`
2. `docs/component-system.md`
3. `docs/ui-screen-spec.md`
4. `docs/copywriting.md`
5. `docs/accessibility-guidelines.md`
6. `docs/microinteractions.md`

Untuk export/backup:

1. `docs/monthly-report-spec.md`
2. `docs/export-spec.md`
3. `docs/backup-restore-spec.md`
4. `docs/data-model.md`

Untuk QA/release:

1. `docs/testing-checklist.md`
2. `docs/accessibility-guidelines.md`
3. `docs/release-checklist.md`

## File List

| File | Purpose |
|---|---|
| `app-flow.md` | User flow, navigation, and back behavior |
| `data-model.md` | Domain and local database model reference |
| `calculation-rules.md` | Budget, allowance, overbudget, leftover formulas |
| `ui-screen-spec.md` | Detailed screen-by-screen UI requirements |
| `design-tokens.md` | Colors, typography, spacing, shapes, dark mode |
| `component-system.md` | Reusable Jetpack Compose component specs |
| `copywriting.md` | Indonesian UX copy and tone guide |
| `accessibility-guidelines.md` | Android accessibility requirements |
| `microinteractions.md` | Motion, animation, and feedback guide |
| `monthly-report-spec.md` | Monthly report metrics and recommendation rules |
| `export-spec.md` | PDF and CSV export requirements |
| `backup-restore-spec.md` | Local backup/restore schema and validation |
| `testing-checklist.md` | Unit, DAO, ViewModel, UI, manual QA checklist |
| `release-checklist.md` | MVP release readiness checklist |

## Non-Negotiables

NataSaku must remain:

- Android native.
- Kotlin.
- Jetpack Compose.
- Material Design 3.
- Offline-first.
- Local data only.
- No login.
- No backend.
- No cloud sync.
- No bank integration.
- No analytics.
- No ads.
