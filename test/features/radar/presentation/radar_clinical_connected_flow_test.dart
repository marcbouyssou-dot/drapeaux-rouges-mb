import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Radar clinical connected flow', () {
    testWidgets('tapping Lombaires opens the first real runtime question', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsOneWidget,
      );
      expect(find.text('ÉVALUATION CLINIQUE'), findsOneWidget);
    });

    testWidgets('tapping Cou opens the cervical pathway question', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      await tester.tap(find.text('Cou'));
      await tester.pumpAndSettle();

      expect(find.textContaining('céphalée inhabituelle'), findsOneWidget);
      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsNothing,
      );
    });

    testWidgets(
      'different supported regions can start with different questions',
      (tester) async {
        await _pumpStartScreen(tester);
        await tester.tap(find.text('Lombaires'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('troubles urinaires ou fécaux nouveaux'),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _pumpStartScreen(tester);
        await tester.tap(find.text('Cou'));
        await tester.pumpAndSettle();

        expect(find.textContaining('céphalée inhabituelle'), findsOneWidget);
        expect(
          find.textContaining('troubles urinaires ou fécaux nouveaux'),
          findsNothing,
        );
      },
    );

    testWidgets('unsupported Tête / Face does not start a lumbar session', (
      tester,
    ) async {
      final observer = _RecordingNavigatorObserver();
      await _pumpStartScreen(tester, observer: observer);
      final routeCountBeforeTap = observer.didPushCount;

      await tester.tap(find.text('Tête / Face'));
      await tester.pump();

      expect(observer.didPushCount, routeCountBeforeTap);
      expect(
        find.textContaining(
          'Parcours clinique non disponible dans la matrice expérimentale V0.1',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsNothing,
      );
    });

    testWidgets('only yes and no are visible in the connected V5 flow', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      expect(find.text('Oui'), findsOneWidget);
      expect(find.text('Non'), findsOneWidget);
      expect(find.text('Des deux côtés'), findsNothing);
      expect(find.text('Impossible à préciser'), findsNothing);
    });

    testWidgets('tapping no shows next real question without pushing a route', (
      tester,
    ) async {
      final observer = _RecordingNavigatorObserver();
      await _pumpStartScreen(tester, observer: observer);
      final routeCountBeforeStart = observer.didPushCount;

      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();
      expect(observer.didPushCount, routeCountBeforeStart + 1);

      await tester.tap(find.text('Non'));
      await tester.pumpAndSettle();

      expect(observer.didPushCount, routeCountBeforeStart + 1);
      expect(find.textContaining('cancer actif'), findsOneWidget);
      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsNothing,
      );
    });

    testWidgets('lumbar summary displays dynamic session data', (tester) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      expect(find.textContaining('Région : Lombaires'), findsWidgets);
      expect(find.text('Parcours clinique réalisé'), findsOneWidget);
      await _scrollUntilText(tester, 'Statut expérimental et version');
      expect(find.text('Statut expérimental et version'), findsOneWidget);
    });

    testWidgets('another pathway summary displays its own region', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Cou'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      expect(find.textContaining('Région : Cou'), findsWidgets);
      expect(find.textContaining('Région : Lombaires'), findsNothing);
    });

    testWidgets('positive answer appears dynamically in summary', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(
        tester,
        answerForCurrentQuestion: () {
          if (find.textContaining('liée au mouvement').evaluate().isNotEmpty) {
            return 'Oui';
          }
          return 'Non';
        },
      );

      await tester.tap(find.text('Éléments ayant contribué à la décision'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Réponse positive'), findsOneWidget);
      expect(find.textContaining('liée au mouvement'), findsOneWidget);
    });

    testWidgets('empty contribution section is hidden', (tester) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      expect(find.text('Éléments ayant contribué à la décision'), findsNothing);
    });

    testWidgets('experimental non validated status is visible in summary', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');
      await _scrollUntilText(tester, 'Statut expérimental et version');
      await tester.tap(find.text('Statut expérimental et version'));
      await tester.pumpAndSettle();

      expect(find.textContaining('NON VALIDÉE'), findsOneWidget);
      expect(find.textContaining('0.1-experimental'), findsOneWidget);
    });

    testWidgets('old static summary data is no longer rendered', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      expect(find.text('Marie Dupont'), findsNothing);
      expect(find.text('Télécharger la synthèse (PDF)'), findsNothing);
      expect(find.textContaining('Facteurs rassurants'), findsNothing);
      expect(
        find.textContaining('prise en charge kinésithérapique habituelle'),
        findsNothing,
      );
    });
  });
}

Future<void> _scrollUntilText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    180,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
}

Future<void> _answerUntilSummary(
  WidgetTester tester, {
  String defaultAnswer = 'Non',
  String Function()? answerForCurrentQuestion,
}) async {
  var guard = 0;
  while (find.text('Oui').evaluate().isNotEmpty ||
      find.text('Non').evaluate().isNotEmpty) {
    final label = answerForCurrentQuestion?.call() ?? defaultAnswer;
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    guard++;
    if (guard > 20) {
      throw StateError('Radar summary was not reached.');
    }
  }
}

Future<void> _pumpStartScreen(
  WidgetTester tester, {
  NavigatorObserver? observer,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const RadarClinicalStartScreen(),
      navigatorObservers: [?observer],
    ),
  );
  await tester.pumpAndSettle();
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  int didPushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPushCount += 1;
    super.didPush(route, previousRoute);
  }
}
