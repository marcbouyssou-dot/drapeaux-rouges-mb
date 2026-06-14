import '../models/clinical/clinical_models.dart';
import '../models/evaluation_model.dart';

class ClinicalReasoningService {
  const ClinicalReasoningService();

  ClinicalReasoning buildFromEvaluation({EvaluationModel? evaluation}) {
    final now = DateTime.now();
    final findings = evaluation == null
        ? <ClinicalFinding>[]
        : _buildFindings(evaluation.checkedFlags, now);

    return ClinicalReasoning(
      id: _buildReasoningId(evaluation, now),
      evaluationId: evaluation?.evaluationId,
      patientId: evaluation?.patientLocalId ?? evaluation?.patientAnonymousId,
      findings: findings,
      alerts: const <ClinicalAlert>[],
      recommendations: const <ClinicalRecommendation>[],
      summary: _buildSummary(evaluation),
      createdAt: now,
    );
  }

  List<ClinicalFinding> _buildFindings(
    List<Map<String, dynamic>> checkedFlags,
    DateTime createdAt,
  ) {
    return checkedFlags.indexed
        .map((entry) {
          final index = entry.$1;
          final flag = entry.$2;
          final label = _readString(flag, const [
            'label',
            'title',
            'name',
            'text',
          ]);
          final description = _readString(flag, const [
            'description',
            'message',
            'detail',
          ], fallback: '');
          final category = _mapCategory(
            _readString(flag, const ['category', 'categorie', 'domain']),
          );
          final severity = _mapSeverity(
            _readString(flag, const ['severity', 'level', 'riskLevel']),
          );

          return ClinicalFinding(
            id: 'finding_${index + 1}',
            label: label.isEmpty ? 'Element clinique ${index + 1}' : label,
            description: description.isEmpty ? null : description,
            category: category,
            severity: severity,
            source: ClinicalSource.evaluation,
            createdAt: createdAt,
          );
        })
        .toList(growable: false);
  }

  String _buildReasoningId(EvaluationModel? evaluation, DateTime now) {
    if (evaluation != null && evaluation.evaluationId.isNotEmpty) {
      return 'clinical_reasoning_${evaluation.evaluationId}';
    }

    return 'clinical_reasoning_${now.microsecondsSinceEpoch}';
  }

  String _buildSummary(EvaluationModel? evaluation) {
    if (evaluation == null) {
      return 'Clinical reasoning pret a etre alimente par une evaluation.';
    }

    if (evaluation.aiSummary.trim().isNotEmpty) return evaluation.aiSummary;
    if (evaluation.decisionMessage.trim().isNotEmpty) {
      return evaluation.decisionMessage;
    }

    return 'Clinical reasoning minimal genere depuis l evaluation.';
  }

  String _readString(
    Map<String, dynamic> source,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }

    return fallback;
  }

  ClinicalFindingCategory _mapCategory(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('cardio')) {
      return ClinicalFindingCategory.cardiovascular;
    }
    if (normalized.contains('respir')) {
      return ClinicalFindingCategory.respiratory;
    }
    if (normalized.contains('neuro')) {
      return ClinicalFindingCategory.neurological;
    }
    if (normalized.contains('infect')) {
      return ClinicalFindingCategory.infectious;
    }
    if (normalized.contains('mental') ||
        normalized.contains('psych') ||
        normalized.contains('sante mentale')) {
      return ClinicalFindingCategory.mentalHealth;
    }
    if (normalized.contains('musculo') ||
        normalized.contains('ortho') ||
        normalized.contains('artic')) {
      return ClinicalFindingCategory.musculoskeletal;
    }

    return ClinicalFindingCategory.other;
  }

  ClinicalSeverity _mapSeverity(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('crit')) return ClinicalSeverity.critical;
    if (normalized.contains('high') || normalized.contains('eleve')) {
      return ClinicalSeverity.high;
    }
    if (normalized.contains('moder')) return ClinicalSeverity.moderate;
    if (normalized.contains('low') || normalized.contains('faible')) {
      return ClinicalSeverity.low;
    }

    return ClinicalSeverity.unknown;
  }
}
