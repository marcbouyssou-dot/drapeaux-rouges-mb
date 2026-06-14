import 'clinical_alert.dart';
import 'clinical_enums.dart';
import 'clinical_finding.dart';
import 'clinical_recommendation.dart';

class ClinicalReasoning {
  const ClinicalReasoning({
    required this.id,
    this.evaluationId,
    this.patientId,
    required this.findings,
    required this.alerts,
    required this.recommendations,
    required this.summary,
    this.severity,
    required this.createdAt,
  });

  final String id;
  final String? evaluationId;
  final String? patientId;
  final List<ClinicalFinding> findings;
  final List<ClinicalAlert> alerts;
  final List<ClinicalRecommendation> recommendations;
  final String summary;
  final ClinicalSeverity? severity;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    final savedSeverity = severity ?? _maxSeverity();

    return {
      'id': id,
      'evaluationId': evaluationId,
      'patientId': patientId,
      'summary': summary,
      'severity': savedSeverity.name,
      'alerts': alerts.map((alert) => alert.toJson()).toList(growable: false),
      'recommendations': recommendations
          .map((recommendation) => recommendation.toJson())
          .toList(growable: false),
      'retainedItems': findings
          .map((finding) => finding.toJson())
          .toList(growable: false),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClinicalReasoning.fromJson(Map<String, dynamic> json) {
    final rawAlerts = json['alerts'] ?? json['alert'] ?? [];
    final rawRecommendations =
        json['recommendations'] ?? json['recommendation'] ?? [];
    final rawFindings = json['retainedItems'] ?? json['findings'] ?? [];

    return ClinicalReasoning(
      id: json['id']?.toString() ?? '',
      evaluationId: json['evaluationId']?.toString(),
      patientId: json['patientId']?.toString(),
      findings: _readMapList(
        rawFindings,
      ).map(ClinicalFinding.fromJson).toList(growable: false),
      alerts: _readMapList(
        rawAlerts,
      ).map(ClinicalAlert.fromJson).toList(growable: false),
      recommendations: _readMapList(
        rawRecommendations,
      ).map(ClinicalRecommendation.fromJson).toList(growable: false),
      summary: json['summary']?.toString() ?? '',
      severity: _severityFromJson(json['severity']),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ClinicalSeverity _maxSeverity() {
    if (findings.isEmpty) return ClinicalSeverity.unknown;

    return findings.map((finding) => finding.severity).reduce((current, next) {
      return _severityRank(next) > _severityRank(current) ? next : current;
    });
  }

  int _severityRank(ClinicalSeverity severity) {
    switch (severity) {
      case ClinicalSeverity.critical:
        return 4;
      case ClinicalSeverity.high:
        return 3;
      case ClinicalSeverity.moderate:
        return 2;
      case ClinicalSeverity.low:
        return 1;
      case ClinicalSeverity.unknown:
        return 0;
    }
  }
}

ClinicalSeverity? _severityFromJson(Object? value) {
  final name = value?.toString();
  if (name == null || name.isEmpty) return null;

  return ClinicalSeverity.values.firstWhere(
    (item) => item.name == name,
    orElse: () => ClinicalSeverity.unknown,
  );
}

List<Map<String, dynamic>> _readMapList(Object? value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  if (value is Map) {
    return [Map<String, dynamic>.from(value)];
  }

  return const [];
}
