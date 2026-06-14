import 'clinical_alert.dart';
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
    required this.createdAt,
  });

  final String id;
  final String? evaluationId;
  final String? patientId;
  final List<ClinicalFinding> findings;
  final List<ClinicalAlert> alerts;
  final List<ClinicalRecommendation> recommendations;
  final String summary;
  final DateTime createdAt;
}
