import 'patient_local.dart';
import 'practitioner_profile.dart';

class PrescriptionModel {
  final String id;
  final String prescriptionType;
  final String professional;
  final String patient;
  final String patientLocalId;
  final String patientAnonymousId;
  final String patientNom;
  final String patientPrenom;
  final String patientDateNaissance;
  final String clinicalContext;
  final String prescription;
  final String frequency;
  final String duration;
  final String nomenclature;
  final Map<String, dynamic> practitionerProfile;
  final String? justificatifImageBase64;
  final DateTime createdAt;

  PrescriptionModel({
    String? id,
    this.prescriptionType = '',
    required this.professional,
    required this.patient,
    this.patientLocalId = '',
    this.patientAnonymousId = '',
    this.patientNom = '',
    this.patientPrenom = '',
    this.patientDateNaissance = '',
    required this.clinicalContext,
    required this.prescription,
    required this.frequency,
    required this.duration,
    required this.nomenclature,
    this.practitionerProfile = const {},
    this.justificatifImageBase64,
    required this.createdAt,
  }) : id = id ?? createdAt.microsecondsSinceEpoch.toString();

  factory PrescriptionModel.fromGenerated({
    required PatientLocal patient,
    required PractitionerProfile practitioner,
    required String prescriptionType,
    required String prescriptionContent,
    String? justificatifImageBase64,
  }) {
    final createdAt = DateTime.now();

    return PrescriptionModel(
      id: createdAt.microsecondsSinceEpoch.toString(),
      prescriptionType: prescriptionType,
      professional: practitioner.fullName,
      patient: '${patient.prenom} ${patient.nom.toUpperCase()}'.trim(),
      patientLocalId: patient.localId,
      patientAnonymousId: patient.anonymousId,
      patientNom: patient.nom,
      patientPrenom: patient.prenom,
      patientDateNaissance: patient.dateNaissance,
      clinicalContext: prescriptionType,
      prescription: prescriptionContent,
      frequency: '',
      duration: '',
      nomenclature: '',
      practitionerProfile: practitioner.toJson(),
      justificatifImageBase64: justificatifImageBase64,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prescriptionType': prescriptionType,
      'professional': professional,
      'patient': patient,
      'patientLocalId': patientLocalId,
      'patientAnonymousId': patientAnonymousId,
      'patientNom': patientNom,
      'patientPrenom': patientPrenom,
      'patientDateNaissance': patientDateNaissance,
      'clinicalContext': clinicalContext,
      'prescription': prescription,
      'frequency': frequency,
      'duration': duration,
      'nomenclature': nomenclature,
      'practitionerProfile': practitionerProfile,
      'justificatifImageBase64': justificatifImageBase64,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      id: map['id']?.toString(),
      prescriptionType: map['prescriptionType']?.toString() ?? '',
      professional: map['professional'] ?? '',
      patient: map['patient'] ?? '',
      patientLocalId: map['patientLocalId']?.toString() ?? '',
      patientAnonymousId: map['patientAnonymousId']?.toString() ?? '',
      patientNom: map['patientNom']?.toString() ?? '',
      patientPrenom: map['patientPrenom']?.toString() ?? '',
      patientDateNaissance: map['patientDateNaissance']?.toString() ?? '',
      clinicalContext: map['clinicalContext'] ?? '',
      prescription: map['prescription'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      nomenclature: map['nomenclature'] ?? '',
      practitionerProfile: map['practitionerProfile'] is Map
          ? Map<String, dynamic>.from(map['practitionerProfile'])
          : const {},
      justificatifImageBase64: map['justificatifImageBase64']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  PractitionerProfile get practitioner {
    if (practitionerProfile.isEmpty) return PractitionerProfile.empty();
    return PractitionerProfile.fromJson(practitionerProfile);
  }

  PatientLocal get patientLocal {
    return PatientLocal(
      localId: patientLocalId,
      anonymousId: patientAnonymousId,
      nom: patientNom,
      prenom: patientPrenom,
      dateNaissance: patientDateNaissance,
      consentementValide: true,
      dateConsentement: createdAt,
    );
  }

  String get displayType {
    if (prescriptionType.trim().isNotEmpty) return prescriptionType.trim();
    if (clinicalContext.trim().isNotEmpty) return clinicalContext.trim();
    return 'Prescription';
  }

  String get displayPatient {
    if (patient.trim().isNotEmpty) return patient.trim();
    if (patientPrenom.trim().isNotEmpty || patientNom.trim().isNotEmpty) {
      return '$patientPrenom ${patientNom.toUpperCase()}'.trim();
    }
    return patientAnonymousId.trim().isEmpty
        ? 'Patient non renseigné'
        : patientAnonymousId.trim();
  }
}
