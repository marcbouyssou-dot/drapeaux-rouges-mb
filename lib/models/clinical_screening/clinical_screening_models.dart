import 'clinical_screening_rule_version.dart';

enum ClinicalFlagCategory {
  general,
  cardiovascular,
  respiratory,
  neurological,
  infectious,
  vascular,
  musculoskeletal,
  postOperative,
  other,
}

enum ClinicalDecisionLevel {
  routine,
  monitor,
  medicalAdvice,
  urgentReferral,
  emergency,
}

enum ClinicalScreeningLayer { immediateDanger, systemic, regional, yellowFlag }

class ClinicalFlag {
  final String id;
  final String label;
  final ClinicalFlagCategory category;
  final ClinicalDecisionLevel level;
  final ClinicalScreeningLayer layer;
  final List<String> tags;
  final int weight;
  final bool isPresent;

  const ClinicalFlag({
    required this.id,
    required this.label,
    required this.category,
    required this.level,
    this.layer = ClinicalScreeningLayer.regional,
    this.tags = const [],
    this.weight = 1,
    this.isPresent = true,
  }) : assert(weight >= 0, 'weight must be greater than or equal to zero');

  ClinicalFlag copyWith({
    String? id,
    String? label,
    ClinicalFlagCategory? category,
    ClinicalDecisionLevel? level,
    ClinicalScreeningLayer? layer,
    List<String>? tags,
    int? weight,
    bool? isPresent,
  }) {
    return ClinicalFlag(
      id: id ?? this.id,
      label: label ?? this.label,
      category: category ?? this.category,
      level: level ?? this.level,
      layer: layer ?? this.layer,
      tags: tags ?? this.tags,
      weight: weight ?? this.weight,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}

class ClinicalRecommendedAction {
  final ClinicalDecisionLevel level;
  final String title;
  final String message;
  final bool requiresMedicalContact;
  final bool requiresEmergencyCall;
  final List<String> relatedFlagIds;

  const ClinicalRecommendedAction({
    required this.level,
    required this.title,
    required this.message,
    required this.requiresMedicalContact,
    required this.requiresEmergencyCall,
    this.relatedFlagIds = const [],
  });
}

class ClinicalReasoningTrace {
  final String ruleId;
  final String rulesetVersion;
  final String title;
  final ClinicalScreeningLayer layer;
  final ClinicalDecisionLevel decisionLevel;
  final List<String> causalFlagIds;
  final String explanation;

  ClinicalReasoningTrace({
    required this.ruleId,
    required this.rulesetVersion,
    required this.title,
    required this.layer,
    required this.decisionLevel,
    required List<String> causalFlagIds,
    required this.explanation,
  }) : causalFlagIds = List.unmodifiable(causalFlagIds);
}

class ClinicalScreeningSession {
  final String id;
  final String? patientId;
  final String reason;
  final DateTime createdAt;
  final List<ClinicalFlag> flags;
  final ClinicalDecisionLevel decisionLevel;
  final ClinicalRecommendedAction recommendedAction;
  final int score;
  final List<ClinicalReasoningTrace> traces;
  final String engineName;
  final String engineVersion;
  final String rulesetVersion;
  final String rulesetDate;
  final String clinicalStatus;

  ClinicalScreeningSession({
    required this.id,
    required this.reason,
    required this.createdAt,
    required List<ClinicalFlag> flags,
    required this.decisionLevel,
    required this.recommendedAction,
    required this.score,
    required List<ClinicalReasoningTrace> traces,
    required this.engineName,
    required this.engineVersion,
    required this.rulesetVersion,
    required this.rulesetDate,
    required this.clinicalStatus,
    this.patientId,
  }) : flags = List.unmodifiable(flags),
       traces = List.unmodifiable(traces);

  List<ClinicalFlag> get presentFlags {
    return flags.where((flag) => flag.isPresent).toList(growable: false);
  }

  bool get hasPresentFlags => presentFlags.isNotEmpty;

  String get reasoningSummary => exportReasoningText();

  String exportReasoningText() {
    final primaryTrace = traces.isNotEmpty ? traces.first : null;
    final flagLabelsById = {for (final flag in flags) flag.id: flag.label};
    final causalLabels =
        primaryTrace?.causalFlagIds
            .map((id) => flagLabelsById[id] ?? id)
            .toList(growable: false) ??
        const <String>[];

    return [
      'Décision : ${recommendedAction.title}.',
      if (primaryTrace != null) 'Règle déclenchée : ${primaryTrace.title}.',
      if (causalLabels.isNotEmpty)
        'Éléments retenus : ${causalLabels.join(', ')}.',
      if (primaryTrace != null) 'Interprétation : ${primaryTrace.explanation}',
      'Conduite proposée : ${recommendedAction.message}',
      'Moteur : $engineName',
      'Version moteur : $engineVersion',
      'Version règles : $rulesetVersion',
      'Date règles : $rulesetDate',
      'Statut clinique : ${_clinicalStatusLabel(clinicalStatus)}',
    ].join('\n');
  }

  String _clinicalStatusLabel(String value) {
    if (value == ClinicalScreeningRuleVersion.clinicalStatus) {
      return ClinicalScreeningRuleVersion.clinicalStatusLabel;
    }

    return value;
  }
}
