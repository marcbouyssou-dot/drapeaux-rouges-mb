import '../models/clinical/clinical_models.dart';

class ClinicalReasoningMapper {
  const ClinicalReasoningMapper();

  ClinicalReasoning enrich(ClinicalReasoning reasoning) {
    final maxSeverity = _maxSeverity(reasoning.findings);
    final alerts = _buildAlerts(reasoning, maxSeverity);
    final recommendations = _buildRecommendations(reasoning, maxSeverity);

    return ClinicalReasoning(
      id: reasoning.id,
      evaluationId: reasoning.evaluationId,
      patientId: reasoning.patientId,
      findings: reasoning.findings,
      alerts: alerts,
      recommendations: recommendations,
      summary: _buildSummary(reasoning.findings, maxSeverity),
      createdAt: reasoning.createdAt,
    );
  }

  ClinicalSeverity _maxSeverity(List<ClinicalFinding> findings) {
    if (findings.isEmpty) return ClinicalSeverity.unknown;

    return findings.map((finding) => finding.severity).reduce((current, next) {
      return _severityRank(next) > _severityRank(current) ? next : current;
    });
  }

  List<ClinicalAlert> _buildAlerts(
    ClinicalReasoning reasoning,
    ClinicalSeverity maxSeverity,
  ) {
    if (reasoning.findings.isEmpty) return const <ClinicalAlert>[];
    if (maxSeverity != ClinicalSeverity.high &&
        maxSeverity != ClinicalSeverity.critical) {
      return const <ClinicalAlert>[];
    }

    final relatedFindingIds = reasoning.findings
        .where((finding) => finding.severity == maxSeverity)
        .map((finding) => finding.id)
        .toList(growable: false);

    return [
      ClinicalAlert(
        id: '${reasoning.id}_alert_${maxSeverity.name}',
        title: maxSeverity == ClinicalSeverity.critical
            ? 'Vigilance clinique prioritaire'
            : 'Vigilance clinique renforcee',
        message:
            'Un ou plusieurs elements cliniques structurés demandent une validation par le praticien.',
        level: maxSeverity == ClinicalSeverity.critical
            ? ClinicalAlertLevel.critical
            : ClinicalAlertLevel.warning,
        relatedFindingIds: relatedFindingIds,
        createdAt: reasoning.createdAt,
      ),
    ];
  }

  List<ClinicalRecommendation> _buildRecommendations(
    ClinicalReasoning reasoning,
    ClinicalSeverity maxSeverity,
  ) {
    if (reasoning.findings.isEmpty) {
      return [
        ClinicalRecommendation(
          id: '${reasoning.id}_recommendation_complete_evaluation',
          title: 'Completer l evaluation clinique',
          description:
              'Aucun element clinique structure n est disponible. Completer l evaluation avant toute interpretation.',
          priority: ClinicalRecommendationPriority.medium,
          actionType: ClinicalActionType.document,
          createdAt: reasoning.createdAt,
        ),
      ];
    }

    switch (maxSeverity) {
      case ClinicalSeverity.critical:
        return [
          ClinicalRecommendation(
            id: '${reasoning.id}_recommendation_critical_review',
            title: 'Validation clinique prioritaire',
            description:
                'Verifier rapidement les elements critiques et orienter selon le contexte clinique, sans poser de diagnostic automatique.',
            priority: ClinicalRecommendationPriority.urgent,
            actionType: ClinicalActionType.emergencyReferral,
            createdAt: reasoning.createdAt,
          ),
        ];
      case ClinicalSeverity.high:
        return [
          ClinicalRecommendation(
            id: '${reasoning.id}_recommendation_high_review',
            title: 'Validation clinique renforcee',
            description:
                'Revoir les elements de severite elevee et confirmer la conduite a tenir par le praticien.',
            priority: ClinicalRecommendationPriority.high,
            actionType: ClinicalActionType.refer,
            createdAt: reasoning.createdAt,
          ),
        ];
      case ClinicalSeverity.moderate:
        return [
          ClinicalRecommendation(
            id: '${reasoning.id}_recommendation_monitor',
            title: 'Surveillance clinique',
            description:
                'Contextualiser les elements releves et maintenir une surveillance clinique adaptee.',
            priority: ClinicalRecommendationPriority.medium,
            actionType: ClinicalActionType.monitor,
            createdAt: reasoning.createdAt,
          ),
        ];
      case ClinicalSeverity.low:
      case ClinicalSeverity.unknown:
        return [
          ClinicalRecommendation(
            id: '${reasoning.id}_recommendation_practitioner_validation',
            title: 'Validation par le praticien',
            description:
                'Utiliser ces elements comme aide au raisonnement clinique et confirmer leur pertinence.',
            priority: ClinicalRecommendationPriority.low,
            actionType: ClinicalActionType.monitor,
            createdAt: reasoning.createdAt,
          ),
        ];
    }
  }

  String _buildSummary(
    List<ClinicalFinding> findings,
    ClinicalSeverity maxSeverity,
  ) {
    if (findings.isEmpty) {
      return 'Aucun element clinique structure disponible. Completer l evaluation clinique avant interpretation.';
    }

    final count = findings.length;
    final severityLabel = _severityLabel(maxSeverity);

    return '$count element(s) clinique(s) structure(s) disponible(s). Severite maximale: $severityLabel. Synthese fournie comme aide au raisonnement clinique, a valider par le praticien.';
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

  String _severityLabel(ClinicalSeverity severity) {
    switch (severity) {
      case ClinicalSeverity.critical:
        return 'critique';
      case ClinicalSeverity.high:
        return 'elevee';
      case ClinicalSeverity.moderate:
        return 'moderee';
      case ClinicalSeverity.low:
        return 'faible';
      case ClinicalSeverity.unknown:
        return 'non determinee';
    }
  }
}
