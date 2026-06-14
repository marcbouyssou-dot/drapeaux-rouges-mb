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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'category': category.name,
      'severity': severity.name,
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClinicalFinding.fromJson(Map<String, dynamic> json) {
    return ClinicalFinding(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString(),
      category: _findingCategoryFromJson(json['category']),
      severity: _severityFromJson(json['severity']),
      source: _sourceFromJson(json['source']),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

ClinicalFindingCategory _findingCategoryFromJson(Object? value) {
  final name = value?.toString();
  return ClinicalFindingCategory.values.firstWhere(
    (item) => item.name == name,
    orElse: () => ClinicalFindingCategory.other,
  );
}

ClinicalSeverity _severityFromJson(Object? value) {
  final name = value?.toString();
  return ClinicalSeverity.values.firstWhere(
    (item) => item.name == name,
    orElse: () => ClinicalSeverity.unknown,
  );
}

ClinicalSource _sourceFromJson(Object? value) {
  final name = value?.toString();
  return ClinicalSource.values.firstWhere(
    (item) => item.name == name,
    orElse: () => ClinicalSource.unknown,
  );
}
