import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'BDK detail screen locks patient association and passes it to PDF export',
    () {
      final source = File(
        'lib/screens/bdk/bdk_detail_screen.dart',
      ).readAsStringSync();

      expect(source, contains('Future<PatientLocal?> _loadSessionPatient()'));
      expect(
        source,
        contains(
          'RgpdLocalService.getPatientByLocalId(\n'
          '        associatedLocalId,',
        ),
      );
      expect(source, contains('return RgpdLocalService.getCurrentPatient();'));
      expect(source, contains('BDKSessionService.associatePatient('));
      expect(source, contains('if (BDKSessionService.hasPatientAssociation)'));
      expect(source, contains('PatientLocal? currentPatient'));
      expect(source, contains('patient: currentPatient'));
      expect(source, contains('BdkPdfService.exportBdkPdf'));
      expect(source, contains('BdkDraftService.saveActiveDraft('));
      expect(source, contains('BdkDraftService.clearActiveDraft()'));
      expect(
        source,
        contains('Le PDF n’a pas pu être généré. Veuillez réessayer.'),
      );
      expect(source, isNot(contains('patient.anonymousId')));
      expect(source, isNot(contains('patient.dateNaissance')));
      expect(source, isNot(contains('StackTrace')));
    },
  );
}
