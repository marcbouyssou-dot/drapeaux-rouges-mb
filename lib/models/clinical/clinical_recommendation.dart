import 'clinical_enums.dart';

class ClinicalRecommendation {
  const ClinicalRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.actionType,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final ClinicalRecommendationPriority priority;
  final ClinicalActionType actionType;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'actionType': actionType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClinicalRecommendation.fromJson(Map<String, dynamic> json) {
    return ClinicalRecommendation(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: _priorityFromJson(json['priority']),
      actionType: _actionTypeFromJson(json['actionType']),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

ClinicalRecommendationPriority _priorityFromJson(Object? value) {
  final name = value?.toString();
  return ClinicalRecommendationPriority.values.firstWhere(
    (item) => item.name == name,
    orElse: () => ClinicalRecommendationPriority.low,
  );
}

ClinicalActionType _actionTypeFromJson(Object? value) {
  final name = value?.toString();
  return ClinicalActionType.values.firstWhere(
    (item) => item.name == name,
    orElse: () => ClinicalActionType.none,
  );
}
