import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/features/reports/reports_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('reports focus on financial summary instead of backup actions',
      (tester) async {
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

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Periode Aktif'), findsOneWidget);
    expect(find.text('Ringkasan Utama'), findsOneWidget);
    expect(find.text('Export Backup'), findsNothing);
    expect(find.text('Restore Backup'), findsNothing);
  });
}
