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

class ClinicalScreeningSession {
  final String id;
  final String? patientId;
  final String reason;
  final DateTime createdAt;
  final List<ClinicalFlag> flags;
  final ClinicalDecisionLevel decisionLevel;
  final ClinicalRecommendedAction recommendedAction;
  final int score;

  const ClinicalScreeningSession({
    required this.id,
    required this.reason,
    required this.createdAt,
    required this.flags,
    required this.decisionLevel,
    required this.recommendedAction,
    required this.score,
    this.patientId,
  });

  List<ClinicalFlag> get presentFlags {
    return flags.where((flag) => flag.isPresent).toList(growable: false);
  }

  bool get hasPresentFlags => presentFlags.isNotEmpty;
}
