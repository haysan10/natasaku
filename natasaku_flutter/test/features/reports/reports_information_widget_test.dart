import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:natasaku_flutter/features/reports/reports_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  testWidgets('reports focus on financial summary instead of backup actions',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      'dashboard_tutorial_seen': true,
      'budget_period': jsonEncode({
        'id': 'active_period',
        'startDate': DateTime(2026, 5, 1).toIso8601String(),
        'endDate': DateTime(2026, 5, 31).toIso8601String(),
        'flexibleFund': 1500000,
        'mode': 'normal',
      }),
      'transactions': jsonEncode([]),
    });

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ReportsPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: '/transactions',
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
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Executive Report'), findsOneWidget);
    expect(find.text('Laporan Keuangan'), findsWidgets);
    expect(find.text('Skor Kesehatan Finansial'), findsOneWidget);
    expect(find.text('AI Rekomendasi Manager'), findsOneWidget);

    // Tap Book Kas & Ekspor tab
    await tester.tap(find.text('Buku Kas & Ekspor'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Export Excel'), findsOneWidget);
    expect(find.text('Export Backup'), findsNothing);
    expect(find.text('Restore Backup'), findsNothing);

    // Drain all remaining delayed animation timers to prevent test invariant failure
    await tester.pump(const Duration(seconds: 10));
  });
}
