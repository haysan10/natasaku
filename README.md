# NataSaku

**NataSaku** adalah aplikasi Android offline-first untuk membantu pengguna mengatur penghasilan pribadi menjadi pengeluaran tetap, target tabungan, jatah harian otomatis, pencatatan pengeluaran, warning overbudget, alokasi sisa harian, laporan bulanan, export PDF/CSV, serta backup dan restore lokal.

Tagline:

> Atur uang bulanan, nikmati hidup harian.

---

## 1. Tujuan Project

Project ini bertujuan membangun aplikasi budgeting Android native yang:

- mudah digunakan,
- ramah untuk pekerja gajian, mahasiswa, freelancer, dan pengguna umum,
- bekerja sepenuhnya offline,
- menyimpan data secara lokal,
- tidak membutuhkan login,
- tidak menggunakan backend,
- tidak memakai cloud sync,
- tidak terhubung ke bank,
- mengikuti Material Design 3,
- dibangun dengan Kotlin dan Jetpack Compose.

---

## 2. Core Product Idea

NataSaku membantu user menjawab pertanyaan sederhana:

> Hari ini aku aman belanja berapa?

Rumus utama:

```text
Dana Fleksibel = Total Penghasilan - Pengeluaran Tetap - Target Tabungan

Jatah Harian = Dana Fleksibel / Jumlah Hari Periode
```

Jika user melewati jatah harian, aplikasi memberi warning yang ramah dan menjelaskan bahwa jatah berikutnya dapat disesuaikan.

Jika user masih punya sisa jatah harian, aplikasi menawarkan alokasi:

1. Tambah ke jatah besok.
2. Masukkan ke tabungan.
3. Bagi otomatis.
4. Simpan sebagai saldo bebas.

---

## 3. Tech Stack

Wajib:

- Kotlin.
- Android Native.
- Jetpack Compose.
- Material Design 3.
- Navigation Compose.
- Room Database.
- DataStore Preferences.
- Kotlin Coroutines.
- Flow / StateFlow.
- ViewModel.
- Local PDF export.
- Local CSV export.
- Local JSON backup/restore.

Tidak boleh:

- Backend.
- Login.
- Cloud sync.
- Bank integration.
- Payment gateway.
- Ads.
- Analytics SDK.
- Online-only features.

---

## 4. Project Context Files

Project ini menggunakan context-driven development.

Struktur context:

```text
.agent/
  skill.md
  agents/

conductor/
  index.md
  product.md
  product-guidelines.md
  tech-stack.md
  workflow.md
  tracks.md
  code_styleguides/
  tracks/

docs/
  README.md
  app-flow.md
  data-model.md
  calculation-rules.md
  design-tokens.md
  component-system.md
  ui-screen-spec.md
  copywriting.md
  accessibility-guidelines.md
  microinteractions.md
  monthly-report-spec.md
  export-spec.md
  backup-restore-spec.md
  testing-checklist.md
  release-checklist.md
```

---

## 5. Required Reading Order for Antigravity

Sebelum mulai coding, agent harus membaca:

1. `.agent/skill.md`
2. `conductor/index.md`
3. `conductor/product.md`
4. `conductor/product-guidelines.md`
5. `conductor/tech-stack.md`
6. `conductor/workflow.md`
7. `conductor/tracks.md`
8. `docs/README.md`
9. File track aktif di `conductor/tracks/<track-id>/`

Untuk coding Kotlin:

- `conductor/code_styleguides/kotlin.md`

Untuk coding Jetpack Compose:

- `conductor/code_styleguides/jetpack-compose.md`

---

## 6. Recommended Development Order

Ikuti urutan ini:

1. Project Foundation.
2. Design System.
3. Budget Calculation.
4. Local Database.
5. Setup Flow.
6. Home Dashboard.
7. Transaction History.
8. Saving and Leftover.
9. Monthly Report Export.
10. Settings Backup Restore.
11. QA Accessibility Polish.

Detail lengkap ada di:

- `IMPLEMENTATION_ORDER.md`
- `conductor/tracks.md`

---

## 7. Main Features

MVP harus mencakup:

1. Splash Screen.
2. Welcome Screen.
3. Onboarding.
4. Setup Periode Gajian.
5. Setup Penghasilan.
6. Setup Pengeluaran Tetap.
7. Setup Target Tabungan.
8. Review Budget.
9. Home Dashboard.
10. Add Expense Bottom Sheet.
11. Warning Overbudget Dialog.
12. Leftover Allocation Dialog.
13. Transaction History.
14. Budget Screen.
15. Saving Screen.
16. Monthly Report Screen.
17. Export Success Screen.
18. Settings Screen.
19. Export PDF.
20. Export CSV.
21. Backup lokal.
22. Restore lokal.

---

## 8. Brand and UX Tone

NataSaku harus terasa:

- helpful,
- calm,
- friendly,
- professional,
- tidak menghakimi,
- seperti manager keuangan pribadi yang ramah.

Gunakan copy seperti:

- “Jatah kamu hari ini”
- “Aman. Pengeluaranmu masih terkendali.”
- “Jatah hari ini terlewati.”
- “Budget akan disesuaikan.”
- “Kamu masih punya sisa.”

Jangan gunakan:

- “Kamu boros”
- “Budget gagal”
- “Kamu salah”
- “Tidak disiplin”
- “Pengeluaranmu buruk”

---

## 9. Definition of Done

Sebuah fitur dianggap selesai jika:

1. Requirement terpenuhi.
2. Berjalan offline.
3. Data tersimpan lokal.
4. Tidak menambahkan fitur terlarang.
5. Business logic tidak berada di Composable.
6. Money menggunakan `Long`, bukan `Double` atau `Float`.
7. Unit test tersedia untuk logic penting.
8. UI mengikuti Material Design 3.
9. Light/dark mode tidak rusak.
10. Accessibility dasar terpenuhi.
11. Copywriting sesuai tone NataSaku.

---

## 10. Start Command for Antigravity

Gunakan instruksi awal ini:

```text
Baca README.md, .agent/skill.md, conductor/index.md, conductor/product.md, conductor/tech-stack.md, conductor/workflow.md, conductor/tracks.md, dan docs/README.md.

Bangun aplikasi Android NataSaku secara bertahap mengikuti IMPLEMENTATION_ORDER.md. Mulai dari Track 001 Project Foundation. Jangan membuat login, backend, cloud sync, integrasi bank, analytics, ads, atau fitur online. Gunakan Kotlin, Jetpack Compose, Material Design 3, Room, DataStore, dan local-only storage.
```
