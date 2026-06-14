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
            : 'Vigilance clinique renforcée',
        message: maxSeverity == ClinicalSeverity.critical
            ? 'La présence d’un élément de gravité critique impose une lecture prioritaire et une orientation médicale urgente selon le contexte.'
            : 'Un ou plusieurs éléments de gravité élevée justifient une validation clinique attentive par le praticien.',
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
          title: 'Compléter l’évaluation clinique',
          description:
              'Aucun élément clinique structuré n’est disponible pour étayer le raisonnement. Compléter l’évaluation avant toute interprétation.',
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
                'Vérifier sans délai les éléments critiques retenus et organiser l’orientation médicale adaptée, sans poser de diagnostic automatisé.',
            priority: ClinicalRecommendationPriority.urgent,
            actionType: ClinicalActionType.emergencyReferral,
            createdAt: reasoning.createdAt,
          ),
        ];
      case ClinicalSeverity.high:
        return [
          ClinicalRecommendation(
            id: '${reasoning.id}_recommendation_high_review',
            title: 'Validation clinique renforcée',
            description:
                'Reprendre les éléments de gravité élevée, les contextualiser avec l’examen clinique et confirmer la conduite à tenir par le praticien.',
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
                'Mettre en perspective les éléments relevés avec l’évolution clinique et maintenir une surveillance adaptée.',
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
                'Utiliser ces éléments comme support au raisonnement clinique et confirmer leur pertinence au regard du contexte du patient.',
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
      return 'Aucun élément clinique structuré n’est disponible pour construire une synthèse fiable. L’évaluation doit être complétée avant toute interprétation.';
    }

    final count = findings.length;
    final severityLabel = _severityLabel(maxSeverity);

    return '$count élément(s) clinique(s) ont été retenu(s). Le niveau de gravité maximal retenu est $severityLabel au regard des éléments sélectionnés. Cette synthèse constitue une aide au raisonnement clinique et doit être validée par le praticien.';
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
        return 'élevé';
      case ClinicalSeverity.moderate:
        return 'modéré';
      case ClinicalSeverity.low:
        return 'faible';
      case ClinicalSeverity.unknown:
        return 'non déterminé';
    }
  }
}
