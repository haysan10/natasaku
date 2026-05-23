import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/core/services/report_export_service.dart';
import 'package:natasaku_flutter/data/models/transaction_model.dart';

void main() {
  test('buildTransactionsCsv exports escaped transaction rows', () {
    final csv = ReportExportService.buildTransactionsCsv(
      transactions: [
        TransactionModel(
          id: 't1',
          date: DateTime(2026, 5, 18, 10, 30),
          amount: 25000,
          isExpense: true,
          category: 'Makan',
          note: 'nasi, minum',
        ),
        TransactionModel(
          id: 't2',
          date: DateTime(2026, 5, 18, 12),
          amount: 100000,
          isExpense: false,
          category: 'Bonus',
        ),
      ],
      totalIncome: 100000,
      totalExpense: 25000,
    );

    expect(csv, contains('18/05/2026 10:30,Keluar,Makan,"nasi, minum",-25000'));
    expect(csv, contains('18/05/2026 12:00,Masuk,Bonus,Pencatatan jajan mandiri,+100000'));
  });

  test('exportTransactionsCsv writes a visible csv file', () async {
    final file = await ReportExportService(
      baseDirectoryProvider: () async => Directory.systemTemp.createTemp(),
    ).exportTransactionsCsv(
      transactions: [
        TransactionModel(
          id: 't1',
          date: DateTime(2026, 5, 18),
          amount: 75000,
          isExpense: true,
          category: 'Transport',
        ),
      ],
      totalIncome: 0,
      totalExpense: 75000,
    );

    expect(file.path, endsWith('.csv'));
    expect(await file.exists(), isTrue);
    expect(await file.readAsString(), contains('Transport'));
  });
}
