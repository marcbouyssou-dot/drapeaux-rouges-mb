import 'dart:io';

import 'package:drapeaux_rouges_mb/models/attestation/attestation_history_item.dart';
import 'package:drapeaux_rouges_mb/models/attestation/attestation_template.dart';
import 'package:drapeaux_rouges_mb/models/attestation/attestation_type.dart';
import 'package:drapeaux_rouges_mb/models/attestation/patient_attestation.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:drapeaux_rouges_mb/screens/attestation/attestation_history_detail_screen.dart';
import 'package:drapeaux_rouges_mb/screens/attestation/attestation_history_screen.dart';
import 'package:drapeaux_rouges_mb/services/attestation_history_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp(
      'attestation_history_screen_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox(AttestationHistoryService.boxName);
  });

  setUp(() async {
    await Hive.box(AttestationHistoryService.boxName).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('shows empty attestation history state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AttestationHistoryScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Aucune attestation générée pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('shows saved attestations and opens detail', (tester) async {
    final item = AttestationHistoryItem.fromAttestation(_attestation());

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AttestationHistoryDetailScreen(attestation: item),
                    ),
                  );
                },
                child: const Text('Ouvrir détail attestation'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir détail attestation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(AttestationHistoryDetailScreen), findsOneWidget);
    expect(find.text('Régénérer le PDF'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Praticien'), findsOneWidget);
    expect(find.text('DUPONT Alice'), findsOneWidget);
  });
}

PatientAttestation _attestation() {
  return PatientAttestation(
    template: attestationTemplates.singleWhere(
      (item) => item.type == AttestationType.nearestAvailableMk,
    ),
    patient: PatientLocal(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      nom: 'Dupont',
      prenom: 'Alice',
      dateNaissance: '01/01/1980',
      consentementValide: true,
      dateConsentement: DateTime(2026, 1, 1),
    ),
    practitioner: const PractitionerProfile(
      nom: 'Martin',
      prenom: 'Claire',
      adresse: '12 rue de la Santé, 33000 Bordeaux',
      adeli: '123456789',
      rpps: '10101010101',
    ),
    date: DateTime(2026, 6, 14),
    lieu: 'Bordeaux',
  );
}
