import '../patient_local.dart';
import '../practitioner_profile.dart';
import 'attestation_template.dart';
import 'attestation_type.dart';

class PatientAttestation {
  const PatientAttestation({
    required this.template,
    required this.patient,
    required this.practitioner,
    required this.date,
    required this.lieu,
  });

  final AttestationTemplate template;
  final PatientLocal? patient;
  final PractitionerProfile practitioner;
  final DateTime date;
  final String lieu;

  String get patientFullName {
    if (patient == null) return 'Patient non identifié';

    final nom = patient!.nom.trim().toUpperCase();
    final prenom = patient!.prenom.trim();
    final value = '$nom $prenom'.trim();

    return value.isEmpty ? 'Patient non identifié' : value;
  }

  String get patientBirthDate {
    final value = patient?.dateNaissance.trim() ?? '';
    return value.isEmpty ? '' : value;
  }

  String get practitionerFullName {
    final value = practitioner.fullName.trim();
    return value.isEmpty ? 'Masseur-kinésithérapeute non renseigné' : value;
  }

  String get practitionerAddress => practitioner.adresse.trim();

  String get practitionerIdentifier {
    final rpps = practitioner.rpps.trim();
    final adeli = practitioner.adeli.trim();

    if (rpps.isNotEmpty && adeli.isNotEmpty) {
      return 'RPPS : $rpps · ADELI : $adeli';
    }
    if (rpps.isNotEmpty) return 'RPPS : $rpps';
    if (adeli.isNotEmpty) return 'ADELI : $adeli';

    return '';
  }

  String get signatureBase64 => patient?.signatureBase64?.trim() ?? '';

  bool get hasPatientSignature => signatureBase64.isNotEmpty;

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String get effectiveCity {
    final value = lieu.trim();
    return value.isEmpty ? '' : value;
  }

  List<String> get bodyParagraphs {
    switch (template.type) {
      case AttestationType.nearestAvailableMk:
        return [
          'Je soussigné(e), $patientFullName,',
          'né(e) le $patientBirthDate,',
          'certifie avoir sollicité pour ma prise en charge à domicile :',
          practitionerFullName,
          if (practitionerAddress.isNotEmpty) practitionerAddress,
          if (practitionerIdentifier.isNotEmpty) practitionerIdentifier,
          'J’atteste que ce professionnel de santé est, à ma connaissance, le masseur-kinésithérapeute disponible le plus proche de mon domicile pour assurer les soins prescrits.',
          'Je reconnais avoir demandé cette prise en charge de ma propre initiative et certifie l’exactitude des informations communiquées.',
        ];

      case AttestationType.refusedMedicalOrientation:
        return [
          'Je soussigné(e), $patientFullName,',
          'né(e) le $patientBirthDate,',
          'reconnais avoir été informé(e) par $practitionerFullName de la nécessité ou de l’intérêt d’une orientation médicale.',
          'Malgré cette information, je déclare ne pas souhaiter donner suite à cette orientation à ce jour.',
          'Je reconnais avoir reçu une information claire sur les risques potentiels liés à l’absence d’avis médical complémentaire.',
        ];

      case AttestationType.reinforcedConsent:
        return [
          'Je soussigné(e), $patientFullName,',
          'né(e) le $patientBirthDate,',
          'certifie avoir reçu une information claire concernant ma prise en charge, ses objectifs, ses limites et les éventuelles situations nécessitant un avis médical.',
          'Je reconnais avoir pu poser mes questions et avoir compris les informations qui m’ont été transmises.',
        ];

      case AttestationType.directAccessCare:
        return [
          'Je soussigné(e), $patientFullName,',
          'né(e) le $patientBirthDate,',
          'certifie solliciter une prise en charge en accès direct auprès de :',
          practitionerFullName,
          if (practitionerAddress.isNotEmpty) practitionerAddress,
          if (practitionerIdentifier.isNotEmpty) practitionerIdentifier,
          'Je reconnais avoir été informé(e) que cette prise en charge ne remplace pas un avis médical lorsque celui-ci est nécessaire.',
        ];
    }
  }
}
