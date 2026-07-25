import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'medical letter without current patient does not load any evaluation',
    () {
      final source = File(
        'lib/screens/medical_letter/medical_letter_screen.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          'Future<EvaluationModel?> latestEvaluationForPatient(\n'
          '    PatientLocal? currentPatient,\n'
          '  ) async {\n'
          '    if (currentPatient == null) return null;',
        ),
      );
      expect(
        source,
        isNot(contains('if (currentPatient == null) return true;')),
      );
    },
  );
}
