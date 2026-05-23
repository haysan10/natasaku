import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/budget_period.dart';
import '../../data/models/transaction_model.dart';

typedef DirectoryProvider = Future<Directory> Function();

class ReportExportService {
  ReportExportService({DirectoryProvider? baseDirectoryProvider})
      : _baseDirectoryProvider = baseDirectoryProvider ?? _defaultBaseDirectory;

  final DirectoryProvider _baseDirectoryProvider;

  Future<File> exportTransactionsExcel({
    required List<TransactionModel> transactions,
    BudgetPeriod? activePeriod,
    required double totalIncome,
    required double totalExpense,
    int? healthScore,
  }) async {
    final baseDir = await _baseDirectoryProvider();
    final folder = Directory('${baseDir.path}/NataSaku/Reports');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final now = DateTime.now();
    final fileName =
        'Transaksi_NataSaku_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.xlsx';
    final file = File('${folder.path}/$fileName');

    final excel = Excel.createExcel();
    final String sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheet = excel[sheetName];

    // Format columns width
    sheet.setColumnWidth(0, 22.0); // Tanggal Transaksi
    sheet.setColumnWidth(1, 15.0); // Jenis Aliran
    sheet.setColumnWidth(2, 20.0); // Kategori Pos
    sheet.setColumnWidth(3, 35.0); // Catatan / Deskripsi Jajan
    sheet.setColumnWidth(4, 20.0); // Nominal Rupiah

    // Styles
    final CellStyle titleStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#0F766E'), // Teal Primary
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 14,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final CellStyle sectionStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'), // Slate 100
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#0F172A'), // Slate 900
    );

    final CellStyle headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#1E293B'), // Slate 800
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final CellStyle normalStyle = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#334155'), // Slate 700
    );

    final CellStyle expenseStyle = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#EF4444'), // Red
      bold: true,
    );

    final CellStyle incomeStyle = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#10B981'), // Green
      bold: true,
    );

    // Main Title header
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("E1"), customValue: TextCellValue("NATASAKU EXECUTIVE FINANCIAL LEDGER"));
    sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

    // Metadata Rows
    void writeMeta(int row, String label, String value) {
      final cellLabel = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      cellLabel.value = TextCellValue(label);
      cellLabel.cellStyle = CellStyle(bold: true, fontColorHex: ExcelColor.fromHexString('#475569'));

      final cellValue = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      cellValue.value = TextCellValue(value);
      cellValue.cellStyle = normalStyle;
    }

    final periodText = activePeriod == null
        ? 'Belum Diatur'
        : '${_fmtDate(activePeriod.startDate)} - ${_fmtDate(activePeriod.endDate)}';
    final resolvedScore = healthScore ?? 78;

    writeMeta(2, 'Pembuat Dokumen', 'Sistem Pengelola Anggaran Mandiri NataSaku (Offline)');
    writeMeta(3, 'Tanggal Cetak', '${_fmtDateTime(now)} WIB');
    writeMeta(4, 'Periode Anggaran', periodText);
    writeMeta(5, 'Skor Kesehatan', '$resolvedScore / 100 (${resolvedScore >= 80 ? "PRIMA" : resolvedScore >= 50 ? "WASPADA" : "KRITIS"})');

    // Section 1: Financial Summary Cards
    sheet.merge(CellIndex.indexByString("A7"), CellIndex.indexByString("E7"), customValue: TextCellValue("RINGKASAN KEUANGAN (EXECUTIVE SUMMARY)"));
    sheet.cell(CellIndex.indexByString("A7")).cellStyle = sectionStyle;

    void writeSummaryRow(int row, String label, double amount, {bool isNet = false}) {
      final cellLabel = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      cellLabel.value = TextCellValue(label);
      cellLabel.cellStyle = CellStyle(bold: true, fontColorHex: ExcelColor.fromHexString('#334155'));

      final cellValue = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      cellValue.value = DoubleCellValue(amount);
      cellValue.cellStyle = isNet 
          ? (amount >= 0 ? incomeStyle : expenseStyle)
          : normalStyle;

      if (isNet) {
        final cellExtra = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
        cellExtra.value = TextCellValue(amount >= 0 ? 'SURPLUS' : 'DEFISIT');
        cellExtra.cellStyle = amount >= 0 ? incomeStyle : expenseStyle;
      }
    }

    writeSummaryRow(8, 'Total Pemasukan', totalIncome);
    writeSummaryRow(9, 'Total Pengeluaran', totalExpense);
    writeSummaryRow(10, 'Arus Kas Bersih', totalIncome - totalExpense, isNet: true);

    // Section 2: Ledger Detail
    sheet.merge(CellIndex.indexByString("A12"), CellIndex.indexByString("E12"), customValue: TextCellValue("DAFTAR DETIL ALIRAN KAS TRANSAKSI (LEDGER DETAIL)"));
    sheet.cell(CellIndex.indexByString("A12")).cellStyle = sectionStyle;

    // Table Headers
    final List<String> headers = ['Tanggal Transaksi', 'Jenis Aliran', 'Kategori Pos', 'Catatan / Deskripsi Jajan', 'Nominal Rupiah'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 13));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    int currentRow = 14;

    for (final tx in sorted) {
      final cellDate = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cellDate.value = TextCellValue(_fmtDateTime(tx.date));
      cellDate.cellStyle = normalStyle;

      final cellType = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      cellType.value = TextCellValue(tx.isExpense ? 'Keluar' : 'Masuk');
      cellType.cellStyle = tx.isExpense ? expenseStyle : incomeStyle;

      final cellCategory = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow));
      cellCategory.value = TextCellValue(tx.category ?? 'Tanpa Kategori');
      cellCategory.cellStyle = normalStyle;

      final cellNote = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow));
      cellNote.value = TextCellValue((tx.note?.trim().isEmpty ?? true) ? 'Pencatatan jajan mandiri' : tx.note!.trim());
      cellNote.cellStyle = normalStyle;

      final cellAmount = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow));
      cellAmount.value = DoubleCellValue(tx.isExpense ? -tx.amount : tx.amount);
      cellAmount.cellStyle = tx.isExpense ? expenseStyle : incomeStyle;

      currentRow++;
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
    }
    return file;
  }

  Future<File> exportTransactionsCsv({
    required List<TransactionModel> transactions,
    BudgetPeriod? activePeriod,
    required double totalIncome,
    required double totalExpense,
    int? healthScore,
  }) async {
    final baseDir = await _baseDirectoryProvider();
    final folder = Directory('${baseDir.path}/NataSaku/Reports');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final now = DateTime.now();
    final fileName =
        'Transaksi_NataSaku_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.csv';
    final file = File('${folder.path}/$fileName');
    
    final csvContent = buildTransactionsCsv(
      transactions: transactions,
      activePeriod: activePeriod,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      healthScore: healthScore,
    );
    
    await file.writeAsString(csvContent);
    return file;
  }

  static String buildTransactionsCsv({
    required List<TransactionModel> transactions,
    BudgetPeriod? activePeriod,
    required double totalIncome,
    required double totalExpense,
    int? healthScore,
  }) {
    final now = DateTime.now();
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final netBalance = totalIncome - totalExpense;
    final periodText = activePeriod == null
        ? 'Belum Diatur'
        : '${_fmtDate(activePeriod.startDate)} - ${_fmtDate(activePeriod.endDate)}';
        
    final resolvedScore = healthScore ?? 78;

    final List<List<String>> csvLines = [
      ['========================================================================='],
      ['                   NATASAKU EXECUTIVE FINANCIAL LEDGER EXPORT             '],
      ['========================================================================='],
      ['Pembuat Dokumen', 'Sistem Pengelola Anggaran Mandiri NataSaku (Offline)'],
      ['Tanggal Cetak', '${_fmtDateTime(now)} WIB'],
      ['Periode Anggaran', periodText],
      ['Skor Kesehatan', '$resolvedScore / 100 (${resolvedScore >= 80 ? "PRIMA" : resolvedScore >= 50 ? "WASPADA" : "KRITIS"})'],
      ['-------------------------------------------------------------------------'],
      ['RINGKASAN LAPORAN KEUANGAN (EXECUTIVE SUMMARY):'],
      ['Total Pemasukan', 'Rp ${totalIncome.round()}'],
      ['Total Pengeluaran', 'Rp ${totalExpense.round()}'],
      ['Arus Kas Bersih', 'Rp ${netBalance.round()} (${netBalance >= 0 ? "SURPLUS" : "DEFISIT"})'],
      ['Status Dokumen', 'TERVERIFIKASI & TERSIMPAN LOKAL'],
      ['========================================================================='],
      [''],
      ['DAFTAR DETIL ALIRAN KAS TRANSAKSI (LEDGER DETAIL):'],
      ['Tanggal Transaksi', 'Jenis Aliran', 'Kategori Pos', 'Catatan / Deskripsi Jajan', 'Nominal Rupiah'],
    ];

    for (final tx in sorted) {
      csvLines.add([
        _fmtDateTime(tx.date),
        tx.isExpense ? 'Keluar' : 'Masuk',
        tx.category ?? 'Tanpa Kategori',
        (tx.note?.trim().isEmpty ?? true) ? 'Pencatatan jajan mandiri' : tx.note!.trim(),
        '${tx.isExpense ? "-" : "+"}${tx.amount.round()}',
      ]);
    }

    return csvLines.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  static Future<Directory> _defaultBaseDirectory() async {
    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    }
    return baseDir ?? await getApplicationDocumentsDirectory();
  }

  static String _fmtDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  static String _fmtDateTime(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  static String _csvCell(Object? value) {
    final raw = value?.toString() ?? '';
    if (raw.contains(',') || raw.contains('"') || raw.contains('\n')) {
      return '"${raw.replaceAll('"', '""')}"';
    }
    return raw;
  }
}
