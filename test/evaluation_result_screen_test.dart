import 'package:drapeaux_rouges_mb/screens/evaluation/evaluation_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpResultScreen(
    WidgetTester tester, {
    required List<Map<String, dynamic>> checkedFlags,
    int score = 0,
    int checkedCount = 0,
    String riskLevel = 'Risque faible',
  }) async {
    await tester.binding.setSurfaceSize(const Size(414, 896));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: EvaluationResultScreen(
          score: score,
          checkedCount: checkedCount,
          riskLevel: riskLevel,
          riskColor: Colors.green,
          selectedCategory: 'Respiratoire',
          categories: const {},
          patientDisplayName: 'Patient test',
          aiSummary: 'Résumé clinique existant.',
          checkedFlags: checkedFlags,
          decisionMessage: 'Message de décision existant.',
          onReset: () {},
          onSave: () {},
          onExportPdf: () {},
        ),
      ),
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

  testWidgets('shows clinical synthesis section', (tester) async {
    await pumpResultScreen(tester, checkedFlags: const []);

    expect(find.text('Synthèse clinique'), findsOneWidget);
    expect(
      find.textContaining('Aucun element clinique structure disponible'),
      findsOneWidget,
    );
  });

  testWidgets('shows recommendations when generated', (tester) async {
    await pumpResultScreen(tester, checkedFlags: const []);

    await scrollToText(tester, 'Recommandations');
    expect(find.text('Recommandations'), findsOneWidget);
    expect(find.text('Completer l evaluation clinique'), findsOneWidget);
  });

  testWidgets('shows alerts and findings when high severity finding exists', (
    tester,
  ) async {
    await pumpResultScreen(
      tester,
      score: 9,
      checkedCount: 1,
      riskLevel: 'Risque élevé',
      checkedFlags: const [
        {
          'label': 'Dyspnée inhabituelle',
          'category': 'Respiratoire',
          'severity': 'eleve',
        },
      ],
    );

    await scrollToText(tester, 'Alertes cliniques');
    expect(find.text('Alertes cliniques'), findsOneWidget);
    expect(find.text('Vigilance clinique renforcee'), findsOneWidget);

    await scrollToText(tester, 'Recommandations');
    expect(find.text('Recommandations'), findsOneWidget);
    expect(find.text('Validation clinique renforcee'), findsOneWidget);

    await scrollToText(tester, 'Éléments retenus');
    expect(find.text('Éléments retenus'), findsOneWidget);
    expect(find.text('Dyspnée inhabituelle'), findsOneWidget);
  });

  testWidgets('empty clinical sections do not crash', (tester) async {
    await pumpResultScreen(tester, checkedFlags: const []);

    expect(tester.takeException(), isNull);
    expect(find.text('Alertes cliniques'), findsNothing);
    expect(find.text('Éléments retenus'), findsNothing);
  });
}
