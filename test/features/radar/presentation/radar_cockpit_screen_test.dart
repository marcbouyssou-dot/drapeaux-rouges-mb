import 'package:drapeaux_rouges_mb/features/radar/presentation/radar_demo_shell.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_start_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_cockpit_screen.dart';
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
