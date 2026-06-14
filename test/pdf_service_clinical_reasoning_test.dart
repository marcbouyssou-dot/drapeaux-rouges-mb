import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/services/pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds compact clinical reasoning lines for evaluation PDF', () {
    final lines = PdfService.clinicalReasoningLines(_clinicalReasoning());

    expect(lines, contains('Synthèse clinique : Synthèse persistée.'));
    expect(lines, contains('Sévérité maximale : Élevée'));
    expect(lines, contains('Alertes cliniques :'));
    expect(
      lines,
      contains('- Alerte persistée (Vigilance) : Message d alerte persisté.'),
    );
    expect(lines, contains('Recommandations :'));
    expect(
      lines,
      contains('- Recommandation persistée (Haute) : Description persistée.'),
    );
    expect(lines, contains('Éléments retenus :'));
    expect(lines, contains('- Élément persisté (Respiratoire · Élevée)'));
    expect(lines.last, contains('Ne constitue pas un diagnostic automatisé'));
  });

  test('builds clinical reasoning lines without optional sections', () {
    final lines = PdfService.clinicalReasoningLines(
      ClinicalReasoning(
        id: 'reasoning-empty',
        findings: const [],
        alerts: const [],
        recommendations: const [],
        summary: 'Synthèse seule.',
        createdAt: DateTime(2026, 6, 14),
      ),
    );

    expect(lines, contains('Synthèse clinique : Synthèse seule.'));
    expect(lines, contains('Sévérité maximale : Non précisée'));
    expect(lines, isNot(contains('Alertes cliniques :')));
    expect(lines, isNot(contains('Recommandations :')));
    expect(lines, isNot(contains('Éléments retenus :')));
    expect(lines.last, contains('aide au raisonnement clinique'));
  });

  test('uses saved clinical reasoning severity when available', () {
    final reasoning = ClinicalReasoning.fromJson({
      ..._clinicalReasoning().toJson(),
      'severity': 'critical',
    });

    final lines = PdfService.clinicalReasoningLines(reasoning);

    expect(lines, contains('Sévérité maximale : Critique'));
  });
}

ClinicalReasoning _clinicalReasoning() {
  return ClinicalReasoning(
    id: 'reasoning-pdf',
    evaluationId: 'evaluation-pdf',
    patientId: 'patient-pdf',
    findings: [
      ClinicalFinding(
        id: 'finding-pdf',
        label: 'Élément persisté',
        category: ClinicalFindingCategory.respiratory,
        severity: ClinicalSeverity.high,
        source: ClinicalSource.evaluation,
        createdAt: DateTime(2026, 6, 14, 10),
      ),
    ],
    alerts: [
      ClinicalAlert(
        id: 'alert-pdf',
        title: 'Alerte persistée',
        message: 'Message d alerte persisté.',
        level: ClinicalAlertLevel.warning,
        relatedFindingIds: const ['finding-pdf'],
        createdAt: DateTime(2026, 6, 14, 10, 1),
      ),
    ],
    recommendations: [
      ClinicalRecommendation(
        id: 'recommendation-pdf',
        title: 'Recommandation persistée',
        description: 'Description persistée.',
        priority: ClinicalRecommendationPriority.high,
        actionType: ClinicalActionType.monitor,
        createdAt: DateTime(2026, 6, 14, 10, 2),
      ),
    ],
    summary: 'Synthèse persistée.',
    createdAt: DateTime(2026, 6, 14, 10, 3),
  );
}
