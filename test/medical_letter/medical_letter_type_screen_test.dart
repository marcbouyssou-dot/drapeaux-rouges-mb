import 'package:drapeaux_rouges_mb/screens/medical_letter/medical_letter_type_screen.dart';
import 'package:drapeaux_rouges_mb/screens/prescription/prescription_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows medical letter template library', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MedicalLetterTypeScreen()));

    expect(find.text('Information médecin traitant'), findsOneWidget);
    expect(find.text('Orientation médicale'), findsOneWidget);
    expect(find.text('Avis spécialisé'), findsOneWidget);
  });

  testWidgets('prescription medical letters item opens letter library', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrescriptionTypeScreen()));

    await tester.tap(find.text('Courriers médicaux'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MedicalLetterTypeScreen), findsOneWidget);
    expect(find.text('Information médecin traitant'), findsOneWidget);
  });
}
