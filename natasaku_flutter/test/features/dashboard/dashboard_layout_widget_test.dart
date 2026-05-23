import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasaku_flutter/features/dashboard/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  testWidgets('dashboard prioritizes daily actions over technical cards',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'flutter.dashboard_tutorial_seen': true,
      'dashboard_tutorial_seen': true,
      'flutter.budget_period': jsonEncode({
        'id': 'active_period',
        'startDate': DateTime(2026, 5, 1).toIso8601String(),
        'endDate': DateTime(2026, 5, 31).toIso8601String(),
        'flexibleFund': 1500000,
        'mode': 'normal',
      }),
      'budget_period': jsonEncode({
        'id': 'active_period',
        'startDate': DateTime(2026, 5, 1).toIso8601String(),
        'endDate': DateTime(2026, 5, 31).toIso8601String(),
        'flexibleFund': 1500000,
        'mode': 'normal',
      }),
      'flutter.transactions': jsonEncode([]),
      'transactions': jsonEncode([]),
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );
    // Let async loads finish
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Jatah Hari Ini'), findsOneWidget);
    expect(find.text('Sisa Jatah Boleh Dipakai'), findsOneWidget);
    expect(find.text('Auto Amankan Sisa'), findsOneWidget);
  });
}
