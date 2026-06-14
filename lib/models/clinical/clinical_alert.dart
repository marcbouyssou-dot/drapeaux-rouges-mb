import 'clinical_enums.dart';

class ClinicalAlert {
  const ClinicalAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.relatedFindingIds,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final ClinicalAlertLevel level;
  final List<String> relatedFindingIds;
  final DateTime createdAt;
}
