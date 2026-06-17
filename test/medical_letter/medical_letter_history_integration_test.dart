import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unified history is wired to medical letters', () {
    final source = File('lib/screens/history_screen.dart').readAsStringSync();

    expect(source, contains('MedicalLetterHistoryService.getLetters()'));
    expect(source, contains('HistoryView.medicalLetters'));
    expect(source, contains("label: 'Courriers'"));
    expect(source, contains('buildMedicalLetterEmptyState'));
    expect(source, contains('buildMedicalLetterCard'));
    expect(source, contains('MedicalLetterHistoryDetailScreen(letter: item)'));
  });

  test('medical letter detail can regenerate PDF from historized data', () {
    final source = File(
      'lib/screens/medical_letter/medical_letter_history_detail_screen.dart',
    ).readAsStringSync();

    expect(source, contains('MedicalLetterPdfService.exportPdf'));
    expect(source, contains('letter.toLetter()'));
    expect(source, contains('Régénérer le PDF'));
  });
}
