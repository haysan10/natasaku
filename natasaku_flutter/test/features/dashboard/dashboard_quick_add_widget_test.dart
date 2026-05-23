import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasaku_flutter/features/dashboard/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('dashboard shows setup prompt when period is empty',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Atur Keuangan Sekarang'), findsOneWidget);
  });
}
