import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/budget_period.dart';
import '../../data/models/transaction_model.dart';

class ReportPdfService {
  Future<File> exportMonthlyReportPdf({
    required List<TransactionModel> transactions,
    BudgetPeriod? activePeriod,
    required double totalIncome,
    required double totalExpense,
    required double averageExpense,
    required double savingBalance,
  }) async {
    final doc = pw.Document();
    final logoBytes =
        await rootBundle.load('assets/branding/logo-natasaku-mark.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    
    // Get base directory - prefer external for user visibility on Android
    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    }
    baseDir ??= await getApplicationDocumentsDirectory();
    
    // Create dedicated NataSaku/Reports folder
    final String folderPath = '${baseDir.path}/NataSaku/Reports';
    final Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final String fileName = 'Laporan_NataSaku_$dateStr\_$timeStr.pdf';
    final file = File('$folderPath/$fileName');

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final expenses = sorted.where((t) => t.isExpense).toList();
    final topItems = sorted.take(15).toList();
    final netBalance = totalIncome - totalExpense;
    final periodText = activePeriod == null
        ? 'Periode aktif belum diatur'
        : '${_fmt(activePeriod.startDate)} - ${_fmt(activePeriod.endDate)}';
        
    final categoryTotals = <String, double>{};
    for (final item in expenses) {
      final key = (item.category?.trim().isNotEmpty ?? false) ? item.category!.trim() : 'Tanpa Kategori';
      categoryTotals[key] = (categoryTotals[key] ?? 0) + item.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Dibuat secara otomatis oleh NataSaku - Halaman ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ),
        build: (context) => [
          // HEADER
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#0F766E'),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 50,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Image(logo),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Ringkasan Keuangan Pribadi',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Periode Laporan: $periodText',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                      ),
                      pw.Text(
                        'Tanggal Cetak: ${_fmt(now)}',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          
          // EXECUTIVE SUMMARY NARRATIVE
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F0FDFA'),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColor.fromHex('#5EEAD4'), width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Catatan Manager Keuangan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColor.fromHex('#0F766E'))),
                pw.SizedBox(height: 6),
                pw.Text(
                  _narrative(totalIncome: totalIncome, totalExpense: totalExpense, topCategories: topCategories),
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // GRID SNAPSHOT
          pw.Text('Ikhtisar Dana', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#111827'))),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _summaryCard('Total Pemasukan', _rupiah(totalIncome), '#ECFDF5', '#065F46'),
              pw.SizedBox(width: 12),
              _summaryCard('Total Pengeluaran', _rupiah(totalExpense), '#FEF2F2', '#991B1B'),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _summaryCard('Arus Kas Bersih', _rupiah(netBalance), '#F8FAFC', '#1E293B'),
              pw.SizedBox(width: 12),
              _summaryCard('Saldo Tabungan', _rupiah(savingBalance), '#F0FDFA', '#0F766E'),
            ],
          ),
          pw.SizedBox(height: 24),

          // CATEGORY BREAKDOWN
          if (topCategories.isNotEmpty) ...[
            pw.Text('Pengeluaran Terbesar (Top 5 Kategori)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#111827'))),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#475569')),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              rowDecoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0')))),
              headers: const ['Kategori', 'Nominal', 'Persentase'],
              data: topCategories.map((c) => [
                c.key,
                _rupiah(c.value),
                '${((c.value / totalExpense) * 100).toStringAsFixed(1)}%'
              ]).toList(),
            ),
            pw.SizedBox(height: 24),
          ],

          // TRANSACTIONS
          pw.Text('Daftar Transaksi Terakhir', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#111827'))),
          pw.SizedBox(height: 8),
          if (topItems.isEmpty)
            pw.Text('Belum ada transaksi untuk dimasukkan ke laporan.', style: const pw.TextStyle(color: PdfColors.grey700))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0F766E')),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 9),
              rowDecoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0')))),
              headers: const ['Tanggal', 'Jenis', 'Kategori', 'Catatan', 'Nominal'],
              data: topItems.map((tx) => [
                _fmt(tx.date),
                tx.isExpense ? 'Keluar' : 'Masuk',
                tx.category ?? '-',
                (tx.note?.trim().isEmpty ?? true) ? '-' : tx.note!.trim(),
                _rupiah(tx.amount),
              ]).toList(),
            ),
            
          pw.SizedBox(height: 32),
          // ACTION PLAN
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Rencana Tindakan Bulan Depan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.SizedBox(height: 8),
                pw.Text(
                  netBalance >= 0 
                      ? '1. Pertahankan rasio pemasukan dan pengeluaran ini.\n2. Alokasikan sebagian sisa dana bulan ini ke tabungan.\n3. Tetap pantau pengeluaran harian menggunakan NataSaku.'
                      : '1. Evaluasi ulang pengeluaran di kategori penyumbang terbesar.\n2. Kurangi pengeluaran opsional selama 1-2 minggu pertama.\n3. Disiplin mencatat setiap pengeluaran kecil agar tidak bocor.',
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await file.writeAsBytes(await doc.save());
    return file;
  }

  pw.Widget _summaryCard(
    String title,
    String value,
    String bgHex,
    String textHex,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex(bgHex),
          borderRadius: pw.BorderRadius.circular(14),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex(textHex),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex(textHex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  static String _rupiah(double value) {
    final safe = value.isFinite ? value : 0;
    final sign = safe < 0 ? '-' : '';
    final absValue = safe.abs().round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < absValue.length; i++) {
      final position = absValue.length - i;
      buffer.write(absValue[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${sign}Rp ${buffer.toString()}';
  }

  static String _narrative({
    required double totalIncome,
    required double totalExpense,
    required List<MapEntry<String, double>> topCategories,
  }) {
    if (totalIncome <= 0 && totalExpense <= 0) {
      return 'Laporan saat ini masih kosong karena belum ada transaksi yang dicatat. Mari mulai rutin mencatat agar pola keuanganmu bisa terbaca di laporan berikutnya.';
    }
    
    final StringBuffer sb = StringBuffer();
    
    if (totalIncome >= totalExpense) {
      sb.write('Kabar baik! Posisi keuangan periode ini terpantau aman dan terkendali. Total pengeluaran masih lebih kecil dibandingkan dengan uang yang masuk. ');
    } else {
      sb.write('Perhatian: Pengeluaran periode ini lebih besar daripada pemasukan (arus kas negatif). Perlu penyesuaian gaya belanja ke depannya agar ritme keuangan tetap sehat. ');
    }
    
    if (topCategories.isNotEmpty) {
      sb.write('Sebagai catatan, porsi terbesar pengeluaranmu terserap pada kategori "${topCategories.first.key}". Pastikan pengeluaran di kategori ini memang sesuai dengan rencanamu.');
    }
    
    return sb.toString();
  }
}
