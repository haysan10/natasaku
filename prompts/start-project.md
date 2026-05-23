# prompts/start-project.md

## Target

Antigravity

## Use When

Gunakan prompt ini saat pertama kali membuka project NataSaku di Antigravity.

## Prompt

```text
Kamu bekerja pada project Android native bernama NataSaku.

NataSaku adalah aplikasi budgeting penghasilan pribadi berbasis Android offline-first. Aplikasi membantu user mengatur penghasilan menjadi pengeluaran tetap, target tabungan, jatah harian otomatis, pencatatan pengeluaran, warning overbudget, alokasi sisa jatah harian, laporan bulanan, export PDF/CSV, dan backup/restore lokal.

Sebelum menulis atau mengubah kode apa pun, baca file berikut secara berurutan:

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
14. GRAPHIC_ASSETS.md

Setelah membaca, lakukan hal berikut:

1. Ringkas pemahamanmu tentang project dalam maksimal 10 bullet.
2. Identifikasi track pertama yang harus dikerjakan berdasarkan IMPLEMENTATION_ORDER.md dan conductor/tracks.md.
3. Baca spec.md, plan.md, dan metadata.json untuk track tersebut.
4. Buat implementation plan singkat sebelum coding.
5. Tunggu konfirmasi jika kamu perlu melakukan tindakan destruktif seperti menghapus file, mengganti struktur besar, mengubah schema database, atau menambahkan dependency baru.

Graphic asset rules:

- Baca `GRAPHIC_ASSETS.md` sebelum mengimplementasikan UI yang menggunakan logo, splash asset, illustration, atau empty state.
- Gunakan asset source dari `design-assets/graphics/` sebagai source-of-truth desain.
- Untuk icon fungsi umum, gunakan Material Icons / Material Symbols, bukan custom graphic file.
- Jika asset final belum tersedia, boleh gunakan placeholder ringan dengan TODO yang jelas.

Hard constraints:

- Gunakan Kotlin.
- Gunakan Jetpack Compose.
- Gunakan Material Design 3.
- Gunakan Room untuk data utama.
- Gunakan DataStore untuk preferences.
- Gunakan Coroutines dan Flow/StateFlow.
- Semua data harus lokal.
- Aplikasi harus berjalan offline.
- Jangan membuat login.
- Jangan membuat backend.
- Jangan membuat cloud sync.
- Jangan membuat integrasi bank.
- Jangan membuat payment gateway.
- Jangan menambahkan ads.
- Jangan menambahkan analytics SDK.
- Jangan menambahkan fitur online.
- Jangan menggunakan Double atau Float untuk uang; gunakan Long.
- Jangan menaruh business logic finansial di Composable.
- Jangan query Room langsung dari Composable.

Mulai dari Track 001 Project Foundation. Kerjakan hanya scope Track 001 terlebih dahulu.

Done when:

- Kamu sudah membaca context files.
- Kamu sudah menyampaikan ringkasan project.
- Kamu sudah membuat plan Track 001.
- Jika diberi izin lanjut, project foundation dibuat sesuai spec.
- Output akhir memuat Summary, Files changed, Tests, dan Risks/TODO.
```
```
