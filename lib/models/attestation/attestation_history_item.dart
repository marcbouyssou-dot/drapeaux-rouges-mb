import '../patient_local.dart';
import '../practitioner_profile.dart';
import 'attestation_template.dart';
import 'attestation_type.dart';
import 'patient_attestation.dart';

class AttestationHistoryItem {
  const AttestationHistoryItem({
    required this.id,
    required this.typeId,
    required this.title,
    required this.pdfTitle,
    required this.generatedAt,
    required this.patientLocalId,
    required this.patientAnonymousId,
    required this.patientNom,
    required this.patientPrenom,
    required this.patientDateNaissance,
    required this.practitionerProfile,
    required this.lieu,
    required this.hasSignature,
    required this.signatureBase64,
    required this.consentConfirmed,
    required this.bodyParagraphs,
  });

  final String id;
  final String typeId;
  final String title;
  final String pdfTitle;
  final DateTime generatedAt;
  final String patientLocalId;
  final String patientAnonymousId;
  final String patientNom;
  final String patientPrenom;
  final String patientDateNaissance;
  final Map<String, dynamic> practitionerProfile;
  final String lieu;
  final bool hasSignature;
  final String signatureBase64;
  final bool consentConfirmed;
  final List<String> bodyParagraphs;

  factory AttestationHistoryItem.fromAttestation(
    PatientAttestation attestation,
  ) {
    final patient = attestation.patient;
    final generatedAt = DateTime.now();

    return AttestationHistoryItem(
      id: generatedAt.microsecondsSinceEpoch.toString(),
      typeId: attestation.template.type.id,
      title: attestation.template.title,
      pdfTitle: attestation.template.pdfTitle,
      generatedAt: generatedAt,
      patientLocalId: patient?.localId ?? '',
      patientAnonymousId: patient?.anonymousId ?? '',
      patientNom: patient?.nom ?? '',
      patientPrenom: patient?.prenom ?? '',
      patientDateNaissance: patient?.dateNaissance ?? '',
      practitionerProfile: attestation.practitioner.toJson(),
      lieu: attestation.lieu,
      hasSignature: attestation.hasPatientSignature,
      signatureBase64: attestation.signatureBase64,
      consentConfirmed: attestation.consentConfirmed,
      bodyParagraphs: attestation.bodyParagraphs,
    );
  }

  factory AttestationHistoryItem.fromMap(Map<String, dynamic> map) {
    return AttestationHistoryItem(
      id: map['id']?.toString() ?? '',
      typeId: map['typeId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Attestation',
      pdfTitle: map['pdfTitle']?.toString() ?? 'ATTESTATION',
      generatedAt:
          DateTime.tryParse(map['generatedAt']?.toString() ?? '') ??
          DateTime.now(),
      patientLocalId: map['patientLocalId']?.toString() ?? '',
      patientAnonymousId: map['patientAnonymousId']?.toString() ?? '',
      patientNom: map['patientNom']?.toString() ?? '',
      patientPrenom: map['patientPrenom']?.toString() ?? '',
      patientDateNaissance: map['patientDateNaissance']?.toString() ?? '',
      practitionerProfile: map['practitionerProfile'] is Map
          ? Map<String, dynamic>.from(map['practitionerProfile'])
          : const {},
      lieu: map['lieu']?.toString() ?? '',
      hasSignature: map['hasSignature'] == true,
      signatureBase64: map['signatureBase64']?.toString() ?? '',
      consentConfirmed: map['consentConfirmed'] == true,
      bodyParagraphs: map['bodyParagraphs'] is List
          ? (map['bodyParagraphs'] as List)
                .map((item) => item.toString())
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'typeId': typeId,
      'title': title,
      'pdfTitle': pdfTitle,
      'generatedAt': generatedAt.toIso8601String(),
      'patientLocalId': patientLocalId,
      'patientAnonymousId': patientAnonymousId,
      'patientNom': patientNom,
      'patientPrenom': patientPrenom,
      'patientDateNaissance': patientDateNaissance,
      'practitionerProfile': practitionerProfile,
      'lieu': lieu,
      'hasSignature': hasSignature,
      'signatureBase64': signatureBase64,
      'consentConfirmed': consentConfirmed,
      'bodyParagraphs': bodyParagraphs,
    };
  }

  PatientAttestation toAttestation() {
    return PatientAttestation(
      template: attestationTemplateByTypeId(typeId),
      patient: patientLocal,
      practitioner: practitioner,
      date: generatedAt,
      lieu: lieu,
      bodyParagraphsOverride: bodyParagraphs,
      consentConfirmed: consentConfirmed,
      patientSignatureBase64: signatureBase64.trim().isEmpty
          ? null
          : signatureBase64,
    );
  }

  PractitionerProfile get practitioner {
    if (practitionerProfile.isEmpty) return PractitionerProfile.empty();
    return PractitionerProfile.fromJson(practitionerProfile);
  }

  PatientLocal? get patientLocal {
    final hasIdentity =
        patientLocalId.trim().isNotEmpty ||
        patientAnonymousId.trim().isNotEmpty ||
        patientNom.trim().isNotEmpty ||
        patientPrenom.trim().isNotEmpty ||
        patientDateNaissance.trim().isNotEmpty;

    if (!hasIdentity) return null;

    return PatientLocal(
      localId: patientLocalId,
      anonymousId: patientAnonymousId,
      nom: patientNom,
      prenom: patientPrenom,
      dateNaissance: patientDateNaissance,
      consentementValide: true,
      dateConsentement: generatedAt,
      signatureBase64: signatureBase64.trim().isEmpty ? null : signatureBase64,
    );
  }

  String get displayPatient {
    final nom = patientNom.trim().toUpperCase();
    final prenom = patientPrenom.trim();
    final identity = '$nom $prenom'.trim();

    if (identity.isNotEmpty) return identity;
    if (patientAnonymousId.trim().isNotEmpty) return patientAnonymousId.trim();

    return 'Patient non identifié';
  }

  String get signatureStatus {
    return hasSignature ? 'Signature présente' : 'Signature absente';
  }

  List<String> get displayBodyParagraphs {
    if (bodyParagraphs.isNotEmpty) return bodyParagraphs;
    return toAttestation().bodyParagraphs;
  }
}
