import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/data/datasources/local/local_storage.dart';
import 'package:natasaku/data/models/budget_period.dart';
import 'package:natasaku/data/models/transaction_model.dart';
import 'package:natasaku/data/repositories/budget_repository.dart';
import 'package:natasaku/features/daily_closing/daily_closing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('daily closing saves current day summary', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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

    final saveBtn = find.byType(FilledButton, skipOffstage: false);
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    final closings = await repo.loadDailyClosings();
    expect(closings.isNotEmpty, true);
  });
}
