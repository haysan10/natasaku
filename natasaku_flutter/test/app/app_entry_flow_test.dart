import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:natasaku/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('app shows welcome gate when onboarding is incomplete even when period exists',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'dashboard_tutorial_seen': true,
      'onboarding_complete': false,
      'budget_period': '{"id":"active_period","startDate":"2026-05-01T00:00:00.000","endDate":"2026-05-30T00:00:00.000","flexibleFund":1500000,"fixedExpenses":0,"monthlySavingAllocation":0,"mode":"normal"}',
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: NataSakuApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Uang Anda'), findsOneWidget);
    expect(find.text('MULAI PERJALANAN ANDA'), findsOneWidget);
  });

  testWidgets('app goes to dashboard when onboarding is complete and period exists',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'budget_period': '{"id":"active_period","startDate":"2026-05-01T00:00:00.000","endDate":"2026-05-30T00:00:00.000","flexibleFund":1500000,"fixedExpenses":0,"monthlySavingAllocation":0,"mode":"normal"}',
      'transactions': '[]',
      'dashboard_tutorial_seen': true,
      'feature_tour_completed': true,
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: NataSakuApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Jatah'), findsWidgets);
    expect(find.text('MULAI PERJALANAN ANDA'), findsNothing);
  });

  testWidgets('welcome opens animated feature tour before setup',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: NataSakuApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('MULAI PERJALANAN ANDA'));
    await tester.tap(find.text('MULAI PERJALANAN ANDA'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Now it goes to TourPage (titled "Tour Fitur NataSaku")
    expect(find.text('Tour Fitur NataSaku'), findsOneWidget);

    // Let's tap 'Lewati' to skip the tour and go to setup
    await tester.tap(find.text('Lewati'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Atur Keuangan'), findsOneWidget);
  });
}
