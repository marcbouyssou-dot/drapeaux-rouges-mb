import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/services/clinical_reasoning_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalReasoningMapper', () {
    test('maps reasoning with no finding', () {
      final reasoning = _reasoning(findings: const []);

      const mapper = ClinicalReasoningMapper();
      final enriched = mapper.enrich(reasoning);

      expect(enriched.findings, isEmpty);
      expect(enriched.alerts, isEmpty);
      expect(enriched.recommendations, hasLength(1));
      expect(
        enriched.recommendations.single.actionType,
        ClinicalActionType.document,
      );
      expect(enriched.summary, isNotEmpty);
    });

    test('maps low severity finding without alert', () {
      final finding = _finding(
        id: 'finding-low',
        severity: ClinicalSeverity.low,
      );
      final reasoning = _reasoning(findings: [finding]);

      const mapper = ClinicalReasoningMapper();
      final enriched = mapper.enrich(reasoning);

      expect(enriched.findings, [finding]);
      expect(enriched.alerts, isEmpty);
      expect(enriched.recommendations, hasLength(1));
      expect(
        enriched.recommendations.single.priority,
        ClinicalRecommendationPriority.low,
      );
      expect(enriched.summary, contains('faible'));
    });

    test('maps high severity finding with alert and recommendation', () {
      final finding = _finding(
        id: 'finding-high',
        severity: ClinicalSeverity.high,
      );
      final reasoning = _reasoning(findings: [finding]);

      const mapper = ClinicalReasoningMapper();
      final enriched = mapper.enrich(reasoning);

      expect(enriched.findings, [finding]);
      expect(enriched.alerts, hasLength(1));
      expect(enriched.alerts.single.level, ClinicalAlertLevel.warning);
      expect(enriched.alerts.single.relatedFindingIds, ['finding-high']);
      expect(
        enriched.recommendations.single.priority,
        ClinicalRecommendationPriority.high,
      );
      expect(enriched.summary, contains('gravité maximal retenu est élevé'));
    });

    test('maps critical severity finding with critical alert', () {
      final finding = _finding(
        id: 'finding-critical',
        severity: ClinicalSeverity.critical,
      );
      final reasoning = _reasoning(findings: [finding]);

      const mapper = ClinicalReasoningMapper();
      final enriched = mapper.enrich(reasoning);

      expect(enriched.findings, [finding]);
      expect(enriched.alerts, hasLength(1));
      expect(enriched.alerts.single.level, ClinicalAlertLevel.critical);
      expect(
        enriched.recommendations.single.priority,
        ClinicalRecommendationPriority.urgent,
      );
      expect(
        enriched.recommendations.single.actionType,
        ClinicalActionType.emergencyReferral,
      );
      expect(enriched.summary, contains('critique'));
    });

    test('keeps existing findings', () {
      final findings = [
        _finding(id: 'finding-1', severity: ClinicalSeverity.low),
        _finding(id: 'finding-2', severity: ClinicalSeverity.high),
      ];
      final reasoning = _reasoning(findings: findings);

      const mapper = ClinicalReasoningMapper();
      final enriched = mapper.enrich(reasoning);

      expect(enriched.findings, findings);
    });
  });
}

ClinicalReasoning _reasoning({required List<ClinicalFinding> findings}) {
  return ClinicalReasoning(
    id: 'reasoning-test',
    findings: findings,
    alerts: const [],
    recommendations: const [],
    summary: 'Minimal summary',
    createdAt: DateTime(2026, 1, 1),
  );
}

ClinicalFinding _finding({
  required String id,
  required ClinicalSeverity severity,
}) {
  return ClinicalFinding(
    id: id,
    label: 'Finding $id',
    category: ClinicalFindingCategory.other,
    severity: severity,
    source: ClinicalSource.evaluation,
    createdAt: DateTime(2026, 1, 1),
  );
}
