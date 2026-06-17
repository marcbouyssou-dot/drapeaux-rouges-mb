import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes advanced optional patient identification fields', () {
    final patient = PatientLocal(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      nom: 'Dupont',
      prenom: 'Alice',
      dateNaissance: '01/01/1980',
      consentementValide: true,
      dateConsentement: DateTime(2026, 1, 1),
      adresse: '1 rue de la Santé',
      codePostal: '33000',
      ville: 'Bordeaux',
      telephone: '0600000000',
      email: 'alice@example.test',
      profession: 'Enseignante',
      personnePrevenir: 'Bob Dupont',
      telephoneContact: '0611111111',
      medecinNom: 'Dr Martin',
      medecinRpps: '12345678901',
      medecinAdeli: '330000000',
      medecinAdresse: '2 avenue médicale',
      medecinTelephone: '0555000000',
      medecinEmail: 'dr.martin@example.test',
      carteVitalePresentee: true,
      identiteVerifiee: true,
      medicalDocuments: const [
        PatientMedicalDocument(
          type: 'Prescription médicale',
          documentName: 'prescription.png',
          documentBase64: 'base64',
          documentAddedAt: '2026-01-01T10:00:00.000',
        ),
      ],
    );

    final restored = PatientLocal.fromJson(patient.toJson());

    expect(restored.adresse, '1 rue de la Santé');
    expect(restored.codePostal, '33000');
    expect(restored.ville, 'Bordeaux');
    expect(restored.medecinNom, 'Dr Martin');
    expect(restored.carteVitalePresentee, isTrue);
    expect(restored.identiteVerifiee, isTrue);
    expect(restored.medicalDocuments, hasLength(1));
    expect(restored.medicalDocuments.single.type, 'Prescription médicale');
    expect(restored.medicalDocuments.single.hasStoredDocument, isTrue);
  });

  test('keeps legacy patient data compatible', () {
    final restored = PatientLocal.fromJson({
      'localId': 'patient-legacy',
      'anonymousId': 'DR-legacy',
      'nom': 'Durand',
      'prenom': 'Paul',
      'dateNaissance': '02/02/1982',
      'consentementValide': true,
      'dateConsentement': '2026-01-01T00:00:00.000',
    });

    expect(restored.adresse, isEmpty);
    expect(restored.medecinNom, isEmpty);
    expect(restored.carteVitalePresentee, isFalse);
    expect(restored.identiteVerifiee, isFalse);
    expect(restored.medicalDocuments, isEmpty);
  });
}
