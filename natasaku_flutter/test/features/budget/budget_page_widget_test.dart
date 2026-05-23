import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasaku/features/budget/budget_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  testWidgets('budget page summarizes active period and offers setup edit',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'flutter.budget_period': jsonEncode({
        'id': 'active_period',
        'startDate': DateTime(2026, 5, 1).toIso8601String(),
        'endDate': DateTime(2026, 5, 31).toIso8601String(),
        'flexibleFund': 1550000,
        'mode': 'hemat',
      }),
      'flutter.transactions': jsonEncode([]),
    });

    tester.view.physicalSize = const Size(540, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BudgetPage(),
        ),
      ),
    );

    // First pump triggers postFrameCallback
    await tester.pump();
    // Pump extra time for delayed animation (400ms)
    await tester.pump(const Duration(milliseconds: 600));
    // Settle animations
    await tester.pumpAndSettle();

    // Scroll down to build off-screen lazy loaded Mode Card
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Budget'), findsWidgets);
    expect(find.text('Dana Awal'), findsOneWidget);
    expect(find.text('Mode: Hemat'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.pencilSimple), findsWidgets);
  });
}
