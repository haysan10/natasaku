import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:natasaku_flutter/features/transactions/transactions_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  testWidgets('transactions page exposes search filters edit and delete',
      (tester) async {
    tester.view.physicalSize = const Size(540, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      'transactions': jsonEncode([
        {
          'id': 't1',
          'date': DateTime(2026, 5, 11, 8, 30).toIso8601String(),
          'amount': 25000,
          'isExpense': true,
          'note': 'nasi',
          'category': 'Makan',
        },
        {
          'id': 't2',
          'date': DateTime(2026, 5, 11, 9, 30).toIso8601String(),
          'amount': 100000,
          'isExpense': false,
          'note': 'bonus',
          'category': 'Pemasukan',
        },
      ]),
    });

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TransactionsPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: '/budget',
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: '/savings',
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const Placeholder(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsWidgets);
    expect(find.text('Pemasukan'), findsWidgets);
    expect(find.text('Makan'), findsOneWidget);

    // Scroll up to ensure transaction row is not obscured by bottom navigation bar
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -200));
    await tester.pumpAndSettle();

    // Tap transaction to edit
    await tester.tap(find.text('Makan'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan Transaksi'), findsOneWidget);
    // Dismiss sheet by tapping Simpan Transaksi
    await tester.tap(find.text('Simpan Transaksi'));
    await tester.pumpAndSettle();

    // Search filter
    await tester.enterText(find.byType(TextField), 'bonus');
    await tester.pumpAndSettle();

    expect(find.text('Pemasukan'), findsWidgets);
    expect(find.text('Makan'), findsNothing);
  });
}
