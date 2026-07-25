import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const contextReload = 'await RgpdLocalService.getCurrentPatient()';
  const invalidContextMessage = 'Le patient actif a changé ou a été supprimé.';

  test('prescription revalidates its patient before PDF and history', () {
    final source = _source('lib/screens/prescription_screen.dart');
    final exportStart = source.indexOf('Future<void> exportPdf()');
    final reload = source.indexOf(contextReload, exportStart);
    final pdf = source.indexOf(
      'PrescriptionPdfService.exportPrescriptionPdf(',
      exportStart,
    );
    final history = source.indexOf(
      'PrescriptionService.savePrescription(',
      exportStart,
    );

    expect(reload, greaterThan(exportStart));
    expect(reload, lessThan(pdf));
    expect(reload, lessThan(history));
    expect(source, contains(invalidContextMessage));
  });

  test(
    'medical letter revalidates patient and preserves anonymous context',
    () {
      final source = _source(
        'lib/screens/medical_letter/medical_letter_screen.dart',
      );
      final exportStart = source.indexOf('Future<void> exportPdf()');
      final reload = source.indexOf(contextReload, exportStart);
      final pdf = source.indexOf(
        'MedicalLetterPdfService.exportPdf(letter)',
        exportStart,
      );
      final history = source.indexOf(
        'MedicalLetterHistoryService.saveLetter(',
        exportStart,
      );

      expect(reload, greaterThan(exportStart));
      expect(reload, lessThan(pdf));
      expect(reload, lessThan(history));
      expect(source, contains('return loaded == null && current == null;'));
      expect(source, contains(invalidContextMessage));
    },
  );

  test('attestation revalidates its patient before PDF and history', () {
    final source = _source(
      'lib/screens/attestation/patient_attestation_screen.dart',
    );
    final exportStart = source.indexOf('Future<void> exportPdf()');
    final reload = source.indexOf(contextReload, exportStart);
    final pdf = source.indexOf(
      'PatientAttestationPdfService.exportPdf(attestation)',
      exportStart,
    );
    final history = source.indexOf(
      'AttestationHistoryService.saveAttestation(',
      exportStart,
    );

    expect(reload, greaterThan(exportStart));
    expect(reload, lessThan(pdf));
    expect(reload, lessThan(history));
    expect(source, contains(invalidContextMessage));
  });

  test('proximity attestation uses one documentary patient identity', () {
    final source = _source(
      'lib/screens/attestation/patient_attestation_screen.dart',
    );

    expect(source, contains('patient: _documentPatient()'));
    expect(source, contains('PatientLocal? _documentPatient()'));
    expect(source, contains('nom: patientNomController.text.trim()'));
    expect(source, contains('prenom: patientPrenomController.text.trim()'));
    expect(
      source,
      contains('dateNaissance: patientBirthDateController.text.trim()'),
    );
  });
}

String _source(String path) {
  return File(path).readAsStringSync();
}
