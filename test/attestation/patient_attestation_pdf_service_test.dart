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
    final attestation = _attestation(
      patient: _patient(signatureBase64: _transparentPngBase64),
    );
    final bytes = await PatientAttestationPdfService.buildPdfBytes(attestation);

    expect(attestation.template.title, 'Attestation de proximité');
    expect(attestation.bodyParagraphs.single, contains('Cabinet Nord'));
    expect(attestation.bodyParagraphs.single, contains('4 km'));
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test(
    'generates PDF with attestation consent and workflow signature',
    () async {
      final attestation = _attestation(
        patient: _patient(),
        consentConfirmed: true,
        patientSignatureBase64: _transparentPngBase64,
      );
      final bytes = await PatientAttestationPdfService.buildPdfBytes(
        attestation,
      );

      expect(attestation.consentConfirmed, isTrue);
      expect(attestation.hasPatientSignature, isTrue);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    },
  );

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

  test(
    'generates dynamic proximity PDF with cabinets and consent choices',
    () async {
      final attestation = _attestation(
        patient: _patient(),
        consentConfirmed: true,
        transmissionAuthorized: true,
        patientSignatureBase64: _transparentPngBase64,
      );

      final bytes = await PatientAttestationPdfService.buildPdfBytes(
        attestation,
      );

      expect(attestation.patientAddress, '10 rue Patient, 33000 Bordeaux');
      expect(attestation.prescriberName, 'Dr Bernard');
      expect(attestation.transmissionAuthorized, isTrue);
      expect(attestation.filledContactedCabinets, hasLength(1));
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    },
  );

  test('proximity attestation fields remain editable values', () {
    final attestation = _attestation(
      patient: _patient(),
      patientNom: 'Durand',
      patientPrenom: 'Louise',
      distanceHomeOffice: '8 km',
      contactedCabinets: const [
        ContactedCabinet(
          name: 'Cabinet Sud',
          city: 'Talence',
          reason: ContactedCabinetReason.other,
          otherReason: 'organisation incompatible',
        ),
      ],
    );

    expect(attestation.patientFullName, 'DURAND Louise');
    expect(attestation.distanceHomeOffice, '8 km');
    expect(
      attestation.filledContactedCabinets.single.reasonLabel,
      'organisation incompatible',
    );
  });

  test('generates PDF with incomplete practitioner profile', () async {
    final attestation = _attestation(
      practitioner: PractitionerProfile.empty(),
      practitionerNom: '',
      practitionerPrenom: '',
      practitionerIdentifierOverride: '',
      practitionerAddressOverride: '',
    );
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
  bool consentConfirmed = false,
  bool transmissionAuthorized = false,
  String? patientSignatureBase64,
  String patientNom = '',
  String patientPrenom = '',
  String practitionerNom = 'Martin',
  String practitionerPrenom = 'Claire',
  String practitionerIdentifierOverride = 'RPPS : 10101010101',
  String practitionerAddressOverride = '12 rue de la Santé, 33000 Bordeaux',
  String distanceHomeOffice = '4 km',
  List<ContactedCabinet> contactedCabinets = const [
    ContactedCabinet(
      name: 'Cabinet Nord',
      city: 'Bordeaux',
      contactDate: '13/06/2026',
      reason: ContactedCabinetReason.overloaded,
    ),
  ],
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
    consentConfirmed: consentConfirmed,
    transmissionAuthorized: transmissionAuthorized,
    patientSignatureBase64: patientSignatureBase64,
    patientNom: patientNom.isEmpty ? patient?.nom ?? '' : patientNom,
    patientPrenom: patientPrenom.isEmpty
        ? patient?.prenom ?? ''
        : patientPrenom,
    patientDateNaissance: patient?.dateNaissance ?? '',
    patientAdresse: patient?.adresse ?? '',
    patientCodePostal: patient?.codePostal ?? '',
    patientVille: patient?.ville ?? '',
    practitionerNom: practitionerNom,
    practitionerPrenom: practitionerPrenom,
    practitionerIdentifierOverride: practitionerIdentifierOverride,
    practitionerAddressOverride: practitionerAddressOverride,
    distanceHomeOffice: distanceHomeOffice,
    prescriberName: 'Dr Bernard',
    prescriptionDate: '12/06/2026',
    contactedCabinets: contactedCabinets,
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
    adresse: '10 rue Patient',
    codePostal: '33000',
    ville: 'Bordeaux',
    medecinNom: 'Dr Bernard',
    signatureBase64: signatureBase64,
  );
}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';
