import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/app/router.dart';
import 'package:natasaku_flutter/features/tour/tour_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('tour route is registered', () {
    final route = AppRouter.onGenerateRoute(
      const RouteSettings(name: AppRouter.tour),
    );

    expect(route, isA<MaterialPageRoute<dynamic>>());
  });

  testWidgets('tour page shows animated feature slides and advances',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: TourPage(),
      ),
    );
    await tester.pump();

    expect(find.text('Tour Fitur NataSaku'), findsOneWidget);
    expect(find.text('Batas Aman Harian'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsWidgets);
    expect(find.byType(TweenAnimationBuilder<double>), findsWidgets);
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Catat Cepat'), findsOneWidget);
  });
}
