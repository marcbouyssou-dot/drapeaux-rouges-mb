import 'dart:io';

import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/services/rgpd_local_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'patient_consent_screen_advanced_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox('patients_box');
    await Hive.openBox('settings_box');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('creates and reads advanced patient data locally', () async {
    final patient = advancedPatient();

    await RgpdLocalService.saveOrUpdatePatient(patient);
    final restored = await RgpdLocalService.getPatientByLocalId(
      patient.localId,
    );

    expect(restored, isNotNull);
    expect(restored!.adresse, '12 rue de la Santé');
    expect(restored.codePostal, '33000');
    expect(restored.ville, 'Bordeaux');
    expect(restored.telephone, '0500000000');
    expect(restored.email, 'alice@example.fr');
    expect(restored.profession, 'Enseignante');
    expect(restored.personnePrevenir, 'Bob Dupont');
    expect(restored.telephoneContact, '0600000000');
    expect(restored.medecinNom, 'Dr Martin');
    expect(restored.medecinRpps, '12345678901');
    expect(restored.medecinAdeli, 'ADELI123');
    expect(restored.medecinAdresse, '1 rue médicale');
    expect(restored.medecinTelephone, '0555555555');
    expect(restored.medecinEmail, 'dr.martin@example.fr');
    expect(restored.carteVitalePresentee, isTrue);
    expect(restored.identiteVerifiee, isTrue);
    expect(restored.medicalDocuments.single.documentName, 'ordonnance.png');
  });

  test('updates advanced patient without losing untouched fields', () async {
    final patient = advancedPatient();
    await RgpdLocalService.saveOrUpdatePatient(patient);

    final restored = await RgpdLocalService.getPatientByLocalId(
      patient.localId,
    );

    final updated = PatientLocal(
      localId: restored!.localId,
      anonymousId: restored.anonymousId,
      nom: restored.nom,
      prenom: restored.prenom,
      dateNaissance: restored.dateNaissance,
      consentementValide: restored.consentementValide,
      dateConsentement: restored.dateConsentement,
      signatureBase64: restored.signatureBase64,
      adresse: restored.adresse,
      codePostal: restored.codePostal,
      ville: 'Talence',
      telephone: '0511111111',
      email: restored.email,
      profession: restored.profession,
      personnePrevenir: restored.personnePrevenir,
      telephoneContact: restored.telephoneContact,
      medecinNom: restored.medecinNom,
      medecinRpps: restored.medecinRpps,
      medecinAdeli: restored.medecinAdeli,
      medecinAdresse: restored.medecinAdresse,
      medecinTelephone: restored.medecinTelephone,
      medecinEmail: restored.medecinEmail,
      carteVitalePresentee: restored.carteVitalePresentee,
      identiteVerifiee: restored.identiteVerifiee,
      medicalDocuments: restored.medicalDocuments,
    );

    await RgpdLocalService.saveOrUpdatePatient(updated);
    final saved = await RgpdLocalService.getPatientByLocalId(patient.localId);

    expect(saved!.ville, 'Talence');
    expect(saved.telephone, '0511111111');
    expect(saved.adresse, '12 rue de la Santé');
    expect(saved.medecinNom, 'Dr Martin');
    expect(saved.medecinRpps, '12345678901');
    expect(saved.carteVitalePresentee, isTrue);
    expect(saved.identiteVerifiee, isTrue);
    expect(saved.medicalDocuments.single.documentName, 'ordonnance.png');
    expect(saved.signatureBase64, patient.signatureBase64);
  });

  test('patient screen reinjects advanced fields into controllers', () {
    final source = File(
      'lib/screens/patient_consent_screen.dart',
    ).readAsStringSync();

    expect(source, contains('void populateFormFromPatient'));
    expect(source, contains('adresseController.text = patient.adresse'));
    expect(source, contains('codePostalController.text = patient.codePostal'));
    expect(source, contains('villeController.text = patient.ville'));
    expect(source, contains('telephoneController.text = patient.telephone'));
    expect(source, contains('emailController.text = patient.email'));
    expect(source, contains('professionController.text = patient.profession'));
    expect(
      source,
      contains('personnePrevenirController.text = patient.personnePrevenir'),
    );
    expect(
      source,
      contains('telephoneContactController.text = patient.telephoneContact'),
    );
    expect(source, contains('medecinNomController.text = patient.medecinNom'));
    expect(
      source,
      contains('medecinRppsController.text = patient.medecinRpps'),
    );
    expect(
      source,
      contains('medecinAdeliController.text = patient.medecinAdeli'),
    );
    expect(
      source,
      contains('medecinAdresseController.text = patient.medecinAdresse'),
    );
    expect(
      source,
      contains('medecinTelephoneController.text = patient.medecinTelephone'),
    );
    expect(
      source,
      contains('medecinEmailController.text = patient.medecinEmail'),
    );
    expect(source, contains('carteVitalePresentee = patient'));
    expect(source, contains('identiteVerifiee = patient'));
    expect(source, contains('patient.medicalDocuments'));
  });

  test('patient screen preserves existing signature on partial update', () {
    final source = File(
      'lib/screens/patient_consent_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Future<void> saveExistingPatient'));
    expect(source, contains('signatureBytes == null'));
    expect(source, contains('patient.signatureBase64'));
    expect(source, contains('medicalDocuments: medicalDocuments'));
  });

  test(
    'anonymous mode remains available without advanced patient data',
    () async {
      await RgpdLocalService.clearCurrentPatient();

      expect(await RgpdLocalService.getCurrentPatient(), isNull);
    },
  );
}

PatientLocal advancedPatient() {
  return PatientLocal(
    localId: 'patient-advanced-1',
    anonymousId: 'DR-patient-advanced-1',
    nom: 'Dupont',
    prenom: 'Alice',
    dateNaissance: '01/01/1980',
    consentementValide: true,
    dateConsentement: DateTime(2026, 1, 1),
    signatureBase64: 'signature-base64',
    adresse: '12 rue de la Santé',
    codePostal: '33000',
    ville: 'Bordeaux',
    telephone: '0500000000',
    email: 'alice@example.fr',
    profession: 'Enseignante',
    personnePrevenir: 'Bob Dupont',
    telephoneContact: '0600000000',
    medecinNom: 'Dr Martin',
    medecinRpps: '12345678901',
    medecinAdeli: 'ADELI123',
    medecinAdresse: '1 rue médicale',
    medecinTelephone: '0555555555',
    medecinEmail: 'dr.martin@example.fr',
    carteVitalePresentee: true,
    identiteVerifiee: true,
    medicalDocuments: const [
      PatientMedicalDocument(
        type: 'Prescription médicale',
        documentName: 'ordonnance.png',
        documentBase64: 'document-base64',
        documentAddedAt: '2026-06-17T10:00:00.000',
      ),
    ],
  );
}
