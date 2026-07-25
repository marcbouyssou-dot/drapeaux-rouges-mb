import 'patient_local.dart';
import 'practitioner_profile.dart';

class BdkHistoryItem {
  static const int currentSchemaVersion = 1;

  const BdkHistoryItem({
    required this.id,
    required this.title,
    required this.generatedAt,
    required this.updatedAt,
    required this.patientLocalId,
    required this.patientAnonymousId,
    required this.patientDisplayName,
    required this.motif,
    required this.contexte,
    required this.antecedents,
    required this.evaluation,
    required this.tests,
    required this.limitations,
    required this.diagnostic,
    required this.vigilance,
    required this.objectifs,
    required this.planTraitement,
    required this.criteresReevaluation,
    required this.syntheseClinique,
    required this.patientSnapshot,
    required this.practitionerSnapshot,
    this.customContext,
    this.schemaVersion = currentSchemaVersion,
  });

  final int schemaVersion;
  final String id;
  final String title;
  final String? customContext;
  final DateTime generatedAt;
  final DateTime updatedAt;
  final String patientLocalId;
  final String patientAnonymousId;
  final String patientDisplayName;
  final String motif;
  final String contexte;
  final String antecedents;
  final String evaluation;
  final String tests;
  final String limitations;
  final String diagnostic;
  final String vigilance;
  final String objectifs;
  final String planTraitement;
  final String criteresReevaluation;
  final String syntheseClinique;
  final Map<String, dynamic>? patientSnapshot;
  final Map<String, dynamic> practitionerSnapshot;

  PatientLocal? get patient {
    final snapshot = patientSnapshot;
    if (snapshot == null) return null;

    try {
      return PatientLocal.fromJson(snapshot);
    } catch (_) {
      return null;
    }
  }

  PractitionerProfile get practitioner {
    return PractitionerProfile.fromJson(practitionerSnapshot);
  }

  String get displayPatient {
    final value = patientDisplayName.trim();
    return value.isEmpty ? 'Patient non renseigné' : value;
  }

  Map<String, dynamic> toMap() {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'title': title,
      'customContext': customContext,
      'generatedAt': generatedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'patientLocalId': patientLocalId,
      'patientAnonymousId': patientAnonymousId,
      'patientDisplayName': patientDisplayName,
      'motif': motif,
      'contexte': contexte,
      'antecedents': antecedents,
      'evaluation': evaluation,
      'tests': tests,
      'limitations': limitations,
      'diagnostic': diagnostic,
      'vigilance': vigilance,
      'objectifs': objectifs,
      'planTraitement': planTraitement,
      'criteresReevaluation': criteresReevaluation,
      'syntheseClinique': syntheseClinique,
      'patientSnapshot': patientSnapshot,
      'practitionerSnapshot': practitionerSnapshot,
    };
  }

  static BdkHistoryItem? tryFromMap(Map<String, dynamic> map) {
    final version = map['schemaVersion'];
    if (version != null &&
        (version is! int || version > currentSchemaVersion || version < 1)) {
      return null;
    }

    final generatedAt = DateTime.tryParse(map['generatedAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(map['updatedAt']?.toString() ?? '');
    if (generatedAt == null || updatedAt == null) return null;

    final patientSnapshot = map['patientSnapshot'];
    final practitionerSnapshot = map['practitionerSnapshot'];

    return BdkHistoryItem(
      schemaVersion: version is int ? version : currentSchemaVersion,
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'BDK',
      customContext: map['customContext']?.toString(),
      generatedAt: generatedAt,
      updatedAt: updatedAt,
      patientLocalId: map['patientLocalId']?.toString() ?? '',
      patientAnonymousId: map['patientAnonymousId']?.toString() ?? '',
      patientDisplayName: map['patientDisplayName']?.toString() ?? '',
      motif: map['motif']?.toString() ?? '',
      contexte: map['contexte']?.toString() ?? '',
      antecedents: map['antecedents']?.toString() ?? '',
      evaluation: map['evaluation']?.toString() ?? '',
      tests: map['tests']?.toString() ?? '',
      limitations: map['limitations']?.toString() ?? '',
      diagnostic: map['diagnostic']?.toString() ?? '',
      vigilance: map['vigilance']?.toString() ?? '',
      objectifs: map['objectifs']?.toString() ?? '',
      planTraitement: map['planTraitement']?.toString() ?? '',
      criteresReevaluation: map['criteresReevaluation']?.toString() ?? '',
      syntheseClinique: map['syntheseClinique']?.toString() ?? '',
      patientSnapshot: patientSnapshot is Map
          ? Map<String, dynamic>.from(patientSnapshot)
          : null,
      practitionerSnapshot: practitionerSnapshot is Map
          ? Map<String, dynamic>.from(practitionerSnapshot)
          : const {},
    );
  }
}
