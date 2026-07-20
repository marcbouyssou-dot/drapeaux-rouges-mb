import 'package:drapeaux_rouges_mb/features/radar/presentation/radar_demo_shell.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_start_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_cockpit_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_colors.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_context_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Radar cockpit screen', () {
    testWidgets('displays the three activities and bottom navigation', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      expect(find.text('Radar'), findsOneWidget);
      expect(
        find.text('Assistant clinique du kinésithérapeute'),
        findsOneWidget,
      );
      expect(find.text('Aucun patient sélectionné'), findsOneWidget);
      expect(find.text('Évaluation clinique'), findsOneWidget);
      expect(find.text('Détecter les situations à risque'), findsOneWidget);
      expect(find.text('Compatible accès direct'), findsOneWidget);
      expect(find.text('Bilan'), findsOneWidget);
      expect(find.text('BDK'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Créer un document clinique'), findsOneWidget);
      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
      expect(find.text('Réglages'), findsOneWidget);
    });

    testWidgets('uses a neutral patient context without clinical green', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      final contextBar = find.byType(RadarContextBar);
      expect(contextBar, findsOneWidget);
      expect(
        find.descendant(
          of: contextBar,
          matching: find.byIcon(Icons.person_outline),
        ),
        findsOneWidget,
      );

      final decorations = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: contextBar,
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((widget) => widget.decoration)
          .whereType<BoxDecoration>();

      expect(
        decorations.any(
          (decoration) => decoration.color == RadarColors.success,
        ),
        isFalse,
      );
      expect(
        decorations.any(
          (decoration) => decoration.color == RadarColors.clinicalSuccess,
        ),
        isFalse,
      );
    });

    testWidgets(
      'keeps the cockpit free of overflow with standard text scaling',
      (tester) async {
        await _pumpCockpit(tester);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('supports a reasonably increased text scaler', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(1.2),
            ),
            child: const RadarDemoShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RadarCockpitScreen), findsOneWidget);
      expect(find.text('Évaluation clinique'), findsOneWidget);
      expect(find.text('Bilan'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens the existing clinical flow from clinical evaluation', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.tap(find.text('Évaluation clinique'));
      await tester.pumpAndSettle();

      expect(find.byType(RadarClinicalStartScreen), findsOneWidget);
      expect(find.text('Où se situe le problème ?'), findsOneWidget);
    });

    testWidgets('Bilan is clickable and shows a sober feedback', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.ensureVisible(find.text('Bilan'));
      await tester.tap(find.text('Bilan'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Fonction disponible prochainement'), findsOneWidget);
    });

    testWidgets('Documents is clickable and shows a sober feedback', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.ensureVisible(find.text('Documents'));
      await tester.tap(find.text('Documents'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Fonction disponible prochainement'), findsOneWidget);
    });
  });
}

Future<void> _pumpCockpit(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(const MaterialApp(home: RadarDemoShell()));
  await tester.pumpAndSettle();

  expect(find.byType(RadarCockpitScreen), findsOneWidget);
}
