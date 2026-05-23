import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:natasaku/app/router.dart';
import 'package:natasaku/features/budget/budget_page.dart';
import 'package:natasaku/features/dashboard/dashboard_page.dart';
import 'package:natasaku/features/reports/reports_page.dart';
import 'package:natasaku/features/savings/savings_page.dart';
import 'package:natasaku/features/transactions/transactions_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  test('budget route is registered', () {
    final route = AppRouter.onGenerateRoute(
      const RouteSettings(name: AppRouter.budget),
    );

    expect(route, isA<MaterialPageRoute<dynamic>>());
  });

  testWidgets('main tabs use Beranda Transaksi Budget Tabungan Laporan',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: DashboardPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Tabungan'), findsOneWidget);
    expect(find.text('Laporan'), findsOneWidget);
    expect(find.text('Pengaturan'), findsNothing);

    expect(AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.dashboard)), isA<MaterialPageRoute<dynamic>>());
    expect(AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.transactions)), isA<MaterialPageRoute<dynamic>>());
    expect(AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.budget)), isA<MaterialPageRoute<dynamic>>());
    expect(AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.savings)), isA<MaterialPageRoute<dynamic>>());
    expect(AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.reports)), isA<MaterialPageRoute<dynamic>>());

    expect(const BudgetPage(), isA<BudgetPage>());
    expect(const TransactionsPage(), isA<TransactionsPage>());
    expect(const SavingsPage(), isA<SavingsPage>());
    expect(const ReportsPage(), isA<ReportsPage>());
  });
}
