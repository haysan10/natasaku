# prompts/fix-bug.md

## Target

Antigravity

## Use When

Gunakan prompt ini saat ada bug spesifik yang perlu diperbaiki.

Ganti placeholder:

- `<BUG_DESCRIPTION>`
- `<EXPECTED_BEHAVIOR>`
- `<ACTUAL_BEHAVIOR>`
- `<RELATED_TRACK_OR_FILES>` jika ada

## Prompt

```text
Ada bug pada project Android NataSaku.

Bug description:
<BUG_DESCRIPTION>

Expected behavior:
<EXPECTED_BEHAVIOR>

Actual behavior:
<ACTUAL_BEHAVIOR>

Related track/files if known:
<RELATED_TRACK_OR_FILES>

Sebelum memperbaiki, baca:

1. README.md
2. DO_NOT_BUILD.md
3. PROJECT_STRUCTURE.md
4. conductor/index.md
5. conductor/product.md
6. conductor/product-guidelines.md
7. conductor/tech-stack.md
8. conductor/workflow.md
9. docs/testing-checklist.md
10. GRAPHIC_ASSETS.md

Jika bug terkait calculation, baca:
- docs/calculation-rules.md
- docs/data-model.md

Jika bug terkait UI, baca:
- docs/ui-screen-spec.md
- docs/design-tokens.md
- docs/component-system.md
- docs/copywriting.md
- docs/accessibility-guidelines.md

Jika bug terkait export, baca:
- docs/export-spec.md
- docs/monthly-report-spec.md

Jika bug terkait backup/restore, baca:
- docs/backup-restore-spec.md
- docs/data-model.md

Graphic asset rules:

- Jika bug terkait logo, splash, onboarding illustration, empty state, atau drawable resources, cek `GRAPHIC_ASSETS.md`.
- Pastikan asset tetap ditempatkan di folder yang benar.
- Jangan mengganti Material Icons dengan custom assets tanpa alasan.

Hard constraints:

- Perbaiki bug dengan perubahan minimal.
- Jangan menambahkan fitur baru.
- Jangan membuat login, backend, cloud sync, integrasi bank, analytics, ads, payment, atau fitur online.
- Jangan menambahkan dependency baru tanpa konfirmasi.
- Jangan menghapus data user tanpa konfirmasi.
- Jangan melakukan destructive database migration tanpa konfirmasi.
- Money tetap Long.
- Business logic tetap di domain layer.
- UI copy tetap bahasa Indonesia dan tidak menghakimi.

Process:

1. Jelaskan kemungkinan root cause.
2. Identifikasi layer yang bertanggung jawab: presentation, domain, data, export, backup, atau navigation.
3. Buat fix plan singkat.
4. Terapkan perubahan minimal.
5. Tambahkan atau update test jika bug menyangkut logic, database, export, atau ViewModel.
6. Jalankan test relevan jika environment mendukung.
7. Berikan laporan hasil.

Done when:

- Bug diperbaiki.
- Tidak ada regression obvious.
- Test relevan ditambahkan/diperbarui jika diperlukan.
- Tidak ada forbidden feature ditambahkan.

Output format:

Root Cause:
- ...

Fix Summary:
- ...

Files changed:
- ...

Tests:
- ...

Regression Risk:
- ...

Follow-up TODO:
- ...
```
```
