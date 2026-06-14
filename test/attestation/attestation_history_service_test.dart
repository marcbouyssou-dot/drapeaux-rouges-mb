import 'dart:io';

import 'package:drapeaux_rouges_mb/models/attestation/attestation_history_item.dart';
import 'package:drapeaux_rouges_mb/models/attestation/attestation_template.dart';
import 'package:drapeaux_rouges_mb/models/attestation/attestation_type.dart';
import 'package:drapeaux_rouges_mb/models/attestation/patient_attestation.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:drapeaux_rouges_mb/services/attestation_history_service.dart';
import 'package:drapeaux_rouges_mb/services/patient_attestation_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'attestation_history_service_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox(AttestationHistoryService.boxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('returns empty history when no attestation was saved', () async {
    final attestations = await AttestationHistoryService.getAttestations();

    expect(attestations, isEmpty);
  });

  test('saves and reads generated attestation history', () async {
    final item = AttestationHistoryItem.fromAttestation(_attestation());

    await AttestationHistoryService.saveAttestation(item);

    final saved = await AttestationHistoryService.getAttestations();

    expect(saved, hasLength(1));
    expect(saved.single.title, 'MK le plus proche disponible');
    expect(saved.single.displayPatient, 'DUPONT Alice');
    expect(saved.single.hasSignature, isFalse);
    expect(saved.single.bodyParagraphs, isNotEmpty);
  });

  test('keeps anonymous patient compatible', () {
    final item = AttestationHistoryItem.fromAttestation(
      _attestation(withPatient: false),
    );

    expect(item.displayPatient, 'Patient non identifié');
    expect(item.patientLocal, isNull);
  });

  test('stores absence of signature without crashing', () {
    final item = AttestationHistoryItem.fromAttestation(_attestation());

    expect(item.hasSignature, isFalse);
    expect(item.signatureStatus, 'Signature absente');
  });

  test('regenerates PDF from history data', () async {
    final item = AttestationHistoryItem.fromAttestation(_attestation());
    final bytes = await PatientAttestationPdfService.buildPdfBytes(
      item.toAttestation(),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('keeps final text for future PDF regeneration', () {
    final item = AttestationHistoryItem.fromAttestation(_attestation());
    final restored = AttestationHistoryItem.fromMap({
      ...item.toMap(),
      'bodyParagraphs': ['Texte historisé final.'],
    });

    expect(restored.toAttestation().bodyParagraphs, ['Texte historisé final.']);
  });
}

PatientAttestation _attestationWithPatient(PatientLocal? patient) {
  return PatientAttestation(
    template: attestationTemplates.singleWhere(
      (item) => item.type == AttestationType.nearestAvailableMk,
    ),
    patient: patient,
    practitioner: const PractitionerProfile(
      nom: 'Martin',
      prenom: 'Claire',
      adresse: '12 rue de la Santé, 33000 Bordeaux',
      adeli: '123456789',
      rpps: '10101010101',
    ),
    date: DateTime(2026, 6, 14),
    lieu: 'Bordeaux',
  );
}

PatientAttestation _attestation({bool withPatient = true}) {
  return _attestationWithPatient(withPatient ? _patient() : null);
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
  );
}
