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
}
