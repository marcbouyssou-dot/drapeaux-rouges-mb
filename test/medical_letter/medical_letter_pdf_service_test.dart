import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_template.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_type.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:drapeaux_rouges_mb/services/medical_letter_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates PDF with complete patient and practitioner', () async {
    final bytes = await MedicalLetterPdfService.buildPdfBytes(_letter());

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('generates PDF with anonymous patient', () async {
    final letter = _letter(withPatient: false);
    final bytes = await MedicalLetterPdfService.buildPdfBytes(letter);

    expect(letter.patientFullName, 'Patient non identifié');
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('generates PDF with French accents and typographic apostrophe', () async {
    final bytes = await MedicalLetterPdfService.buildPdfBytes(
      MedicalLetter(
        template: medicalLetterTemplates.singleWhere(
          (item) => item.type == MedicalLetterType.specialistOpinion,
        ),
        patient: PatientLocal(
          localId: 'patient-unicode',
          anonymousId: 'DR-unicode',
          nom: 'Lecœur',
          prenom: 'Élodie',
          dateNaissance: '14/06/1980',
          consentementValide: true,
          dateConsentement: DateTime(2026, 6, 14),
          medecinNom: 'Dr François',
        ),
        practitioner: const PractitionerProfile(
          nom: 'Benoît',
          prenom: 'Chloé',
          adresse: '7 rue de l’Église, 33000 Mérignac',
          adeli: '123456789',
          rpps: '10101010101',
        ),
        date: DateTime(2026, 6, 14),
        lieu: 'Mérignac',
        bodyParagraphsOverride: const [
          'L’objectif est d’assurer une transmission claire : accents, cédille, œ et apostrophe typographique ’ restent compatibles.',
        ],
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}

MedicalLetter _letter({bool withPatient = true}) {
  return MedicalLetter(
    template: medicalLetterTemplates.singleWhere(
      (item) => item.type == MedicalLetterType.generalPractitionerInfo,
    ),
    patient: withPatient ? _patient() : null,
    practitioner: const PractitionerProfile(
      nom: 'Durand',
      prenom: 'Camille',
      adresse: '12 rue de la Santé, 33000 Bordeaux',
      adeli: '123456789',
      rpps: '10101010101',
      profession: 'Masseur-kinésithérapeute',
      signatureBase64: _transparentPngBase64,
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
  );
}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';
