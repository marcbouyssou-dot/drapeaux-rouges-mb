import 'clinical_enums.dart';

class ClinicalFinding {
  const ClinicalFinding({
    required this.id,
    required this.label,
    this.description,
    required this.category,
    required this.severity,
    required this.source,
    required this.createdAt,
  });

  final String id;
  final String label;
  final String? description;
  final ClinicalFindingCategory category;
  final ClinicalSeverity severity;
  final ClinicalSource source;
  final DateTime createdAt;
}
