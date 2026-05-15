# prompts/build-track.md

## Target

Antigravity

## Use When

Gunakan prompt ini saat ingin mengerjakan satu track tertentu dari `conductor/tracks/`.

Ganti placeholder:

- `<TRACK_FOLDER>` dengan folder track, contoh: `004-budget-calculation`
- `<TRACK_NAME>` dengan nama track, contoh: `Budget Calculation`

## Prompt

```text
Kamu bekerja pada project Android native NataSaku.

Tugasmu adalah mengerjakan satu track saja:

Track folder:
<TRACK_FOLDER>

Track name:
<TRACK_NAME>

Sebelum coding, baca file berikut:

1. README.md
2. DO_NOT_BUILD.md
3. PROJECT_STRUCTURE.md
4. IMPLEMENTATION_ORDER.md
5. MVP_CHECKLIST.md
6. .agent/skill.md
7. conductor/index.md
8. conductor/product.md
9. conductor/product-guidelines.md
10. conductor/tech-stack.md
11. conductor/workflow.md
12. conductor/tracks.md
13. conductor/tracks/<TRACK_FOLDER>/spec.md
14. conductor/tracks/<TRACK_FOLDER>/plan.md
15. conductor/tracks/<TRACK_FOLDER>/metadata.json

Baca juga docs yang relevan:

- Untuk UI: docs/ui-screen-spec.md, docs/design-tokens.md, docs/component-system.md, docs/copywriting.md, docs/accessibility-guidelines.md
- Untuk calculation: docs/calculation-rules.md, docs/data-model.md, docs/testing-checklist.md
- Untuk database: docs/data-model.md, docs/backup-restore-spec.md, docs/testing-checklist.md
- Untuk export/report: docs/monthly-report-spec.md, docs/export-spec.md, docs/testing-checklist.md
- Untuk backup/restore: docs/backup-restore-spec.md, docs/data-model.md, docs/testing-checklist.md

Scope rules:

- Kerjakan hanya scope track ini.
- Jangan mengerjakan track lain kecuali dibutuhkan sebagai dependency minimal.
- Jangan menambahkan fitur di luar spec.md.
- Jangan mengubah public contract besar tanpa menjelaskan dampaknya.
- Jangan menambahkan dependency baru tanpa alasan dan tanpa menunggu konfirmasi.
- Jangan melakukan tindakan destruktif tanpa konfirmasi.

Hard constraints:

- NataSaku harus offline-first.
- Semua data user harus lokal.
- Jangan buat login, backend, cloud sync, integrasi bank, analytics, ads, payment, atau fitur online.
- Gunakan Kotlin, Jetpack Compose, Material Design 3, Room, DataStore, Coroutines, Flow/StateFlow.
- Money harus menggunakan Long.
- Business logic finansial harus berada di domain layer, bukan di Composable.
- Room entities tidak boleh langsung dipakai UI.
- UI copy harus bahasa Indonesia dan tidak menghakimi.

Process:

1. Ringkas tujuan track dalam 5 bullet.
2. Buat implementation plan berdasarkan plan.md.
3. Sebutkan file yang akan dibuat/diubah.
4. Implementasikan track.
5. Jalankan test yang relevan jika environment mendukung.
6. Update checklist plan.md jika diminta.
7. Berikan hasil akhir.

Done when:

- Acceptance criteria di spec.md terpenuhi.
- Checklist relevan di plan.md selesai atau TODO jelas.
- Project tetap buildable.
- Tidak ada forbidden feature.
- Output akhir berisi:

Summary:
- ...

Files changed:
- ...

Tests:
- ...

Risks / TODO:
- ...
```
```
