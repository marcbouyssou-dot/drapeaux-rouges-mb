import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/models/evaluation_model.dart';
import 'package:drapeaux_rouges_mb/screens/evaluation/evaluation_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDetailScreen(
    WidgetTester tester,
    Map<String, dynamic> evaluation,
  ) async {
    await tester.binding.setSurfaceSize(const Size(414, 896));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: EvaluationDetailScreen(evaluation: evaluation)),
    );

    await tester.pump();
  }

  Future<void> scrollToText(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
  }

  testWidgets('shows saved clinical reasoning in historical detail', (
    tester,
  ) async {
    await pumpDetailScreen(
      tester,
      _evaluationJson(clinicalReasoning: _clinicalReasoning()),
    );

    await scrollToText(tester, 'Synthèse clinique');
    expect(find.text('Synthèse clinique'), findsOneWidget);
    expect(
      find.text('Synthèse sauvegardée depuis l historique.'),
      findsOneWidget,
    );

    await scrollToText(tester, 'Sévérité maximale');
    expect(find.text('Sévérité maximale'), findsOneWidget);
    expect(find.text('Élevée'), findsWidgets);

    await scrollToText(tester, 'Alerte sauvegardée');
    expect(find.text('Alertes cliniques'), findsWidgets);
    expect(find.text('Alerte sauvegardée'), findsOneWidget);

    await scrollToText(tester, 'Recommandation sauvegardée');
    expect(find.text('Recommandations'), findsWidgets);
    expect(find.text('Recommandation sauvegardée'), findsOneWidget);

    await scrollToText(tester, 'Éléments retenus');
    expect(find.text('Éléments retenus'), findsOneWidget);
    expect(find.text('Finding sauvegardé'), findsOneWidget);
  });

  testWidgets('hides clinical reasoning block for old historical evaluation', (
    tester,
  ) async {
    final oldEvaluation = _evaluationJson()..remove('clinicalReasoning');

    await pumpDetailScreen(tester, oldEvaluation);

    expect(tester.takeException(), isNull);
    expect(find.text('Timeline clinique'), findsNothing);
    expect(find.text('Synthèse clinique'), findsNothing);
    expect(find.text('Alertes cliniques'), findsNothing);
    expect(find.text('Recommandations'), findsNothing);
    expect(find.text('Éléments retenus'), findsNothing);
  });

  testWidgets('shows compact historical evaluation summary without reasoning', (
    tester,
  ) async {
    final oldEvaluation = _evaluationJson(
      checkedFlags: const [
        {
          'title': 'Drapeau rouge historique',
          'category': 'Respiratoire',
          'severity': 'eleve',
        },
      ],
    )..remove('clinicalReasoning');

    await pumpDetailScreen(tester, oldEvaluation);

    expect(find.text('Synthèse de l’évaluation'), findsOneWidget);
    expect(find.text('Risque'), findsOneWidget);
    expect(find.text('Risque élevé'), findsWidgets);
    expect(find.text('Score'), findsWidgets);
    expect(find.text('8'), findsWidgets);
    expect(find.text('Drapeaux'), findsWidgets);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Orientation proposée'), findsOneWidget);
    expect(find.text('Décision enregistrée'), findsWidgets);
  });

  testWidgets('does not infer clinical reasoning when saved value is absent', (
    tester,
  ) async {
    final evaluationWithoutReasoning = _evaluationJson(
      checkedFlags: const [
        {
          'title': 'Drapeau rouge historique',
          'category': 'Respiratoire',
          'severity': 'eleve',
        },
      ],
    )..remove('clinicalReasoning');

    await pumpDetailScreen(tester, evaluationWithoutReasoning);

    expect(tester.takeException(), isNull);
    expect(find.text('Timeline clinique'), findsNothing);
    expect(find.text('Synthèse clinique'), findsNothing);

    await scrollToText(tester, 'Drapeaux rouges cochés');
    expect(find.text('Drapeau rouge historique'), findsOneWidget);
  });

  testWidgets('shows clinical timeline when clinical reasoning is saved', (
    tester,
  ) async {
    await pumpDetailScreen(
      tester,
      _evaluationJson(
        clinicalReasoning: _clinicalReasoning(),
        checkedFlags: const [
          {
            'title': 'Drapeau rouge historique',
            'category': 'Respiratoire',
            'severity': 'eleve',
          },
        ],
      ),
    );

    await scrollToText(tester, 'Timeline clinique');

    expect(find.text('Timeline clinique'), findsOneWidget);
    expect(find.text('Évaluation réalisée'), findsOneWidget);
    expect(find.text('Drapeaux rouges détectés'), findsOneWidget);
    expect(find.text('Niveau de risque retenu'), findsOneWidget);
    expect(find.text('Alertes cliniques'), findsWidgets);
    expect(find.text('Recommandations'), findsWidgets);
    expect(find.text('Orientation proposée'), findsOneWidget);
    expect(find.textContaining('Risque élevé'), findsOneWidget);
    expect(find.textContaining('1 alerte'), findsOneWidget);
  });
}

Map<String, dynamic> _evaluationJson({
  ClinicalReasoning? clinicalReasoning,
  List<Map<String, dynamic>> checkedFlags = const [],
}) {
  return EvaluationModel(
    evaluationId: 'evaluation-history-1',
    patientLocalId: 'patient-1',
    patientAnonymousId: null,
    patientDisplayName: 'Patient historique',
    date: DateTime(2026, 6, 14, 9, 30),
    motif: 'Respiratoire',
    score: checkedFlags.isEmpty ? 0 : 8,
    riskLevel: checkedFlags.isEmpty ? 'Risque faible' : 'Risque élevé',
    checkedCount: checkedFlags.length,
    checkedFlags: checkedFlags,
    decisionTitle: 'Décision enregistrée',
    decisionMessage: 'Message de décision enregistré.',
    aiSummary: 'Synthèse historique.',
    clinicalReasoning: clinicalReasoning,
  ).toJson();
}

ClinicalReasoning _clinicalReasoning() {
  return ClinicalReasoning(
    id: 'reasoning-history-1',
    evaluationId: 'evaluation-history-1',
    patientId: 'patient-1',
    findings: [
      ClinicalFinding(
        id: 'finding-history-1',
        label: 'Finding sauvegardé',
        category: ClinicalFindingCategory.respiratory,
        severity: ClinicalSeverity.high,
        source: ClinicalSource.evaluation,
        createdAt: DateTime(2026, 6, 14, 9, 31),
      ),
    ],
    alerts: [
      ClinicalAlert(
        id: 'alert-history-1',
        title: 'Alerte sauvegardée',
        message: 'Message d alerte sauvegardé.',
        level: ClinicalAlertLevel.warning,
        relatedFindingIds: const ['finding-history-1'],
        createdAt: DateTime(2026, 6, 14, 9, 32),
      ),
    ],
    recommendations: [
      ClinicalRecommendation(
        id: 'recommendation-history-1',
        title: 'Recommandation sauvegardée',
        description: 'Description de recommandation sauvegardée.',
        priority: ClinicalRecommendationPriority.high,
        actionType: ClinicalActionType.monitor,
        createdAt: DateTime(2026, 6, 14, 9, 33),
      ),
    ],
    summary: 'Synthèse sauvegardée depuis l historique.',
    createdAt: DateTime(2026, 6, 14, 9, 34),
  );
}
