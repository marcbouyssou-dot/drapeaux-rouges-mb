import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/models/evaluation_model.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_history_item.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_template.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_type.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prefills medical letter from patient, doctor and evaluation', () {
    final letter = _letter(
      templateType: MedicalLetterType.generalPractitionerInfo,
      evaluation: _evaluation(),
    );

    expect(letter.patientFullName, 'DUPONT Alice');
    expect(letter.treatingDoctorName, 'Dr Martin');
    expect(letter.bodyParagraphs.join(' '), contains('Synthèse clinique'));
    expect(letter.bodyParagraphs.join(' '), contains('Risque élevé'));
  });

  test('keeps anonymous patient compatible', () {
    final letter = _letter(withPatient: false);

    expect(letter.patientFullName, 'Patient non identifié');
    expect(letter.bodyParagraphs.join(' '), contains('Patient non identifié'));
  });

  test('stores final letter text for history regeneration', () {
    final item = MedicalLetterHistoryItem.fromLetter(_letter());
    final restored = MedicalLetterHistoryItem.fromMap({
      ...item.toMap(),
      'bodyParagraphs': ['Texte final historisé.'],
    });

    expect(restored.displayPatient, 'DUPONT Alice');
    expect(restored.toLetter().bodyParagraphs, ['Texte final historisé.']);
  });

  test('keeps legacy history map compatible', () {
    final item = MedicalLetterHistoryItem.fromMap({
      'title': 'Courrier médical',
      'generatedAt': DateTime(2026, 6, 17).toIso8601String(),
    });

    expect(item.displayPatient, 'Patient non identifié');
    expect(item.toLetter().bodyParagraphs, isNotEmpty);
  });
}

MedicalLetter _letter({
  MedicalLetterType templateType = MedicalLetterType.medicalOrientation,
  bool withPatient = true,
  EvaluationModel? evaluation,
}) {
  return MedicalLetter(
    template: medicalLetterTemplates.singleWhere(
      (item) => item.type == templateType,
    ),
    patient: withPatient ? _patient() : null,
    practitioner: _practitioner(),
    date: DateTime(2026, 6, 17),
    lieu: 'Bordeaux',
    evaluation: evaluation,
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
    medecinAdresse: '1 rue médicale, 33000 Bordeaux',
  );
}

PractitionerProfile _practitioner() {
  return const PractitionerProfile(
    nom: 'Durand',
    prenom: 'Camille',
    adresse: '12 rue de la Santé, 33000 Bordeaux',
    adeli: '123456789',
    rpps: '10101010101',
    profession: 'Masseur-kinésithérapeute',
  );
}

EvaluationModel _evaluation() {
  return EvaluationModel(
    evaluationId: 'evaluation-1',
    patientLocalId: 'patient-1',
    patientAnonymousId: null,
    patientDisplayName: 'DUPONT Alice',
    date: DateTime(2026, 6, 17),
    motif: 'Lombalgie',
    score: 6,
    riskLevel: 'Risque élevé',
    checkedCount: 2,
    checkedFlags: const [],
    decisionTitle: 'Avis médical recommandé',
    decisionMessage: 'Orientation médicale à discuter.',
    aiSummary: '',
    clinicalReasoning: ClinicalReasoning(
      id: 'reasoning-1',
      evaluationId: 'evaluation-1',
      patientId: 'patient-1',
      findings: const [],
      alerts: const [],
      recommendations: const [],
      summary: 'Synthèse clinique sauvegardée.',
      severity: ClinicalSeverity.high,
      createdAt: DateTime(2026, 6, 17),
    ),
  );
}
