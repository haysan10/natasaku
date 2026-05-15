import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/features/dashboard/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('dashboard prioritizes daily actions over technical cards',
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
        home: DashboardPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catat Cepat'), findsOneWidget);
    expect(find.text('Saya Lupa Catat'), findsOneWidget);
    expect(find.text('Cek Sebelum Beli'), findsOneWidget);
    expect(find.text('Tutup Hari'), findsOneWidget);
    expect(find.text('Mode Saat Ini'), findsNothing);
    expect(find.text('Dasar Hitungan Batas Aman'), findsNothing);
  });
}
