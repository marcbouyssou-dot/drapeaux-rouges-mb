import 'dart:io';

import 'package:drapeaux_rouges_mb/screens/medical_letter/medical_letter_screen.dart';
import 'package:drapeaux_rouges_mb/screens/medical_letter/medical_letter_type_screen.dart';
import 'package:drapeaux_rouges_mb/screens/prescription/prescription_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp(
      'medical_letter_type_screen_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox('settings_box');
    await Hive.openBox('patients_box');
    await Hive.openBox('evaluations_box');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

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

  testWidgets('medical letter template opens the complete form', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MedicalLetterTypeScreen()));

    await tester.tap(find.text('Information médecin traitant'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MedicalLetterScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Générer le PDF'), findsOneWidget);
  });
}
