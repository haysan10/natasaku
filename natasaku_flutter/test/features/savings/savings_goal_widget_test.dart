import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/features/savings/savings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('savings page shows active goal progress', (tester) async {
    SharedPreferences.setMockInitialValues({
      'saving_balance': 500000.0,
      'saving_goal': jsonEncode({
        'id': 'goal-1',
        'name': 'Dana Darurat',
        'targetAmount': 2000000,
        'currentAmount': 250000,
        'targetDate': DateTime(2026, 12, 31).toIso8601String(),
      }),
      'saving_allocations': jsonEncode([]),
    });

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SavingsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Dana Darurat'), findsOneWidget);
    expect(find.text('Target aktif'), findsOneWidget);
    expect(find.text('Terkumpul'), findsOneWidget);
    expect(find.text('Sisa menuju target'), findsOneWidget);
    expect(find.text('Progress Target'), findsNothing);
    expect(find.text('Atur Target'), findsOneWidget);

    final mainScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Auto-celengan'), 260, scrollable: mainScrollable);
    expect(find.text('Auto-celengan'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Alur tabungan'), 260, scrollable: mainScrollable);
    expect(find.text('Alur tabungan'), findsOneWidget);
  });
}
