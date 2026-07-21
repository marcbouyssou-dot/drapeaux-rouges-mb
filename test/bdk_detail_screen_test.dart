import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'BDK detail screen loads current patient and passes it to PDF export',
    () {
      final source = File(
        'lib/screens/bdk/bdk_detail_screen.dart',
      ).readAsStringSync();

      expect(source, contains('RgpdLocalService.getCurrentPatient()'));
      expect(source, contains('PatientLocal? currentPatient'));
      expect(source, contains('patient: currentPatient'));
      expect(source, contains('BdkPdfService.exportBdkPdf'));
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
