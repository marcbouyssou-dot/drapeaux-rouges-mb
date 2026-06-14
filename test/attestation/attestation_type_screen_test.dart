import 'dart:io';

import 'package:drapeaux_rouges_mb/screens/attestation/attestation_type_screen.dart';
import 'package:drapeaux_rouges_mb/screens/attestation/attestation_history_screen.dart';
import 'package:drapeaux_rouges_mb/screens/prescription/prescription_type_screen.dart';
import 'package:drapeaux_rouges_mb/services/attestation_history_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp(
      'attestation_type_screen_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox(AttestationHistoryService.boxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('shows attestation template library', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AttestationTypeScreen()));

    expect(find.text('MK le plus proche disponible'), findsOneWidget);
    expect(find.text('Refus d’orientation médicale proposée'), findsOneWidget);
    expect(find.text('Consentement éclairé renforcé'), findsOneWidget);
    expect(find.text('Prise en charge en accès direct'), findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('Préparé'), findsNWidgets(3));
  });

  testWidgets('prescription attestation item opens attestation library', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrescriptionTypeScreen()));

    await tester.tap(find.text('Attestations'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(AttestationTypeScreen), findsOneWidget);
    expect(find.text('MK le plus proche disponible'), findsOneWidget);
  });

  testWidgets('opens attestation history from library', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AttestationTypeScreen()));

    await tester.tap(find.text('Historique'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(AttestationHistoryScreen), findsOneWidget);
    expect(
      find.text('Aucune attestation générée pour le moment.'),
      findsOneWidget,
    );
  });
}
