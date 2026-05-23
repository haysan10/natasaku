# DEVELOPMENT_PROMPT.md - Antigravity Start Prompts for NataSaku

## Purpose

File ini berisi prompt siap pakai untuk menjalankan development NataSaku di Antigravity.

Gunakan prompt ini agar Antigravity membaca konteks yang benar dan tidak keluar scope.

---

## 1. Main Start Prompt

Copy prompt ini saat pertama kali membuka project di Antigravity:

```text
Kamu bekerja pada project Android bernama NataSaku.

Sebelum menulis kode, baca file berikut secara berurutan:
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
13. docs/README.md

NataSaku adalah aplikasi Android native offline-first untuk budgeting penghasilan pribadi. Gunakan Kotlin, Jetpack Compose, Material Design 3, Room, DataStore, Coroutines, Flow, dan local-only storage.

Jangan membuat login, backend, cloud sync, integrasi bank, analytics, ads, payment, atau fitur online.

Mulai implementasi dari Track 001 Project Foundation di conductor/tracks/001-project-foundation/. Baca spec.md, plan.md, dan metadata.json track tersebut. Buat rencana singkat, lalu implementasikan sesuai scope. Setelah selesai, laporkan file yang dibuat/diubah, test yang dijalankan, dan risiko/TODO.
```

---

## 2. Build Specific Track Prompt

Gunakan saat ingin mengerjakan track tertentu:

```text
Lanjutkan development NataSaku untuk Track <TRACK_ID>.

Sebelum coding, baca:
1. README.md
2. DO_NOT_BUILD.md
3. conductor/index.md
4. conductor/product.md
5. conductor/product-guidelines.md
6. conductor/tech-stack.md
7. conductor/workflow.md
8. conductor/tracks.md
9. conductor/tracks/<TRACK_ID>/spec.md
10. conductor/tracks/<TRACK_ID>/plan.md
11. conductor/tracks/<TRACK_ID>/metadata.json
12. docs yang relevan untuk track ini.

Ikuti acceptance criteria di spec.md dan checklist di plan.md. Jangan mengerjakan scope di luar track. Jangan menambahkan login, backend, cloud sync, integrasi bank, analytics, ads, atau fitur online.

Setelah selesai, berikan:
- Summary
- Files changed
- Tests
- Risks / TODO
```

Contoh:

```text
Lanjutkan development NataSaku untuk Track 004 Budget Calculation.
```

---

## 3. Review Code Prompt

Gunakan untuk meminta Antigravity review hasil implementasi:

```text
Review implementasi NataSaku saat ini.

Baca:
1. README.md
2. DO_NOT_BUILD.md
3. conductor/workflow.md
4. conductor/tech-stack.md
5. docs/testing-checklist.md
6. docs/release-checklist.md

Fokus review:
- Apakah ada pelanggaran offline-first?
- Apakah ada login/backend/cloud/bank integration?
- Apakah architecture layer sudah benar?
- Apakah business logic berada di domain, bukan Compose?
- Apakah money menggunakan Long?
- Apakah UI copy sesuai tone NataSaku?
- Apakah accessibility basic terpenuhi?
- Apakah test penting sudah ada?

Berikan hasil dalam format:
1. Pass
2. Issues by severity
3. Required fixes
4. Suggested improvements
```

---

## 4. Fix Bug Prompt

Gunakan saat ada bug:

```text
Ada bug pada NataSaku: <DESCRIBE_BUG>.

Sebelum memperbaiki, baca:
1. README.md
2. DO_NOT_BUILD.md
3. conductor/tech-stack.md
4. conductor/workflow.md
5. docs/testing-checklist.md
6. File spec/plan track yang terkait.

Tugas:
1. Reproduksi atau jelaskan kemungkinan penyebab.
2. Identifikasi layer yang bertanggung jawab.
3. Perbaiki dengan perubahan minimal.
4. Tambahkan atau update test jika bug berkaitan dengan logic.
5. Pastikan tidak menambahkan fitur di luar scope.

Laporkan:
- Root cause
- Fix summary
- Files changed
- Tests run
- Regression risk
```

---

## 5. QA Prompt

Gunakan untuk final QA:

```text
Jalankan QA readiness review untuk NataSaku.

Baca:
1. MVP_CHECKLIST.md
2. docs/testing-checklist.md
3. docs/release-checklist.md
4. docs/accessibility-guidelines.md
5. docs/copywriting.md
6. DO_NOT_BUILD.md

Periksa:
- MVP flow
- Calculation correctness
- Local database behavior
- Export PDF/CSV
- Backup/restore
- Offline behavior
- Dark mode
- Accessibility
- Copywriting
- Forbidden features

Berikan:
1. Ready / Not Ready
2. Blockers
3. High priority fixes
4. Medium priority fixes
5. Release notes draft
```

---

## 6. Continue From Previous Session Prompt

Gunakan saat melanjutkan sesi:

```text
Lanjutkan pekerjaan terakhir pada NataSaku.

Pertama baca:
1. README.md
2. conductor/index.md
3. conductor/tracks.md
4. Track yang statusnya in_progress atau review
5. plan.md track tersebut

Identifikasi:
- Apa yang sudah selesai
- Apa yang belum selesai
- Apa blocker
- Apa langkah berikutnya

Jangan memulai track baru sebelum track aktif selesai atau diberi instruksi.
```

---

## 7. Guardrail Reminder Prompt

Gunakan jika Antigravity mulai menyarankan fitur di luar scope:

```text
Ingat guardrail NataSaku:

Jangan buat:
- Login
- Register account
- Backend
- Cloud sync
- Bank integration
- Payment gateway
- Ads
- Analytics SDK
- Online-only feature

NataSaku harus tetap Android native, Kotlin, Jetpack Compose, Material Design 3, Room, DataStore, dan local-only offline-first.

Kembalikan solusi ke scope MVP.
```
