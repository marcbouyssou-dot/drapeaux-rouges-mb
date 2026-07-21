import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_patient_context.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadarPatientContext', () {
    test(
      'adapts the historical patient display name without technical data',
      () {
        final patient = _patient(
          localId: 'local-patient-id',
          anonymousId: 'DR-technical-id',
          nom: 'Durand',
          prenom: 'Alice',
          dateNaissance: '12/03/1981',
        );

        final context = RadarPatientContext.fromPatient(patient);

        expect(context.isAssociated, isTrue);
        expect(context.primaryLabel, 'DURAND Alice');
        expect(context.secondaryLabel, 'Consultation en cours');
        expect(context.displayedValues, isNot(contains('local-patient-id')));
        expect(context.displayedValues, isNot(contains('DR-technical-id')));
        expect(context.displayedValues, isNot(contains('12/03/1981')));
        expect(context.displayedValues, isNot(contains('adresse sensible')));
        expect(context.displayedValues, isNot(contains('0600000000')));
      },
    );

    test('uses a stable anonymous state when no patient is associated', () {
      final context = RadarPatientContext.fromPatient(null);

      expect(context.isAssociated, isFalse);
      expect(context.primaryLabel, 'Consultation en cours');
      expect(context.secondaryLabel, 'Patient non associé');
    });

    test('keeps the historical fallback for partial identity data', () {
      final context = RadarPatientContext.fromPatient(
        _patient(nom: '', prenom: '', dateNaissance: ''),
      );

      expect(context.isAssociated, isTrue);
      expect(context.primaryLabel, 'Patient non renseigné');
      expect(context.secondaryLabel, 'Consultation en cours');
    });
  });
}

PatientLocal _patient({
  String localId = 'local-id',
  String anonymousId = 'DR-anonymous',
  required String nom,
  required String prenom,
  required String dateNaissance,
}) {
  return PatientLocal(
    localId: localId,
    anonymousId: anonymousId,
    nom: nom,
    prenom: prenom,
    dateNaissance: dateNaissance,
    consentementValide: true,
    dateConsentement: DateTime(2026),
    adresse: 'adresse sensible',
    telephone: '0600000000',
    email: 'patient@example.test',
  );
}
