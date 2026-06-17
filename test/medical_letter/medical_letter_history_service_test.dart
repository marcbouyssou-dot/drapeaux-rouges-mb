import 'dart:io';

import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_history_item.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_template.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_type.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:drapeaux_rouges_mb/services/medical_letter_history_service.dart';
import 'package:drapeaux_rouges_mb/services/medical_letter_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp(
      'medical_letter_history_service_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox(MedicalLetterHistoryService.boxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('returns empty history when no letter was saved', () async {
    final letters = await MedicalLetterHistoryService.getLetters();

    expect(letters, isEmpty);
  });

  test('saves and reads generated medical letter history', () async {
    final item = MedicalLetterHistoryItem.fromLetter(_letter());

    await MedicalLetterHistoryService.saveLetter(item);

    final saved = await MedicalLetterHistoryService.getLetters();

    expect(saved, hasLength(1));
    expect(saved.single.title, 'Orientation médicale');
    expect(saved.single.displayPatient, 'DUPONT Alice');
    expect(saved.single.bodyParagraphs, isNotEmpty);
  });

  test('stores anonymous patient without crashing', () {
    final item = MedicalLetterHistoryItem.fromLetter(
      _letter(withPatient: false),
    );

    expect(item.displayPatient, 'Patient non identifié');
    expect(item.patientLocal, isNull);
  });

  test('keeps data necessary for PDF regeneration', () {
    final item = MedicalLetterHistoryItem.fromLetter(_letter());

    expect(item.toLetter().bodyParagraphs, item.bodyParagraphs);
    expect(item.toLetter().template.type, MedicalLetterType.medicalOrientation);
    expect(item.toLetter().treatingDoctorDetails, contains('RPPS'));
    expect(item.toLetter().treatingDoctorDetails, contains('1 rue médicale'));
  });

  test('regenerates PDF from history data', () async {
    final item = MedicalLetterHistoryItem.fromLetter(_letter());
    final bytes = await MedicalLetterPdfService.buildPdfBytes(item.toLetter());

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}

MedicalLetter _letter({bool withPatient = true}) {
  return MedicalLetter(
    template: medicalLetterTemplates.singleWhere(
      (item) => item.type == MedicalLetterType.medicalOrientation,
    ),
    patient: withPatient ? _patient() : null,
    practitioner: const PractitionerProfile(
      nom: 'Durand',
      prenom: 'Camille',
      adresse: '12 rue de la Santé, 33000 Bordeaux',
      adeli: '123456789',
      rpps: '10101010101',
    ),
    date: DateTime(2026, 6, 17),
    lieu: 'Bordeaux',
  );
}

PatientLocal _patient() {
  return PatientLocal(
    localId: 'patient-1',
    anonymousId: 'DR-patient-1',
    nom: 'Dupont',
    prenom: 'Alice',
    dateNaissance: '01/01/1980',
    consentementValide: true,
    dateConsentement: DateTime(2026, 1, 1),
    medecinNom: 'Dr Martin',
    medecinRpps: '12345678901',
    medecinAdeli: 'ADELI123',
    medecinAdresse: '1 rue médicale, 33000 Bordeaux',
    medecinTelephone: '0555555555',
    medecinEmail: 'dr.martin@example.fr',
  );
}
