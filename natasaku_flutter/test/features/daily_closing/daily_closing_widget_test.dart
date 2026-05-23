import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/data/datasources/local/local_storage.dart';
import 'package:natasaku_flutter/data/models/budget_period.dart';
import 'package:natasaku_flutter/data/models/transaction_model.dart';
import 'package:natasaku_flutter/data/repositories/budget_repository.dart';
import 'package:natasaku_flutter/features/daily_closing/daily_closing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('daily closing saves current day summary', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = BudgetRepository(LocalStorage());

    await repo.savePeriod(
      BudgetPeriod(
        id: 'p1',
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 30),
        flexibleFund: 1000000,
      ),
    );

    await repo.addTransaction(
      TransactionModel(
        id: 't1',
        date: DateTime.now(),
        amount: 15000,
        isExpense: true,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DailyClosingPage(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Simpan Daily Closing'));
    await tester.pumpAndSettle();

    final closings = await repo.loadDailyClosings();
    expect(closings.isNotEmpty, true);
  });
}
