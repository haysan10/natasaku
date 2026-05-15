import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shows welcome gate when active period is missing',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'dashboard_tutorial_seen': true,
    });

    await tester.pumpWidget(const NataSakuApp());
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di NataSaku'), findsOneWidget);
    expect(find.text('Mulai Atur Uang'), findsOneWidget);
  });
}
