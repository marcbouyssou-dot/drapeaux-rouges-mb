import '../patient_local.dart';
import '../practitioner_profile.dart';
import 'attestation_template.dart';
import 'attestation_type.dart';

enum ContactedCabinetReason {
  noResponse,
  overloaded,
  noHomeCare,
  delayTooLong,
  other,
}

extension ContactedCabinetReasonLabel on ContactedCabinetReason {
  String get label {
    switch (this) {
      case ContactedCabinetReason.noResponse:
        return 'pas de réponse';
      case ContactedCabinetReason.overloaded:
        return 'surcharge';
      case ContactedCabinetReason.noHomeCare:
        return 'ne réalise pas les soins à domicile';
      case ContactedCabinetReason.delayTooLong:
        return 'délai trop important';
      case ContactedCabinetReason.other:
        return 'autre';
    }
  }

  String get id {
    switch (this) {
      case ContactedCabinetReason.noResponse:
        return 'noResponse';
      case ContactedCabinetReason.overloaded:
        return 'overloaded';
      case ContactedCabinetReason.noHomeCare:
        return 'noHomeCare';
      case ContactedCabinetReason.delayTooLong:
        return 'delayTooLong';
      case ContactedCabinetReason.other:
        return 'other';
    }
  }
}

ContactedCabinetReason contactedCabinetReasonById(String id) {
  return ContactedCabinetReason.values.firstWhere(
    (reason) => reason.id == id,
    orElse: () => ContactedCabinetReason.noResponse,
  );
}

class ContactedCabinet {
  const ContactedCabinet({
    this.name = '',
    this.city = '',
    this.contactDate = '',
    this.reason,
    this.otherReason = '',
  });

  final String name;
  final String city;
  final String contactDate;
  final ContactedCabinetReason? reason;
  final String otherReason;

  bool get hasData {
    return name.trim().isNotEmpty ||
        city.trim().isNotEmpty ||
        contactDate.trim().isNotEmpty ||
        reason != null ||
        otherReason.trim().isNotEmpty;
  }

  String get reasonLabel {
    if (reason == ContactedCabinetReason.other) {
      final value = otherReason.trim();
      return value.isEmpty ? ContactedCabinetReason.other.label : value;
    }

    return reason?.label ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'contactDate': contactDate,
      'reason': reason?.id,
      'otherReason': otherReason,
    };
  }

  factory ContactedCabinet.fromJson(Map<String, dynamic> json) {
    final reasonId = json['reason']?.toString() ?? '';

    return ContactedCabinet(
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      contactDate: json['contactDate']?.toString() ?? '',
      reason: reasonId.isEmpty ? null : contactedCabinetReasonById(reasonId),
      otherReason: json['otherReason']?.toString() ?? '',
    );
  }
}

class PatientAttestation {
  const PatientAttestation({
    required this.template,
    required this.patient,
    required this.practitioner,
    required this.date,
    required this.lieu,
    this.bodyParagraphsOverride = const [],
    this.consentConfirmed = false,
    this.transmissionAuthorized = false,
    this.patientSignatureBase64,
    this.patientNom = '',
    this.patientPrenom = '',
    this.patientDateNaissance = '',
    this.patientAdresse = '',
    this.patientCodePostal = '',
    this.patientVille = '',
    this.practitionerNom = '',
    this.practitionerPrenom = '',
    this.practitionerIdentifierOverride = '',
    this.practitionerAddressOverride = '',
    this.distanceHomeOffice = '',
    this.prescriberName = '',
    this.prescriptionDate = '',
    this.contactedCabinets = const [],
  });

  final AttestationTemplate template;
  final PatientLocal? patient;
  final PractitionerProfile practitioner;
  final DateTime date;
  final String lieu;
  final List<String> bodyParagraphsOverride;
  final bool consentConfirmed;
  final bool transmissionAuthorized;
  final String? patientSignatureBase64;
  final String patientNom;
  final String patientPrenom;
  final String patientDateNaissance;
  final String patientAdresse;
  final String patientCodePostal;
  final String patientVille;
  final String practitionerNom;
  final String practitionerPrenom;
  final String practitionerIdentifierOverride;
  final String practitionerAddressOverride;
  final String distanceHomeOffice;
  final String prescriberName;
  final String prescriptionDate;
  final List<ContactedCabinet> contactedCabinets;

  String get patientFullName {
    final override =
        '${patientNom.trim().toUpperCase()} ${patientPrenom.trim()}'.trim();
    if (override.isNotEmpty) return override;
    if (patient == null) return 'Patient non identifié';

    final nom = patient!.nom.trim().toUpperCase();
    final prenom = patient!.prenom.trim();
    final value = '$nom $prenom'.trim();

    return value.isEmpty ? 'Patient non identifié' : value;
  }

  String get patientBirthDate {
    final value = patientDateNaissance.trim().isNotEmpty
        ? patientDateNaissance.trim()
        : patient?.dateNaissance.trim() ?? '';
    return value.isEmpty ? '' : value;
  }

  String get patientAddress {
    final parts = [
      patientAdresse.trim().isNotEmpty
          ? patientAdresse.trim()
          : patient?.adresse.trim() ?? '',
      [
        patientCodePostal.trim().isNotEmpty
            ? patientCodePostal.trim()
            : patient?.codePostal.trim() ?? '',
        patientVille.trim().isNotEmpty
            ? patientVille.trim()
            : patient?.ville.trim() ?? '',
      ].where((part) => part.isNotEmpty).join(' '),
    ].where((part) => part.isNotEmpty).toList();

    return parts.join(', ');
  }

  String get practitionerFullName {
    final override =
        '${practitionerPrenom.trim()} ${practitionerNom.trim().toUpperCase()}'
            .trim();
    if (override.isNotEmpty) return override;

    final value = practitioner.fullName.trim();
    return value.isEmpty ? 'Masseur-kinésithérapeute non renseigné' : value;
  }

  String get practitionerAddress {
    final value = practitionerAddressOverride.trim();
    return value.isNotEmpty ? value : practitioner.adresse.trim();
  }

  String get practitionerIdentifier {
    final override = practitionerIdentifierOverride.trim();
    if (override.isNotEmpty) return override;

    final rpps = practitioner.rpps.trim();
    final adeli = practitioner.adeli.trim();

    if (rpps.isNotEmpty && adeli.isNotEmpty) {
      return 'RPPS : $rpps · ADELI : $adeli';
    }
    if (rpps.isNotEmpty) return 'RPPS : $rpps';
    if (adeli.isNotEmpty) return 'ADELI : $adeli';

    return '';
  }

  String get signatureBase64 {
    final workflowSignature = patientSignatureBase64?.trim() ?? '';
    if (workflowSignature.isNotEmpty) return workflowSignature;

    return patient?.signatureBase64?.trim() ?? '';
  }

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
    if (bodyParagraphsOverride.isNotEmpty) return bodyParagraphsOverride;

    switch (template.type) {
      case AttestationType.nearestAvailableMk:
        return [proximityDeclaration];

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

  List<ContactedCabinet> get filledContactedCabinets {
    return contactedCabinets.where((cabinet) => cabinet.hasData).toList();
  }

  String get proximityDeclaration {
    final cabinets = filledContactedCabinets;
    final contactsText = cabinets.isEmpty
        ? 'Les cabinets contactés ne sont pas renseignés.'
        : cabinets
              .map((cabinet) {
                final parts = [
                  cabinet.name.trim(),
                  cabinet.city.trim(),
                  if (cabinet.contactDate.trim().isNotEmpty)
                    'contacté le ${cabinet.contactDate.trim()}',
                  if (cabinet.reasonLabel.trim().isNotEmpty)
                    'motif : ${cabinet.reasonLabel.trim()}',
                ].where((part) => part.isNotEmpty).join(', ');
                return parts;
              })
              .join(' ; ');

    return 'Je soussigné(e), $patientFullName, né(e) le ${patientBirthDate.isEmpty ? 'Non renseigné' : patientBirthDate}, domicilié(e) ${patientAddress.isEmpty ? 'à une adresse non renseignée' : patientAddress}, atteste avoir sollicité une prise en charge à domicile auprès de $practitionerFullName${practitionerAddress.isEmpty ? '' : ', $practitionerAddress'}${practitionerIdentifier.isEmpty ? '' : ' ($practitionerIdentifier)'}. '
        '${distanceHomeOffice.trim().isEmpty ? '' : 'La distance domicile / cabinet déclarée est de ${distanceHomeOffice.trim()}. '}'
        '${prescriberName.trim().isEmpty && prescriptionDate.trim().isEmpty ? '' : 'La prescription est renseignée par ${prescriberName.trim().isEmpty ? 'un prescripteur non renseigné' : prescriberName.trim()}${prescriptionDate.trim().isEmpty ? '' : ', ordonnance du ${prescriptionDate.trim()}'}. '}'
        'Cabinets contactés : $contactsText. '
        'Cette attestation est établie pour documenter la recherche d’un masseur-kinésithérapeute disponible pour des soins à domicile, dans le respect de l’information du patient, du secret professionnel et des dispositions applicables du Code de la santé publique, notamment les articles L.1111-2 et L.1110-4.';
  }

  Map<String, dynamic> proximityDataToJson() {
    return {
      'patientNom': patientNom,
      'patientPrenom': patientPrenom,
      'patientDateNaissance': patientDateNaissance,
      'patientAdresse': patientAdresse,
      'patientCodePostal': patientCodePostal,
      'patientVille': patientVille,
      'practitionerNom': practitionerNom,
      'practitionerPrenom': practitionerPrenom,
      'practitionerIdentifierOverride': practitionerIdentifierOverride,
      'practitionerAddressOverride': practitionerAddressOverride,
      'distanceHomeOffice': distanceHomeOffice,
      'prescriberName': prescriberName,
      'prescriptionDate': prescriptionDate,
      'transmissionAuthorized': transmissionAuthorized,
      'contactedCabinets': contactedCabinets
          .map((cabinet) => cabinet.toJson())
          .toList(),
    };
  }
}
