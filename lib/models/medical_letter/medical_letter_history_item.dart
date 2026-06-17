import '../evaluation_model.dart';
import '../patient_local.dart';
import '../practitioner_profile.dart';
import 'medical_letter.dart';
import 'medical_letter_template.dart';

class MedicalLetterHistoryItem {
  const MedicalLetterHistoryItem({
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
    required this.patientMedecinNom,
    required this.patientMedecinRpps,
    required this.patientMedecinAdeli,
    required this.patientMedecinAdresse,
    required this.patientMedecinTelephone,
    required this.patientMedecinEmail,
    required this.practitionerProfile,
    required this.lieu,
    required this.subject,
    required this.bodyParagraphs,
    required this.evaluationSnapshot,
    required this.hasPractitionerSignature,
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
  final String patientMedecinNom;
  final String patientMedecinRpps;
  final String patientMedecinAdeli;
  final String patientMedecinAdresse;
  final String patientMedecinTelephone;
  final String patientMedecinEmail;
  final Map<String, dynamic> practitionerProfile;
  final String lieu;
  final String subject;
  final List<String> bodyParagraphs;
  final Map<String, dynamic> evaluationSnapshot;
  final bool hasPractitionerSignature;

  factory MedicalLetterHistoryItem.fromLetter(MedicalLetter letter) {
    final patient = letter.patient;
    final generatedAt = DateTime.now();

    return MedicalLetterHistoryItem(
      id: generatedAt.microsecondsSinceEpoch.toString(),
      typeId: letter.template.type.id,
      title: letter.template.title,
      pdfTitle: letter.template.pdfTitle,
      generatedAt: generatedAt,
      patientLocalId: patient?.localId ?? '',
      patientAnonymousId: patient?.anonymousId ?? '',
      patientNom: patient?.nom ?? '',
      patientPrenom: patient?.prenom ?? '',
      patientDateNaissance: patient?.dateNaissance ?? '',
      patientMedecinNom: patient?.medecinNom ?? '',
      patientMedecinRpps: patient?.medecinRpps ?? '',
      patientMedecinAdeli: patient?.medecinAdeli ?? '',
      patientMedecinAdresse: patient?.medecinAdresse ?? '',
      patientMedecinTelephone: patient?.medecinTelephone ?? '',
      patientMedecinEmail: patient?.medecinEmail ?? '',
      practitionerProfile: letter.practitioner.toJson(),
      lieu: letter.lieu,
      subject: letter.effectiveSubject,
      bodyParagraphs: letter.bodyParagraphs,
      evaluationSnapshot: letter.evaluation?.toJson() ?? const {},
      hasPractitionerSignature: letter.hasPractitionerSignature,
    );
  }

  factory MedicalLetterHistoryItem.fromMap(Map<String, dynamic> map) {
    return MedicalLetterHistoryItem(
      id: map['id']?.toString() ?? '',
      typeId: map['typeId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Courrier médical',
      pdfTitle: map['pdfTitle']?.toString() ?? 'COURRIER MÉDICAL',
      generatedAt:
          DateTime.tryParse(map['generatedAt']?.toString() ?? '') ??
          DateTime.now(),
      patientLocalId: map['patientLocalId']?.toString() ?? '',
      patientAnonymousId: map['patientAnonymousId']?.toString() ?? '',
      patientNom: map['patientNom']?.toString() ?? '',
      patientPrenom: map['patientPrenom']?.toString() ?? '',
      patientDateNaissance: map['patientDateNaissance']?.toString() ?? '',
      patientMedecinNom: map['patientMedecinNom']?.toString() ?? '',
      patientMedecinRpps: map['patientMedecinRpps']?.toString() ?? '',
      patientMedecinAdeli: map['patientMedecinAdeli']?.toString() ?? '',
      patientMedecinAdresse: map['patientMedecinAdresse']?.toString() ?? '',
      patientMedecinTelephone: map['patientMedecinTelephone']?.toString() ?? '',
      patientMedecinEmail: map['patientMedecinEmail']?.toString() ?? '',
      practitionerProfile: map['practitionerProfile'] is Map
          ? Map<String, dynamic>.from(map['practitionerProfile'] as Map)
          : const {},
      lieu: map['lieu']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      bodyParagraphs: map['bodyParagraphs'] is List
          ? (map['bodyParagraphs'] as List)
                .map((item) => item.toString())
                .toList()
          : const [],
      evaluationSnapshot: map['evaluationSnapshot'] is Map
          ? Map<String, dynamic>.from(map['evaluationSnapshot'] as Map)
          : const {},
      hasPractitionerSignature: map['hasPractitionerSignature'] == true,
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
      'patientMedecinNom': patientMedecinNom,
      'patientMedecinRpps': patientMedecinRpps,
      'patientMedecinAdeli': patientMedecinAdeli,
      'patientMedecinAdresse': patientMedecinAdresse,
      'patientMedecinTelephone': patientMedecinTelephone,
      'patientMedecinEmail': patientMedecinEmail,
      'practitionerProfile': practitionerProfile,
      'lieu': lieu,
      'subject': subject,
      'bodyParagraphs': bodyParagraphs,
      'evaluationSnapshot': evaluationSnapshot,
      'hasPractitionerSignature': hasPractitionerSignature,
    };
  }

  MedicalLetter toLetter() {
    return MedicalLetter(
      template: medicalLetterTemplateByTypeId(typeId),
      patient: patientLocal,
      practitioner: practitioner,
      date: generatedAt,
      lieu: lieu,
      subject: subject,
      evaluation: evaluation,
      bodyParagraphsOverride: bodyParagraphs,
    );
  }

  PractitionerProfile get practitioner {
    if (practitionerProfile.isEmpty) return PractitionerProfile.empty();
    return PractitionerProfile.fromJson(practitionerProfile);
  }

  EvaluationModel? get evaluation {
    if (evaluationSnapshot.isEmpty) return null;

    try {
      return EvaluationModel.fromJson(evaluationSnapshot);
    } catch (_) {
      return null;
    }
  }

  PatientLocal? get patientLocal {
    final hasIdentity =
        patientLocalId.trim().isNotEmpty ||
        patientAnonymousId.trim().isNotEmpty ||
        patientNom.trim().isNotEmpty ||
        patientPrenom.trim().isNotEmpty ||
        patientDateNaissance.trim().isNotEmpty ||
        patientMedecinNom.trim().isNotEmpty ||
        patientMedecinRpps.trim().isNotEmpty ||
        patientMedecinAdeli.trim().isNotEmpty ||
        patientMedecinAdresse.trim().isNotEmpty ||
        patientMedecinTelephone.trim().isNotEmpty ||
        patientMedecinEmail.trim().isNotEmpty;

    if (!hasIdentity) return null;

    return PatientLocal(
      localId: patientLocalId,
      anonymousId: patientAnonymousId,
      nom: patientNom,
      prenom: patientPrenom,
      dateNaissance: patientDateNaissance,
      consentementValide: false,
      dateConsentement: generatedAt,
      medecinNom: patientMedecinNom,
      medecinRpps: patientMedecinRpps,
      medecinAdeli: patientMedecinAdeli,
      medecinAdresse: patientMedecinAdresse,
      medecinTelephone: patientMedecinTelephone,
      medecinEmail: patientMedecinEmail,
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

  String get practitionerSignatureStatus {
    return hasPractitionerSignature
        ? 'Signature praticien présente'
        : 'Signature praticien absente';
  }

  List<String> get displayBodyParagraphs {
    if (bodyParagraphs.isNotEmpty) return bodyParagraphs;
    return toLetter().bodyParagraphs;
  }
}
