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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'level': level.name,
      'relatedFindingIds': relatedFindingIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClinicalAlert.fromJson(Map<String, dynamic> json) {
    return ClinicalAlert(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      level: _alertLevelFromJson(json['level']),
      relatedFindingIds: List<String>.from(json['relatedFindingIds'] ?? []),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

ClinicalAlertLevel _alertLevelFromJson(Object? value) {
  final name = value?.toString();
  return ClinicalAlertLevel.values.firstWhere(
    (item) => item.name == name,
    orElse: () => ClinicalAlertLevel.info,
  );
}
