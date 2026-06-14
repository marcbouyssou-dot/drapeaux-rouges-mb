import 'package:drapeaux_rouges_mb/models/attestation/attestation_template.dart';
import 'package:drapeaux_rouges_mb/models/attestation/attestation_type.dart';
import 'package:drapeaux_rouges_mb/models/attestation/patient_attestation.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:drapeaux_rouges_mb/services/patient_attestation_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates PDF with complete patient', () async {
    final bytes = await PatientAttestationPdfService.buildPdfBytes(
      _attestation(patient: _patient(signatureBase64: _transparentPngBase64)),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('generates PDF without patient signature', () async {
    final bytes = await PatientAttestationPdfService.buildPdfBytes(
      _attestation(patient: _patient()),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('generates PDF with anonymous patient', () async {
    final attestation = _attestation(patient: null);
    final bytes = await PatientAttestationPdfService.buildPdfBytes(attestation);

    expect(attestation.patientFullName, 'Patient non identifié');
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('generates PDF with incomplete practitioner profile', () async {
    final attestation = _attestation(practitioner: PractitionerProfile.empty());
    final bytes = await PatientAttestationPdfService.buildPdfBytes(attestation);

    expect(
      attestation.practitionerFullName,
      'Masseur-kinésithérapeute non renseigné',
    );
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('generates PDF with French accents and typographic apostrophe', () async {
    final bytes = await PatientAttestationPdfService.buildPdfBytes(
      PatientAttestation(
        template: attestationTemplates.singleWhere(
          (item) => item.type == AttestationType.reinforcedConsent,
        ),
        patient: PatientLocal(
          localId: 'patient-unicode',
          anonymousId: 'DR-unicode',
          nom: 'Lecœur',
          prenom: 'Élodie',
          dateNaissance: '14/06/1980',
          consentementValide: true,
          dateConsentement: DateTime(2026, 6, 14),
        ),
        practitioner: const PractitionerProfile(
          nom: 'François',
          prenom: 'Chloé',
          adresse: '7 rue de l’Église, 33000 Mérignac',
          adeli: '123456789',
          rpps: '10101010101',
        ),
        date: DateTime(2026, 6, 14),
        lieu: 'Mérignac',
        bodyParagraphsOverride: const [
          'L’objectif est d’éviter toute ambiguïté : accents, cédille, œ et apostrophe typographique ’ doivent rester compatibles.',
        ],
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}

PatientAttestation _attestation({
  PatientLocal? patient,
  PractitionerProfile? practitioner,
}) {
  return PatientAttestation(
    template: attestationTemplates.singleWhere(
      (item) => item.type == AttestationType.nearestAvailableMk,
    ),
    patient: patient,
    practitioner:
        practitioner ??
        const PractitionerProfile(
          nom: 'Martin',
          prenom: 'Claire',
          adresse: '12 rue de la Santé, 33000 Bordeaux',
          adeli: '123456789',
          rpps: '10101010101',
          profession: 'Masseur-kinésithérapeute',
          email: 'claire.martin@example.fr',
          telephone: '0500000000',
        ),
    date: DateTime(2026, 6, 14),
    lieu: 'Bordeaux',
  );
}

PatientLocal _patient({String? signatureBase64}) {
  return PatientLocal(
    localId: 'patient-1',
    anonymousId: 'DR-patient-1',
    nom: 'Dupont',
    prenom: 'Alice',
    dateNaissance: '01/01/1980',
    consentementValide: true,
    dateConsentement: DateTime(2026, 1, 1),
    signatureBase64: signatureBase64,
  );
}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';
