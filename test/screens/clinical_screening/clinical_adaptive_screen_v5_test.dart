import 'package:drapeaux_rouges_mb/screens/clinical_screening/clinical_adaptive_screen_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalAdaptiveScreenV5', () {
    testWidgets('shows the first question', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Évaluation clinique'), findsOneWidget);
      expect(find.text('Question 1 sur $_totalQuestionCount'), findsOneWidget);
      expect(find.text('Question 0 sur $_totalQuestionCount'), findsNothing);
      expect(
        find.byKey(const Key('adaptive-v5-question-text')),
        findsOneWidget,
      );
      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Répondez selon les éléments recueillis pendant l’entretien clinique.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows yes and no buttons initially', (tester) async {
      await _pumpScreen(tester);

      expect(find.byKey(const Key('adaptive-v5-yes-button')), findsOneWidget);
      expect(find.byKey(const Key('adaptive-v5-no-button')), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Oui'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Non'), findsOneWidget);
    });

    testWidgets('tapping no moves to the next question', (tester) async {
      await _pumpScreen(tester);

      await _tapNo(tester);

      expect(find.text('Question 2 sur $_totalQuestionCount'), findsOneWidget);
      expect(find.textContaining('essoufflement brutal'), findsOneWidget);
    });

    testWidgets('tapping yes on cauda equina triggers hard stop', (
      tester,
    ) async {
      await _pumpScreen(tester);

      await _tapYes(tester);

      expect(find.text('Alerte clinique prioritaire'), findsOneWidget);
      expect(find.text('Hard Stop'), findsNothing);
      expect(
        find.text('Suspicion de syndrome de la queue de cheval'),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('Urgence immédiate'), findsAtLeastNWidgets(1));
      expect(
        find.byKey(const Key('adaptive-v5-final-decision')),
        findsOneWidget,
      );
    });

    testWidgets('hard stop hides yes and no buttons', (tester) async {
      await _pumpScreen(tester);

      await _tapYes(tester);

      expect(find.byKey(const Key('adaptive-v5-yes-button')), findsNothing);
      expect(find.byKey(const Key('adaptive-v5-no-button')), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Oui'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Non'), findsNothing);
    });

    testWidgets('does not display clinical percentages', (tester) async {
      await _pumpScreen(tester);

      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('pourcent'), findsNothing);

      await _tapYes(tester);

      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('pourcent'), findsNothing);
    });

    testWidgets('shows routine final state after negative answers', (
      tester,
    ) async {
      await _pumpScreen(tester);

      for (var index = 0; index < _totalQuestionCount; index++) {
        await _tapNo(tester);
      }

      expect(find.text('Questionnaire terminé'), findsOneWidget);
      expect(find.text('État final'), findsOneWidget);
      expect(
        find.byKey(const Key('adaptive-v5-final-decision')),
        findsOneWidget,
      );
      expect(find.text('Prise en charge habituelle'), findsAtLeastNWidgets(1));
      expect(
        find.text(
          'Aucun signal d’alerte prioritaire n’a été retrouvé dans ce questionnaire. La décision finale reste sous la responsabilité du professionnel.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('adaptive-v5-yes-button')), findsNothing);
      expect(find.byKey(const Key('adaptive-v5-no-button')), findsNothing);
    });

    testWidgets('clinical details are hidden by default', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Détails cliniques'), findsOneWidget);
      expect(
        find.byKey(const Key('adaptive-v5-technical-summary')),
        findsNothing,
      );
    });

    testWidgets('clinical details expose internal V7 state when expanded', (
      tester,
    ) async {
      await _pumpScreen(tester);

      await tester.tap(find.text('Détails cliniques'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('adaptive-v5-technical-summary')),
        findsOneWidget,
      );
      expect(find.textContaining('Décision : routine'), findsOneWidget);
      expect(find.textContaining('hardStopState : absent'), findsOneWidget);
      expect(find.textContaining('canReassure : true'), findsOneWidget);
      expect(find.textContaining('script : aucun'), findsOneWidget);
      expect(find.textContaining('hypothèse : aucune'), findsOneWidget);
    });
  });
}

int get _totalQuestionCount =>
    ClinicalScreeningQuestionnaireV4.questions.length;

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ClinicalAdaptiveScreenV5()));
  await tester.pumpAndSettle();
}

Future<void> _tapYes(WidgetTester tester) async {
  final button = find.byKey(const Key('adaptive-v5-yes-button'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _tapNo(WidgetTester tester) async {
  final button = find.byKey(const Key('adaptive-v5-no-button'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}
