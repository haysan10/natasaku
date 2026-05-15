import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/app/app.dart';

void main() {
  testWidgets('App bootstraps material root', (tester) async {
    await tester.pumpWidget(const NataSakuApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
