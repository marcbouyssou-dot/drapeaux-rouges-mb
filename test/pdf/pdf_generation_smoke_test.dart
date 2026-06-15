import 'dart:io';
import 'dart:typed_data';

import 'package:drapeaux_rouges_mb/models/attestation/attestation_template.dart';
import 'package:drapeaux_rouges_mb/models/attestation/attestation_type.dart';
import 'package:drapeaux_rouges_mb/models/attestation/patient_attestation.dart';
import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:drapeaux_rouges_mb/services/bdk_pdf_service.dart';
import 'package:drapeaux_rouges_mb/services/patient_attestation_pdf_service.dart';
import 'package:drapeaux_rouges_mb/services/pdf_service.dart';
import 'package:drapeaux_rouges_mb/services/prescription_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'attestation PDF smoke supports complete and anonymous patients',
    () async {
      final complete = await PatientAttestationPdfService.buildPdfBytes(
        _attestation(patient: _patient()),
      );
      final anonymous = await PatientAttestationPdfService.buildPdfBytes(
        _attestation(patient: null),
      );

      _expectPdfBytes(complete);
      _expectPdfBytes(anonymous);
      expect(complete.length, greaterThan(anonymous.length ~/ 2));
    },
  );

  test('prescription PDF smoke supports French medical text', () async {
    final bytes = await PrescriptionPdfService.buildPrescriptionPdfBytes(
      patient: _patient(),
      practitioner: _practitioner(),
      prescriptionType: 'Rééducation',
      prescriptionContent:
          'Rééducation à domicile : mobilité, contrôle de la douleur, œdème, cédille et apostrophe typographique ’.',
    );

    _expectPdfBytes(bytes);
  });

  test('BDK PDF smoke supports practitioner and French text', () async {
    final bytes = await BdkPdfService.buildBdkPdfBytes(
      title: 'BDK Cervicalgie',
      patient: _patient(),
      motif: 'Cervicalgie aiguë',
      contexte: 'Douleur à l’effort, gêne fonctionnelle.',
      antecedents: 'Antécédents non renseignés.',
      evaluation: 'Évaluation clinique structurée.',
      tests: 'Tests fonctionnels réalisés.',
      limitations: 'Limitation à la rotation.',
      diagnostic: 'Diagnostic kinésithérapique prudent.',
      vigilance: 'Surveillance des signes d’alerte.',
      objectifs: 'Récupération progressive.',
      planTraitement: 'Exercices, conseils, éducation.',
      criteresReevaluation: 'Réévaluation à 7 jours.',
      syntheseClinique: 'Synthèse avec accents : é, è, à, ç, œ, ’.',
      practitioner: _practitioner(),
    );

    _expectPdfBytes(bytes);
  });

  test('evaluation PDF smoke supports clinical reasoning', () async {
    final bytes = await PdfService.buildPdfBytes(
      categories: {
        'Respiratoire': [
          {
            'checked': true,
            'title': 'Dyspnée inhabituelle',
            'severity': 'élevé',
          },
        ],
      },
      score: 7,
      checkedCount: 1,
      riskLevel: 'Risque élevé',
      patientCode: 'DR-évaluation',
      motif: 'Évaluation respiratoire',
      decisionTitle: 'Orientation médicale recommandée',
      decisionMessage: 'Tableau clinique à valider par le praticien.',
      aiSummary: 'Synthèse clinique avec é, è, à, ç, œ et ’.',
      clinicalReasoning: _clinicalReasoning(),
      practitioner: _practitioner(),
    );

    _expectPdfBytes(bytes);
  });

  test('PDF services use local font helper without runtime GoogleFonts', () {
    final serviceSources = [
      File('lib/services/pdf_service.dart').readAsStringSync(),
      File('lib/services/bdk_pdf_service.dart').readAsStringSync(),
      File('lib/services/prescription_pdf_service.dart').readAsStringSync(),
      File(
        'lib/services/patient_attestation_pdf_service.dart',
      ).readAsStringSync(),
    ].join('\n');

    expect(serviceSources, contains('PdfFontHelper.unicodeTheme'));
    expect(serviceSources, isNot(contains('PdfGoogleFonts')));
    expect(serviceSources, isNot(contains('Font.helvetica')));
    expect(serviceSources, isNot(contains('pw.Font.helvetica')));
  });
}

void _expectPdfBytes(Uint8List bytes) {
  expect(bytes, isNotEmpty);
  expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  expect(bytes.length, greaterThan(1500));
}

PatientAttestation _attestation({required PatientLocal? patient}) {
  return PatientAttestation(
    template: attestationTemplates.singleWhere(
      (item) => item.type == AttestationType.nearestAvailableMk,
    ),
    patient: patient,
    practitioner: _practitioner(),
    date: DateTime(2026, 6, 15),
    lieu: 'Mérignac',
    bodyParagraphsOverride: const [
      'Je soussigné(e), patient, atteste d’une information claire avec accents français : é, è, à, ç, œ et apostrophe ’.',
    ],
  );
}

PatientLocal _patient() {
  return PatientLocal(
    localId: 'patient-pdf',
    anonymousId: 'DR-pdf',
    nom: 'Lecœur',
    prenom: 'Élodie',
    dateNaissance: '15/06/1980',
    consentementValide: true,
    dateConsentement: DateTime(2026, 6, 15),
  );
}

PractitionerProfile _practitioner() {
  return const PractitionerProfile(
    nom: 'François',
    prenom: 'Chloé',
    adresse: '7 rue de l’Église, 33000 Mérignac',
    adeli: '123456789',
    rpps: '10101010101',
    profession: 'Masseur-kinésithérapeute',
    email: 'chloe.francois@example.fr',
    telephone: '0500000000',
  );
}

ClinicalReasoning _clinicalReasoning() {
  return ClinicalReasoning(
    id: 'reasoning-smoke',
    evaluationId: 'evaluation-smoke',
    patientId: 'patient-pdf',
    findings: [
      ClinicalFinding(
        id: 'finding-smoke',
        label: 'Dyspnée inhabituelle',
        category: ClinicalFindingCategory.respiratory,
        severity: ClinicalSeverity.high,
        source: ClinicalSource.evaluation,
        createdAt: DateTime(2026, 6, 15),
      ),
    ],
    alerts: [
      ClinicalAlert(
        id: 'alert-smoke',
        title: 'Vigilance clinique',
        message: 'Alerte à valider par le praticien.',
        level: ClinicalAlertLevel.warning,
        relatedFindingIds: const ['finding-smoke'],
        createdAt: DateTime(2026, 6, 15),
      ),
    ],
    recommendations: [
      ClinicalRecommendation(
        id: 'recommendation-smoke',
        title: 'Validation clinique',
        description: 'Orientation à discuter selon l’évolution.',
        priority: ClinicalRecommendationPriority.high,
        actionType: ClinicalActionType.refer,
        createdAt: DateTime(2026, 6, 15),
      ),
    ],
    summary: 'Synthèse Clinical Reasoning sauvegardée.',
    createdAt: DateTime(2026, 6, 15),
  );
}
