import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasaku_flutter/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shows welcome gate when active period is missing',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'dashboard_tutorial_seen': true,
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
