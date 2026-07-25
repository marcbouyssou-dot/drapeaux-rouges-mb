import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'document form reset is protected by Radar destructive confirmation',
    () {
      final source = File(
        'lib/screens/prescription_screen.dart',
      ).readAsStringSync();

      expect(source, contains('Future<void> resetForm() async'));
      expect(source, contains("title: 'Réinitialiser la prescription ?'"));
      expect(source, contains("confirmLabel: 'Réinitialiser'"));
      expect(source, contains('showRadarDestructiveConfirmationDialog'));
    },
  );

  test('BDK reset is protected by Radar destructive confirmation', () {
    final source = File(
      'lib/screens/bdk/bdk_detail_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Future<void> _resetBDK() async'));
    expect(source, contains("title: 'Réinitialiser le BDK ?'"));
    expect(source, contains('BDKSessionService.clear()'));
    expect(source, contains('showRadarDestructiveConfirmationDialog'));
  });

  test('persistent access direct document deletion is confirmed', () {
    final source = File(
      'lib/screens/access_direct_settings_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Future<void> removeDocument() async'));
    expect(source, contains("title: 'Supprimer le justificatif ?'"));
    expect(
      source,
      contains('AccessDirectLocalService.saveSettings(currentModel)'),
    );
    expect(source, contains('showRadarDestructiveConfirmationDialog'));
  });

  test('persistent diagnosis document deletion is confirmed', () {
    final source = File(
      'lib/screens/patient_consent_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Future<void> removeDiagnosisDocument() async'));
    expect(source, contains('diagnostic préalable'));
    expect(source, contains('AccessDirectLocalService.saveSettings'));
    expect(source, contains('showRadarDestructiveConfirmationDialog'));
  });
}
