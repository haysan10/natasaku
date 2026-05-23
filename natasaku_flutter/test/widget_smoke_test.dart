import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasaku_flutter/app/app.dart';

void main() {
  testWidgets('App bootstraps material root', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NataSakuApp()));
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.darkTheme, isNotNull);
    
    // Pump 2 seconds duration to cleanly consume scheduled platform/GoRouter microtasks and Splash delay
    await tester.pump(const Duration(seconds: 2));
  });
}
