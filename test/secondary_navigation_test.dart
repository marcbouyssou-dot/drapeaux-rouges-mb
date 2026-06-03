import 'package:drapeaux_rouges_mb/screens/bdk/bdk_type_screen.dart';
import 'package:drapeaux_rouges_mb/screens/prescription/prescription_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BDK type screen shows a clear back button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BDKTypeScreen()));

    expect(find.byTooltip('Retour'), findsOneWidget);
  });

  testWidgets('Prescription type screen shows a clear back button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrescriptionTypeScreen()));

    expect(find.byTooltip('Retour'), findsOneWidget);
  });
}
