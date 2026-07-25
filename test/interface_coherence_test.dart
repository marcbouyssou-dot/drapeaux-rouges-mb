import 'dart:io';

import 'package:drapeaux_rouges_mb/models/bdk_history_item.dart';
import 'package:drapeaux_rouges_mb/screens/bdk/bdk_history_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BDK history detail uses the shared detail action hierarchy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BdkHistoryDetailScreen(item: _bdkItem())),
    );

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('PATIENT TEST'), findsOneWidget);
    expect(find.text('Supprimer'), findsOneWidget);
    expect(find.text('Régénérer le PDF'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    final deleteButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Supprimer'),
    );
    expect(deleteButton.style?.foregroundColor?.resolve({}), isNotNull);
  });

  test('all document detail deletions keep explicit confirmation', () {
    final paths = [
      'lib/screens/bdk/bdk_history_detail_screen.dart',
      'lib/screens/prescription/prescription_history_detail_screen.dart',
      'lib/screens/medical_letter/medical_letter_history_detail_screen.dart',
      'lib/screens/attestation/attestation_history_detail_screen.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      expect(source, contains('showRadarDestructiveConfirmationDialog('));
      expect(source, contains("confirmLabel: 'Supprimer'"));
      expect(source, contains('RadarColors.clinicalDanger'));
    }
  });

  test('history provides a non-blank empty state for every category', () {
    final source = File('lib/screens/history_screen.dart').readAsStringSync();

    for (final title in [
      'Aucun bilan enregistré',
      'Aucune prescription enregistrée',
      'Aucune attestation générée',
      'Aucun courrier médical généré',
      'Aucun BDK terminé',
    ]) {
      expect(source, contains(title));
    }
  });
}

BdkHistoryItem _bdkItem() {
  final date = DateTime.utc(2026, 7, 25, 10);
  return BdkHistoryItem(
    id: 'bdk-test',
    title: 'BDK Lombalgie',
    generatedAt: date,
    updatedAt: date,
    patientLocalId: 'patient-test',
    patientAnonymousId: 'anonymous-test',
    patientDisplayName: 'PATIENT TEST',
    motif: 'Lombalgie',
    contexte: '',
    antecedents: '',
    evaluation: '',
    tests: '',
    limitations: '',
    diagnostic: '',
    vigilance: '',
    objectifs: '',
    planTraitement: '',
    criteresReevaluation: '',
    syntheseClinique: '',
    patientSnapshot: null,
    practitionerSnapshot: const {},
  );
}
