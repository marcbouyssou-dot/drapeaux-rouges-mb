import 'dart:io';

import 'package:drapeaux_rouges_mb/models/attestation/attestation_history_item.dart';
import 'package:drapeaux_rouges_mb/models/medical_letter/medical_letter_history_item.dart';
import 'package:drapeaux_rouges_mb/models/prescription_model.dart';
import 'package:drapeaux_rouges_mb/services/attestation_history_service.dart';
import 'package:drapeaux_rouges_mb/services/medical_letter_history_service.dart';
import 'package:drapeaux_rouges_mb/services/prescription_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'document_history_hardening_test_',
    );
    Hive.init(tempDir.path);
    await Future.wait([
      Hive.openBox('prescriptions_box'),
      Hive.openBox(MedicalLetterHistoryService.boxName),
      Hive.openBox(AttestationHistoryService.boxName),
    ]);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('schema versions and dates', () {
    test('reads compatible unversioned historical entries', () async {
      await Hive.box('prescriptions_box').put('prescriptions_history', [
        _withoutSchemaVersion(_prescription('prescription-legacy').toMap()),
      ]);
      await Hive.box(MedicalLetterHistoryService.boxName).put(
        'medical_letters_history',
        [_withoutSchemaVersion(_letter('letter-legacy').toMap())],
      );
      await Hive.box(AttestationHistoryService.boxName).put(
        'attestations_history',
        [_withoutSchemaVersion(_attestation('attestation-legacy').toMap())],
      );

      expect(
        (await PrescriptionService.getPrescriptions()).single.id,
        'prescription-legacy',
      );
      expect(
        (await MedicalLetterHistoryService.getLetters()).single.id,
        'letter-legacy',
      );
      expect(
        (await AttestationHistoryService.getAttestations()).single.id,
        'attestation-legacy',
      );
    });

    test('ignores future schema versions without crashing', () async {
      await Hive.box('prescriptions_box').put('prescriptions_history', [
        {..._prescription('prescription-future').toMap(), 'schemaVersion': 999},
      ]);
      await Hive.box(MedicalLetterHistoryService.boxName).put(
        'medical_letters_history',
        [
          {..._letter('letter-future').toMap(), 'schemaVersion': 999},
        ],
      );
      await Hive.box(AttestationHistoryService.boxName).put(
        'attestations_history',
        [
          {..._attestation('attestation-future').toMap(), 'schemaVersion': 999},
        ],
      );

      expect(await PrescriptionService.getPrescriptions(), isEmpty);
      expect(await MedicalLetterHistoryService.getLetters(), isEmpty);
      expect(await AttestationHistoryService.getAttestations(), isEmpty);
    });

    test('rejects invalid dates instead of replacing them with now', () async {
      await Hive.box('prescriptions_box').put('prescriptions_history', [
        {..._prescription('prescription-invalid').toMap(), 'createdAt': 'bad'},
      ]);
      await Hive.box(MedicalLetterHistoryService.boxName).put(
        'medical_letters_history',
        [
          {..._letter('letter-invalid').toMap(), 'generatedAt': 'bad'},
        ],
      );
      await Hive.box(
        AttestationHistoryService.boxName,
      ).put('attestations_history', [
        {..._attestation('attestation-invalid').toMap(), 'generatedAt': 'bad'},
      ]);

      expect(await PrescriptionService.getPrescriptions(), isEmpty);
      expect(await MedicalLetterHistoryService.getLetters(), isEmpty);
      expect(await AttestationHistoryService.getAttestations(), isEmpty);
    });
  });

  group('serialized mutations', () {
    test('keeps two concurrent additions in every history', () async {
      await Future.wait([
        PrescriptionService.savePrescription(_prescription('prescription-1')),
        PrescriptionService.savePrescription(_prescription('prescription-2')),
        MedicalLetterHistoryService.saveLetter(_letter('letter-1')),
        MedicalLetterHistoryService.saveLetter(_letter('letter-2')),
        AttestationHistoryService.saveAttestation(
          _attestation('attestation-1'),
        ),
        AttestationHistoryService.saveAttestation(
          _attestation('attestation-2'),
        ),
      ]);

      expect(await PrescriptionService.getPrescriptions(), hasLength(2));
      expect(await MedicalLetterHistoryService.getLetters(), hasLength(2));
      expect(await AttestationHistoryService.getAttestations(), hasLength(2));
    });

    test('orders a concurrent addition followed by deletion', () async {
      await Future.wait([
        PrescriptionService.savePrescription(_prescription('prescription-1')),
        PrescriptionService.savePrescription(_prescription('prescription-2')),
        MedicalLetterHistoryService.saveLetter(_letter('letter-1')),
        MedicalLetterHistoryService.saveLetter(_letter('letter-2')),
        AttestationHistoryService.saveAttestation(
          _attestation('attestation-1'),
        ),
        AttestationHistoryService.saveAttestation(
          _attestation('attestation-2'),
        ),
      ]);

      await Future.wait([
        PrescriptionService.savePrescription(_prescription('prescription-3')),
        PrescriptionService.deleteById('prescription-1'),
        MedicalLetterHistoryService.saveLetter(_letter('letter-3')),
        MedicalLetterHistoryService.deleteById('letter-1'),
        AttestationHistoryService.saveAttestation(
          _attestation('attestation-3'),
        ),
        AttestationHistoryService.deleteById('attestation-1'),
      ]);

      final prescriptions = await PrescriptionService.getPrescriptions();
      final letters = await MedicalLetterHistoryService.getLetters();
      final attestations = await AttestationHistoryService.getAttestations();
      expect(
        prescriptions.map((item) => item.id),
        containsAll(['prescription-2', 'prescription-3']),
      );
      expect(
        prescriptions.map((item) => item.id),
        isNot(contains('prescription-1')),
      );
      expect(
        letters.map((item) => item.id),
        containsAll(['letter-2', 'letter-3']),
      );
      expect(letters.map((item) => item.id), isNot(contains('letter-1')));
      expect(
        attestations.map((item) => item.id),
        containsAll(['attestation-2', 'attestation-3']),
      );
      expect(
        attestations.map((item) => item.id),
        isNot(contains('attestation-1')),
      );
    });
  });

  test('complete purges remove unknown keys from every box', () async {
    await Hive.box('prescriptions_box').put('historical_unknown_key', true);
    await Hive.box(
      MedicalLetterHistoryService.boxName,
    ).put('historical_unknown_key', true);
    await Hive.box(
      AttestationHistoryService.boxName,
    ).put('historical_unknown_key', true);

    await Future.wait([
      PrescriptionService.clearPrescriptions(),
      MedicalLetterHistoryService.clearLetters(),
      AttestationHistoryService.clearAttestations(),
    ]);

    expect(Hive.box('prescriptions_box').isEmpty, isTrue);
    expect(Hive.box(MedicalLetterHistoryService.boxName).isEmpty, isTrue);
    expect(Hive.box(AttestationHistoryService.boxName).isEmpty, isTrue);
  });

  test('targeted patient deletion preserves other patients', () async {
    await Future.wait([
      PrescriptionService.savePrescription(_prescription('p-a')),
      PrescriptionService.savePrescription(
        _prescription('p-b', patientLocalId: 'patient-b'),
      ),
      MedicalLetterHistoryService.saveLetter(_letter('l-a')),
      MedicalLetterHistoryService.saveLetter(
        _letter('l-b', patientLocalId: 'patient-b'),
      ),
      AttestationHistoryService.saveAttestation(_attestation('a-a')),
      AttestationHistoryService.saveAttestation(
        _attestation('a-b', patientLocalId: 'patient-b'),
      ),
    ]);

    await Future.wait([
      PrescriptionService.deleteForPatient('patient-a', ''),
      MedicalLetterHistoryService.deleteForPatient('patient-a', ''),
      AttestationHistoryService.deleteForPatient('patient-a', ''),
    ]);

    expect(
      (await PrescriptionService.getPrescriptions()).single.patientLocalId,
      'patient-b',
    );
    expect(
      (await MedicalLetterHistoryService.getLetters()).single.patientLocalId,
      'patient-b',
    );
    expect(
      (await AttestationHistoryService.getAttestations()).single.patientLocalId,
      'patient-b',
    );
  });
}

Map<String, dynamic> _withoutSchemaVersion(Map<String, dynamic> map) {
  return Map<String, dynamic>.from(map)..remove('schemaVersion');
}

PrescriptionModel _prescription(
  String id, {
  String patientLocalId = 'patient-a',
}) {
  return PrescriptionModel(
    id: id,
    professional: 'Praticien',
    patient: 'Patient',
    patientLocalId: patientLocalId,
    clinicalContext: 'Contexte',
    prescription: 'Prescription',
    frequency: '',
    duration: '',
    nomenclature: '',
    createdAt: DateTime(2025, 1, 1),
  );
}

MedicalLetterHistoryItem _letter(
  String id, {
  String patientLocalId = 'patient-a',
}) {
  return MedicalLetterHistoryItem(
    id: id,
    typeId: 'orientation',
    title: 'Courrier',
    pdfTitle: 'COURRIER',
    generatedAt: DateTime(2025, 1, 2),
    patientLocalId: patientLocalId,
    patientAnonymousId: '',
    patientNom: 'Patient',
    patientPrenom: 'Test',
    patientDateNaissance: '',
    patientMedecinNom: '',
    patientMedecinRpps: '',
    patientMedecinAdeli: '',
    patientMedecinAdresse: '',
    patientMedecinTelephone: '',
    patientMedecinEmail: '',
    practitionerProfile: const {},
    lieu: '',
    subject: '',
    bodyParagraphs: const [],
    evaluationSnapshot: const {},
    hasPractitionerSignature: false,
  );
}

AttestationHistoryItem _attestation(
  String id, {
  String patientLocalId = 'patient-a',
}) {
  return AttestationHistoryItem(
    id: id,
    typeId: 'presence',
    title: 'Attestation',
    pdfTitle: 'ATTESTATION',
    generatedAt: DateTime(2025, 1, 3),
    patientLocalId: patientLocalId,
    patientAnonymousId: '',
    patientNom: 'Patient',
    patientPrenom: 'Test',
    patientDateNaissance: '',
    practitionerProfile: const {},
    lieu: '',
    hasSignature: false,
    signatureBase64: '',
    consentConfirmed: false,
    bodyParagraphs: const [],
  );
}
