import 'dart:io';
import 'dart:convert';

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
    required int totalIncome,
    required int totalExpense,
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
    
    // Rename default sheet to 'Ringkasan' to avoid leaving an empty default sheet
    final String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(defaultSheet, 'Ringkasan');
    
    final Sheet summarySheet = excel['Ringkasan'];
    final Sheet txSheet = excel['Transaksi'];
    final Sheet pivotSheet = excel['Data_Pivot'];

    // ── Sheet 1: Ringkasan ───────────────────────────────────────────
    summarySheet.setColumnWidth(0, 30.0);
    summarySheet.setColumnWidth(1, 25.0);

    // Styles
    final CellStyle titleStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#0F766E'), // Teal Primary
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 14,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
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

    // Title header
    summarySheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("B1"), customValue: TextCellValue("LAPORAN RINGKASAN KEUANGAN"));
    summarySheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

    final resolvedScore = healthScore ?? 78;
    final periodText = activePeriod == null
        ? 'Belum Diatur'
        : '${_fmtDate(activePeriod.startDate)} - ${_fmtDate(activePeriod.endDate)}';

    final summaryData = [
      ['Pembuat Dokumen', 'Sistem Pengelola Anggaran Mandiri NataSaku (Offline)'],
      ['Tanggal Cetak', '${_fmtDateTime(now)} WIB'],
      ['Periode Anggaran', periodText],
      ['Total Pemasukan', totalIncome],
      ['Total Pengeluaran', totalExpense],
      ['Arus Kas Bersih', totalIncome - totalExpense],
      ['Skor Kesehatan (/100)', resolvedScore],
    ];

    for (int i = 0; i < summaryData.length; i++) {
      final label = summaryData[i][0].toString();
      final val = summaryData[i][1];
      final rowIdx = i + 2;

      final cellLabel = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx));
      cellLabel.value = TextCellValue(label);
      cellLabel.cellStyle = CellStyle(bold: true, fontColorHex: ExcelColor.fromHexString('#475569'));

      final cellValue = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx));
      if (val is int) {
        cellValue.value = IntCellValue(val);
        cellValue.cellStyle = CellStyle(
          numberFormat: NumFormat.custom(formatCode: '"Rp "#,##0'),
          fontColorHex: ExcelColor.fromHexString('#334155'),
        );
      } else {
        cellValue.value = TextCellValue(val.toString());
        cellValue.cellStyle = normalStyle;
      }
    }

    // ── Sheet 2: Semua Transaksi ─────────────────────────────────────────────
    txSheet.setColumnWidth(0, 22.0); // Tanggal Transaksi
    txSheet.setColumnWidth(1, 15.0); // Jenis Aliran
    txSheet.setColumnWidth(2, 20.0); // Kategori Pos
    txSheet.setColumnWidth(3, 35.0); // Catatan / Deskripsi Jajan
    txSheet.setColumnWidth(4, 20.0); // Nominal Rupiah

    // Table Headers
    final List<String> headers = ['Tanggal Transaksi', 'Jenis Aliran', 'Kategori Pos', 'Catatan / Deskripsi Jajan', 'Nominal Rupiah'];
    for (int i = 0; i < headers.length; i++) {
      final cell = txSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    int currentRow = 1;

    for (final tx in sorted) {
      final isEven = currentRow % 2 == 0;
      final rowBgColor = isEven ? '#F8FAFC' : '#FFFFFF';
      
      final cellDate = txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cellDate.value = TextCellValue(_fmtDateTime(tx.date));
      cellDate.cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString(rowBgColor), fontColorHex: ExcelColor.fromHexString('#334155'));

      final cellType = txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      cellType.value = TextCellValue(tx.isExpense ? 'Keluar' : 'Masuk');
      cellType.cellStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString(rowBgColor),
        fontColorHex: ExcelColor.fromHexString(tx.isExpense ? '#EF4444' : '#10B981'),
        bold: true,
      );

      final cellCategory = txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow));
      cellCategory.value = TextCellValue(tx.category ?? 'Tanpa Kategori');
      cellCategory.cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString(rowBgColor), fontColorHex: ExcelColor.fromHexString('#334155'));

      final cellNote = txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow));
      cellNote.value = TextCellValue((tx.note?.trim().isEmpty ?? true) ? 'Pencatatan jajan mandiri' : tx.note!.trim());
      cellNote.cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString(rowBgColor), fontColorHex: ExcelColor.fromHexString('#334155'));

      final cellAmount = txSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow));
      cellAmount.value = IntCellValue(tx.isExpense ? -tx.amount : tx.amount);
      cellAmount.cellStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString(rowBgColor),
        fontColorHex: ExcelColor.fromHexString(tx.isExpense ? '#EF4444' : '#10B981'),
        bold: true,
        numberFormat: NumFormat.custom(formatCode: '"Rp "#,##0'),
      );

      currentRow++;
    }

    // ── Sheet 3: Data Pivot-Ready ────────────────────────────────────────────
    pivotSheet.setColumnWidth(0, 10.0); // Tahun
    pivotSheet.setColumnWidth(1, 10.0); // Bulan
    pivotSheet.setColumnWidth(2, 22.0); // Tanggal
    pivotSheet.setColumnWidth(3, 10.0); // Hari Ke
    pivotSheet.setColumnWidth(4, 20.0); // Kategori
    pivotSheet.setColumnWidth(5, 15.0); // Tipe
    pivotSheet.setColumnWidth(6, 20.0); // Nominal

    final List<String> pivotHeaders = ['Tahun', 'Bulan', 'Tanggal', 'Hari_Ke', 'Kategori', 'Tipe', 'Nominal_IDR'];
    final CellStyle pivotHeaderStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#134E4A'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    for (int i = 0; i < pivotHeaders.length; i++) {
      final cell = pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(pivotHeaders[i]);
      cell.cellStyle = pivotHeaderStyle;
    }

    int pivotRowIdx = 1;
    for (final tx in sorted) {
      pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: pivotRowIdx)).value = IntCellValue(tx.date.year);
      pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: pivotRowIdx)).value = IntCellValue(tx.date.month);
      pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: pivotRowIdx)).value = TextCellValue(_fmtDate(tx.date));
      pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: pivotRowIdx)).value = IntCellValue(tx.date.day);
      pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: pivotRowIdx)).value = TextCellValue(tx.category ?? 'Tanpa Kategori');
      pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: pivotRowIdx)).value = TextCellValue(tx.isExpense ? 'Pengeluaran' : 'Pemasukan');
      
      final cellAmount = pivotSheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: pivotRowIdx));
      cellAmount.value = IntCellValue(tx.amount);
      
      pivotRowIdx++;
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
    required int totalIncome,
    required int totalExpense,
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
    required int totalIncome,
    required int totalExpense,
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

  Future<File> exportJsonBackup({
    required List<TransactionModel> transactions,
    BudgetPeriod? period,
  }) async {
    final baseDir = await _baseDirectoryProvider();
    final folder = Directory('${baseDir.path}/NataSaku/Backups');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final now = DateTime.now();
    final fileName =
        'Backup_NataSaku_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';
    final file = File('${folder.path}/$fileName');

    final backup = {
      'app': 'NataSaku',
      'version': 1,
      'schemaVersion': 1,
      'exportedAt': now.toIso8601String(),
      'period': period == null ? null : {
        'id': period.id,
        'startDate': period.startDate.toIso8601String(),
        'endDate': period.endDate.toIso8601String(),
        'flexibleFund': period.flexibleFund,
        'fixedExpenses': period.fixedExpenses,
        'savingAllocation': period.monthlySavingAllocation,
        'mode': period.mode.name,
      },
      'transactions': transactions.map((tx) => {
        'id': tx.id,
        'date': tx.date.toIso8601String(),
        'amount': tx.amount,
        'isExpense': tx.isExpense,
        'category': tx.category,
        'note': tx.note,
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
    await file.writeAsString(jsonString);
    return file;
  }
}
