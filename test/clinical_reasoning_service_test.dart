import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/models/evaluation_model.dart';
import 'package:drapeaux_rouges_mb/services/clinical_reasoning_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Clinical reasoning models', () {
    test('creates a ClinicalFinding', () {
      final now = DateTime(2026, 1, 1);
      final finding = ClinicalFinding(
        id: 'finding-1',
        label: 'Douleur thoracique',
        description: 'Douleur inhabituelle',
        category: ClinicalFindingCategory.cardiovascular,
        severity: ClinicalSeverity.high,
        source: ClinicalSource.evaluation,
        createdAt: now,
      );

      expect(finding.id, 'finding-1');
      expect(finding.category, ClinicalFindingCategory.cardiovascular);
      expect(finding.severity, ClinicalSeverity.high);
      expect(finding.source, ClinicalSource.evaluation);
    });

    test('creates a ClinicalAlert', () {
      final now = DateTime(2026, 1, 1);
      final alert = ClinicalAlert(
        id: 'alert-1',
        title: 'Vigilance',
        message: 'Alerte clinique potentielle',
        level: ClinicalAlertLevel.warning,
        relatedFindingIds: const ['finding-1'],
        createdAt: now,
      );

      expect(alert.level, ClinicalAlertLevel.warning);
      expect(alert.relatedFindingIds, contains('finding-1'));
    });

    test('creates a ClinicalRecommendation', () {
      final now = DateTime(2026, 1, 1);
      final recommendation = ClinicalRecommendation(
        id: 'recommendation-1',
        title: 'Orienter',
        description: 'Avis medical conseille',
        priority: ClinicalRecommendationPriority.high,
        actionType: ClinicalActionType.refer,
        createdAt: now,
      );

      expect(recommendation.priority, ClinicalRecommendationPriority.high);
      expect(recommendation.actionType, ClinicalActionType.refer);
    });

    test('creates a ClinicalReasoning', () {
      final now = DateTime(2026, 1, 1);
      final reasoning = ClinicalReasoning(
        id: 'reasoning-1',
        evaluationId: 'evaluation-1',
        patientId: 'patient-1',
        findings: const [],
        alerts: const [],
        recommendations: const [],
        summary: 'Synthese minimale',
        createdAt: now,
      );

      expect(reasoning.id, 'reasoning-1');
      expect(reasoning.evaluationId, 'evaluation-1');
      expect(reasoning.summary, isNotEmpty);
    });
  });

  group('ClinicalReasoningService', () {
    test('buildFromEvaluation returns a valid minimal ClinicalReasoning', () {
      const service = ClinicalReasoningService();

      final reasoning = service.buildFromEvaluation();

      expect(reasoning.id, startsWith('clinical_reasoning_'));
      expect(reasoning.findings, isEmpty);
      expect(reasoning.alerts, isEmpty);
      expect(reasoning.recommendations, hasLength(1));
      expect(reasoning.summary, isNotEmpty);
    });

    test(
      'buildFromEvaluation maps existing checked flags without recalculating',
      () {
        const service = ClinicalReasoningService();
        final evaluation = EvaluationModel(
          evaluationId: 'eval-1',
          patientLocalId: 'patient-1',
          patientAnonymousId: null,
          patientDisplayName: 'Patient test',
          date: DateTime(2026, 1, 1),
          motif: 'Motif test',
          score: 7,
          riskLevel: 'Risque modere',
          checkedCount: 1,
          checkedFlags: const [
            {
              'label': 'Dyspnee inhabituelle',
              'category': 'Respiratoire',
              'severity': 'eleve',
            },
          ],
          decisionTitle: 'Decision test',
          decisionMessage: 'Message test',
          aiSummary: 'Synthese test',
        );

        final reasoning = service.buildFromEvaluation(evaluation: evaluation);

        expect(reasoning.id, 'clinical_reasoning_eval-1');
        expect(reasoning.evaluationId, 'eval-1');
        expect(reasoning.patientId, 'patient-1');
        expect(reasoning.findings, hasLength(1));
        expect(
          reasoning.findings.single.category,
          ClinicalFindingCategory.respiratory,
        );
        expect(reasoning.findings.single.severity, ClinicalSeverity.high);
        expect(reasoning.alerts, hasLength(1));
        expect(reasoning.recommendations, hasLength(1));
        expect(reasoning.summary, contains('elevee'));
      },
    );
  });
}
