import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/features/notifications/notifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('notifications page explains balanced persistent and sound policy',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    tester.view.physicalSize = const Size(540, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi Jatah Harian NataSaku'), findsOneWidget);
    expect(find.text('Silent & Tetap Tampil (Ongoing)'), findsOneWidget);
    expect(find.text('Tombol Aksi Cepat'), findsOneWidget);

    // Scroll down to expose the bottom footer widget
    final listFinder = find.byType(ListView);
    await tester.drag(listFinder, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Layanan ini terintegrasi penuh ke sistem notifikasi background & foreground Android.'), findsOneWidget);
  });
}
