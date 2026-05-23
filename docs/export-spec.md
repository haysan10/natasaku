# docs/export-spec.md - NataSaku Export Specification

## Purpose

NataSaku supports local export for monthly report and transactions.

Supported exports:
- PDF report.
- CSV transaction data.

All exports are local-only and user-controlled.

## Global Rules

1. No cloud upload.
2. No email sending built-in.
3. No server.
4. No internet.
5. Export must run off main thread.
6. User must explicitly trigger export.
7. Use Android share/open intents for file actions.
8. Use safe file access with FileProvider or suitable Android storage approach.

## CSV Export

Filename:

```text
NataSaku_Transaksi_YYYY_MM.csv
```

Encoding:
- UTF-8.

MIME:
```text
text/csv
```

Columns:

```csv
period_start,period_end,date,category,amount,note,created_at
```

Example:

```csv
period_start,period_end,date,category,amount,note,created_at
2026-05-01,2026-05-31,2026-05-07,Makan,25000,Makan siang,2026-05-07T12:00:00Z
```

Rules:
1. Include only selected period.
2. Exclude soft-deleted transactions.
3. Escape commas, quotes, and newlines.
4. Amount should be numeric, not formatted Rupiah.
5. Dates use ISO format.
6. Note can be empty.
7. Header row required.

## CSV Escaping Rules

If field contains comma, quote, or newline, wrap in quotes and escape quote by doubling it.

Example:

```text
"Makan siang, nasi ayam"
"Catatan dengan ""quote"""
```

## PDF Export

Filename:

```text
NataSaku_Laporan_YYYY_MM.pdf
```

MIME:

```text
application/pdf
```

Content:
1. App name: NataSaku.
2. Title: Laporan Bulanan.
3. Period.
4. Generated date.
5. Total penghasilan.
6. Total pengeluaran.
7. Total tabungan.
8. Sisa akhir bulan.
9. Kategori terbesar.
10. Hari paling boros.
11. Hari paling hemat.
12. Jumlah hari overbudget.
13. Rata-rata pengeluaran harian.
14. Rekomendasi bulan depan.

Design:
- Clean.
- Professional.
- Teal accent.
- Clear hierarchy.
- Minimal decoration.

## Export Success Data

```kotlin
data class ExportedFileUiModel(
    val fileName: String,
    val uri: Uri,
    val mimeType: String,
    val fileSizeBytes: Long,
    val createdAt: Instant
)
```

## Export Success Copy

Title:
> File berhasil dibuat

Body:
> Laporanmu sudah tersimpan di perangkat.

Actions:
- Bagikan File.
- Buka File.

## Error Handling

Export failed:
> File belum berhasil dibuat. Coba lagi atau pilih lokasi penyimpanan lain.

## Threading

Use:
- `Dispatchers.IO`
- suspend use case
- loading state in ViewModel

Do not:
- Write file on main thread.
- Block Compose rendering.
