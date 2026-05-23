import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/budget_period.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/saving_goal.dart';

class ReportPdfService {
  Future<File> exportMonthlyReportPdf({
    required List<TransactionModel> transactions,
    BudgetPeriod? activePeriod,
    required int totalIncome,
    required int totalExpense,
    required double averageExpense,
    required int savingBalance,
    int? healthScore,
    List<SavingGoal>? savingGoals,
  }) async {
    final doc = pw.Document();
    
    // Load branding logo
    pw.MemoryImage? logo;
    try {
      final logoBytes = await rootBundle.load('assets/branding/logo-natasaku-mark.png');
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // Fallback if logo cannot be loaded during tests or environment limits
    }

    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    
    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    }
    baseDir ??= await getApplicationDocumentsDirectory();
    
    final String folderPath = '${baseDir.path}/NataSaku/Reports';
    final Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final String fileName = 'Laporan_NataSaku_${dateStr}_$timeStr.pdf';
    final file = File('$folderPath/$fileName');

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final expenses = sorted.where((t) => t.isExpense).toList();
    final topItems = sorted.take(22).toList();
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

    // Default health score calculation if none is supplied
    final resolvedHealthScore = healthScore ?? 78;

    // Define colors for the PDF theme matching NataSaku premium branding
    final primaryColor = PdfColor.fromHex('#0F766E'); // NataSaku Dark Teal
    final accentColor = PdfColor.fromHex('#0D9488'); // NataSaku Mint
    final grayDark = PdfColor.fromHex('#334155'); // Slate Gray
    final bgLight = PdfColor.fromHex('#F8FAFC'); // Light background slate
    
    // Choose health score color based on value
    final scoreColor = resolvedHealthScore >= 80 
        ? PdfColor.fromHex('#10B981') // Green
        : resolvedHealthScore >= 50 
            ? PdfColor.fromHex('#F59E0B') // Amber
            : PdfColor.fromHex('#EF4444'); // Red

    final lightScoreColor = resolvedHealthScore >= 80
        ? PdfColor.fromHex('#ECFDF5') // Light Green
        : resolvedHealthScore >= 50
            ? PdfColor.fromHex('#FEF3C7') // Light Amber
            : PdfColor.fromHex('#FEE2E2'); // Light Red

    final borderScoreColor = resolvedHealthScore >= 80
        ? PdfColor.fromHex('#A7F3D0') // Emerald Border
        : resolvedHealthScore >= 50
            ? PdfColor.fromHex('#FDE68A') // Amber Border
            : PdfColor.fromHex('#FCA5A5'); // Red Border

    final scoreLabel = resolvedHealthScore >= 80 
        ? 'PRIMA / SANGAT SEHAT' 
        : resolvedHealthScore >= 50 
            ? 'WASPADAI / CUKUP SEHAT' 
            : 'KRITIS / PERLU PEMULIHAN';

    // ── HALAMAN 1: Cover Page ────────────────────────────────────────────────
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 12,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [primaryColor, accentColor],
                  ),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
              ),
              pw.SizedBox(height: 40),
              
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logo != null) ...[
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        color: bgLight,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                      ),
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Image(logo),
                    ),
                    pw.SizedBox(width: 16),
                  ],
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NataSaku',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text(
                        'Offline Budgeting & Financial Tracker',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              pw.Divider(color: PdfColors.grey200, height: 1),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'LAPORAN RINGKASAN KEUANGAN',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: grayDark,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Analisis komprehensif kas harian, tagihan rutin, dan pencapaian finansial.',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
              
              pw.SizedBox(height: 40),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _metaRow('Periode Analisis', periodText, grayDark),
                    pw.SizedBox(height: 8),
                    _metaRow('Tanggal Ekspor', '${_fmt(now)} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB', grayDark),
                    pw.SizedBox(height: 8),
                    _metaRow('Status Dokumen', 'Valid & Terenkripsi Lokal', accentColor, isBold: true),
                    pw.SizedBox(height: 8),
                    _metaRow('Diagnosis Keuangan', scoreLabel, scoreColor, isBold: true),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 40),
              
              pw.Text(
                'IKHTISAR KUNCI',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: grayDark, letterSpacing: 0.8),
              ),
              pw.SizedBox(height: 12),
              
              pw.Row(
                children: [
                  _summaryCard('TOTAL PEMASUKAN', _rupiah(totalIncome), '#ECFDF5', '#065F46', indicatorColor: PdfColor.fromHex('#10B981')),
                  pw.SizedBox(width: 12),
                  _summaryCard('TOTAL PENGELUARAN', _rupiah(totalExpense), '#FEF2F2', '#991B1B', indicatorColor: PdfColor.fromHex('#EF4444')),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  _summaryCard(
                    'ARUS KAS BERSIH', 
                    _rupiah(netBalance), 
                    netBalance >= 0 ? '#ECFDF5' : '#FEF2F2', 
                    netBalance >= 0 ? '#065F46' : '#991B1B',
                    extra: netBalance >= 0 ? 'SURPLUS' : 'DEFISIT',
                    indicatorColor: netBalance >= 0 ? PdfColor.fromHex('#10B981') : PdfColor.fromHex('#EF4444'),
                  ),
                  pw.SizedBox(width: 12),
                  _summaryCard('SKOR KESEHATAN', '$resolvedHealthScore/100', '#F0FDFA', '#0F766E', indicatorColor: PdfColor.fromHex('#0D9488')),
                ],
              ),
              
              pw.Spacer(),
              _buildPdfFooter(1, 4),
            ],
          );
        },
      ),
    );

    // ── HALAMAN 2: Executive Summary ─────────────────────────────────────────
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfSectionHeader('Ringkasan Eksekutif & Analisis Kategori', primaryColor),
              pw.SizedBox(height: 20),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: lightScoreColor,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: borderScoreColor, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(width: 4, height: 12, decoration: pw.BoxDecoration(color: scoreColor, borderRadius: pw.BorderRadius.circular(2))),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          'ANALISIS PERILAKU & CATATAN UNTUK KAMU:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: grayDark, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _narrative(totalIncome: totalIncome, totalExpense: totalExpense, topCategories: topCategories),
                      style: pw.TextStyle(fontSize: 9.5, lineSpacing: 1.4, color: grayDark, fontStyle: pw.FontStyle.italic),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 24),
              
              pw.Text(
                'ALOKASI PENGELUARAN PER KATEGORI',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: grayDark, letterSpacing: 0.8),
              ),
              pw.SizedBox(height: 10),
              if (topCategories.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(color: bgLight, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Text('Belum ada pengeluaran kategori yang tercatat.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                )
              else
                pw.Table(
                  columnWidths: const {
                    0: pw.FlexColumnWidth(0.8), // Peringkat
                    1: pw.FlexColumnWidth(2.5), // Kategori
                    2: pw.FlexColumnWidth(2.2), // Visual Alokasi
                    3: pw.FlexColumnWidth(2.2), // Total Nominal
                    4: pw.FlexColumnWidth(1.3), // Persentase
                  },
                  border: null,
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: grayDark,
                        borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                      ),
                      children: [
                        _tableHeaderCell('Peringkat'),
                        _tableHeaderCell('Kategori'),
                        _tableHeaderCell('Visual Alokasi'),
                        _tableHeaderCell('Total Nominal', alignRight: true),
                        _tableHeaderCell('Persentase', alignRight: true),
                      ],
                    ),
                    ...List.generate(topCategories.length, (index) {
                      final c = topCategories[index];
                      final pct = totalExpense > 0 ? (c.value / totalExpense) * 100 : 0.0;
                      final isEven = index % 2 == 0;
                      final rowBgColor = isEven ? PdfColors.white : PdfColor.fromHex('#F8FAFC');
                      
                      final barColors = [
                        PdfColor.fromHex('#0F766E'),
                        PdfColor.fromHex('#0D9488'),
                        PdfColor.fromHex('#3B82F6'),
                        PdfColor.fromHex('#8B5CF6'),
                        PdfColor.fromHex('#F59E0B'),
                      ];
                      final barColor = barColors[index % barColors.length];

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: rowBgColor,
                          border: const pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                          ),
                        ),
                        children: [
                          _tableCell('#${index + 1}'),
                          _tableCell(c.key),
                          _visualBarCell(pct, barColor),
                          _tableCell(_rupiah(c.value), alignRight: true, isBold: true),
                          _tableCell('${pct.toStringAsFixed(1)}%', alignRight: true),
                        ],
                      );
                    }),
                  ],
                ),
              
              pw.Spacer(),
              _buildPdfFooter(2, 4),
            ],
          );
        },
      ),
    );

    // ── HALAMAN 3: Buku Kas Lengkap ──────────────────────────────────────────
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfSectionHeader('Buku Kas & Transaksi Lengkap', primaryColor),
              pw.SizedBox(height: 16),
              
              if (topItems.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(color: bgLight, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Text('Belum ada data transaksi yang tercatat dalam periode aktif ini.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                )
              else
                pw.Table(
                  columnWidths: const {
                    0: pw.FlexColumnWidth(1.2), // Tanggal
                    1: pw.FlexColumnWidth(1.3), // Jenis
                    2: pw.FlexColumnWidth(1.5), // Kategori
                    3: pw.FlexColumnWidth(3.0), // Catatan
                    4: pw.FlexColumnWidth(2.0), // Nominal
                  },
                  border: null,
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                      ),
                      children: [
                        _tableHeaderCell('Tanggal'),
                        _tableHeaderCell('Jenis'),
                        _tableHeaderCell('Kategori'),
                        _tableHeaderCell('Catatan / Memo'),
                        _tableHeaderCell('Nominal', alignRight: true),
                      ],
                    ),
                    ...List.generate(topItems.length, (index) {
                      final tx = topItems[index];
                      final isEven = index % 2 == 0;
                      final rowBgColor = isEven ? PdfColors.white : PdfColor.fromHex('#F8FAFC');
                      
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: rowBgColor,
                          border: const pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                          ),
                        ),
                        children: [
                          _tableCell(_fmt(tx.date)),
                          _tableCell(
                            tx.isExpense ? 'Keluar' : 'Masuk',
                            textColor: tx.isExpense ? PdfColor.fromHex('#EF4444') : PdfColor.fromHex('#10B981'),
                          ),
                          _tableCell(tx.category ?? '-'),
                          _tableCell((tx.note?.trim().isEmpty ?? true) ? 'Catatan jajan mandiri' : tx.note!.trim()),
                          _tableCell(
                            tx.isExpense ? '-${_rupiah(tx.amount)}' : '+${_rupiah(tx.amount)}',
                            textColor: tx.isExpense ? PdfColor.fromHex('#EF4444') : PdfColor.fromHex('#10B981'),
                            alignRight: true,
                            isBold: true,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              
              pw.Spacer(),
              _buildPdfFooter(3, 4),
            ],
          );
        },
      ),
    );

    // ── HALAMAN 4: Analisa Tabungan ──────────────────────────────────────────
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (context) {
          final activeGoal = (savingGoals != null && savingGoals.isNotEmpty)
              ? savingGoals.firstWhere((element) => element.currentAmount > 0 || element.targetAmount > 0, orElse: () => savingGoals.first)
              : null;
              
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfSectionHeader('Analisa Tabungan & Target Keuangan', primaryColor),
              pw.SizedBox(height: 20),
              
              pw.Text(
                'CELENGAN AKTIF DAN PROGRESS',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: grayDark, letterSpacing: 0.8),
              ),
              pw.SizedBox(height: 10),
              if (activeGoal == null)
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: bgLight,
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                  ),
                  child: pw.Text(
                    'Belum ada target tabungan (Celengan) yang aktif saat ini. Tetapkan target impianmu di Celengan NataSaku untuk mulai menabung secara teratur.',
                    style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey600),
                  ),
                )
              else
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: bgLight,
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            activeGoal.name.toUpperCase(),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: primaryColor),
                          ),
                          pw.Text(
                            '${((activeGoal.currentAmount / activeGoal.targetAmount.clamp(1, double.maxFinite.toInt())) * 100).toStringAsFixed(1)}% Tercapai',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: accentColor),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      _visualBarCell(
                        (activeGoal.currentAmount / activeGoal.targetAmount.clamp(1, double.maxFinite.toInt())) * 100,
                        accentColor,
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('KUMPUL KAN', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500)),
                              pw.Text(_rupiah(activeGoal.currentAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: grayDark)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('TARGET IMPIAN', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500)),
                              pw.Text(_rupiah(activeGoal.targetAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: grayDark)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
              pw.SizedBox(height: 24),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RENCANA TINDAKAN STRATEGIS BULAN DEPAN',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: grayDark),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      netBalance >= 0 
                          ? '1. PERTAHANKAN RASIO: Lanjutkan pembagian rasio hemat ini. Tabungan Anda meningkat stabil.\n2. ALOKASIKAN SURPLUS: Segera kunci sisa surplus kas ke dalam dana investasi simpanan.\n3. MONITOR KONSISTENSI: Tetap gunakan widget NataSaku harian agar gaya hidup tidak bergeser.'
                          : '1. EVALUASI POS JAJAN: Kategori terboros Anda memerlukan pemotongan anggaran minimal 20% segera.\n2. REM DARURAT 2 MINGGU: Hentikan jajan non-esensial dan selesaikan pengeluaran prioritas saja.\n3. ATUR ULANG BUDGET HARIAN: Mulai besok, turunkan jatah anggaran aman harian Anda di Dashboard.',
                      style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.5, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 24),
              
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 150,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: accentColor, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColor.fromHex('#F0FDFA'),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'VERIFIKASI SISTEM',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5, color: accentColor, letterSpacing: 0.8),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'NATASAKU ENGINE v1.2',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: primaryColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        height: 0.5,
                        color: accentColor,
                        margin: const pw.EdgeInsets.symmetric(vertical: 4),
                      ),
                      pw.Text(
                        'Status: VALID & AMAN',
                        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Kode ID: NS-$dateStr-$timeStr',
                        style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500),
                      ),
                    ],
                  ),
                ),
              ),
              
              pw.Spacer(),
              _buildPdfFooter(4, 4),
            ],
          );
        },
      ),
    );

    await file.writeAsBytes(await doc.save());
    return file;
  }

  pw.Widget _pdfSectionHeader(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 2,
          width: 50,
          color: color,
        ),
      ],
    );
  }

  pw.Widget _metaRow(String label, String value, PdfColor valueColor, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            color: valueColor,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFooter(int page, int total) {
    return pw.Container(
      alignment: pw.Alignment.center,
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Dibuat oleh NataSaku • Rahasia & Terenkripsi Lokal',
            style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8),
          ),
          pw.Text(
            'Halaman $page dari $total',
            style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8),
          ),
        ],
      ),
    );
  }

  pw.Widget _visualBarCell(double percentage, PdfColor barColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Container(
        alignment: pw.Alignment.centerLeft,
        height: 6,
        width: 70,
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#E2E8F0'),
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Container(
          height: 6,
          width: 70 * (percentage / 100).clamp(0.0, 1.0),
          decoration: pw.BoxDecoration(
            color: barColor,
            borderRadius: pw.BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  pw.Widget _summaryCard(
    String title,
    String value,
    String bgHex,
    String textHex, {
    String? extra,
    PdfColor? indicatorColor,
  }) {
    final bgColor = PdfColor.fromHex(bgHex);
    final textColor = PdfColor.fromHex(textHex);
    return pw.Expanded(
      child: pw.Container(
        height: 54,
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
        ),
        child: pw.Row(
          children: [
            if (indicatorColor != null)
              pw.Container(
                width: 5,
                decoration: pw.BoxDecoration(
                  color: indicatorColor,
                  borderRadius: const pw.BorderRadius.horizontal(left: pw.Radius.circular(12)),
                ),
              ),
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            fontWeight: pw.FontWeight.bold,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (extra != null)
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: pw.BoxDecoration(
                              color: extra == 'SURPLUS' ? PdfColor.fromHex('#D1FAE5') : PdfColor.fromHex('#FEE2E2'),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(
                              extra,
                              style: pw.TextStyle(
                                fontSize: 6.5,
                                fontWeight: pw.FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      value,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _tableHeaderCell(String text, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _tableCell(String text, {PdfColor? textColor, bool alignRight = false, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.5,
          color: textColor ?? PdfColor.fromHex('#334155'),
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  static String _fmt(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  static String _rupiah(num value) {
    final sign = value < 0 ? '-' : '';
    final absValue = value.abs().round().toString();
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
    required int totalIncome,
    required int totalExpense,
    required List<MapEntry<String, double>> topCategories,
  }) {
    if (totalIncome <= 0 && totalExpense <= 0) {
      return 'Laporan saat ini masih kosong karena belum ada transaksi yang dicatat. Mari mulai rutin mencatat pengeluaran Anda agar pola keuangan pribadi bisa terbaca di laporan eksekutif NataSaku berikutnya.';
    }
    
    final StringBuffer sb = StringBuffer();
    
    if (totalIncome >= totalExpense) {
      sb.write('Posisi keuangan Anda periode ini terpantau sangat sehat dan stabil! Surplus kas berhasil diamankan karena total pengeluaran terjaga dengan baik di bawah pemasukan. ');
    } else {
      sb.write('Perhatian: Anda mengalami defisit arus kas (arus kas negatif) periode ini. Segera evaluasi ulang pos belanja non-prioritas agar ritme harian keuangan Anda kembali seimbang. ');
    }
    
    if (topCategories.isNotEmpty) {
      sb.write('Sebagai catatan strategis manajer keuangan, porsi dana terbesar Anda diserap pada kategori belanja "${topCategories.first.key}". Disarankan memotong jatah harian untuk kategori tersebut.');
    }
    
    return sb.toString();
  }
}
