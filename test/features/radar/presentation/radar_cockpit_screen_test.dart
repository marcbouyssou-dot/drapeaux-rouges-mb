import 'dart:io';

import 'package:drapeaux_rouges_mb/features/radar/presentation/radar_demo_shell.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_start_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_cockpit_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_colors.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_context_bar.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_patient_context.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/screens/bdk/bdk_type_screen.dart';
import 'package:drapeaux_rouges_mb/screens/history_screen.dart';
import 'package:drapeaux_rouges_mb/screens/patient_consent_screen.dart';
import 'package:drapeaux_rouges_mb/screens/prescription/prescription_type_screen.dart';
import 'package:drapeaux_rouges_mb/screens/settings_screen.dart';
import 'package:drapeaux_rouges_mb/services/rgpd_local_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('Radar cockpit screen', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'radar_cockpit_patient_test_',
      );
      Hive.init(tempDir.path);
      await Hive.openBox('patients_box');
      await Hive.openBox('evaluations_box');
      await Hive.openBox('settings_box');
      await Hive.openBox('access_direct_box');
      await Hive.openBox('prescriptions_box');
      await Hive.openBox('attestations_box');
      await Hive.openBox('medical_letters_box');
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    testWidgets('displays the three activities and bottom navigation', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      expect(find.text('Radar'), findsOneWidget);
      expect(
        find.text('Assistant clinique du kinésithérapeute'),
        findsOneWidget,
      );
      expect(find.text('Consultation en cours'), findsOneWidget);
      expect(find.text('Patient non associé'), findsOneWidget);
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
      expect(find.byType(RadarPatientContextBar), findsOneWidget);
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

    testWidgets('opens the historical patient workflow from patient context', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.tap(find.byType(RadarPatientContextBar));
      await tester.pumpAndSettle();

      expect(find.byType(PatientConsentScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'refreshes patient context after the patient workflow returns',
      (tester) async {
        final patient = PatientLocal(
          localId: 'patient-alice-dupont',
          anonymousId: 'DR-alice-dupont',
          nom: 'Dupont',
          prenom: 'Alice',
          dateNaissance: '12/03/1981',
          consentementValide: true,
          dateConsentement: DateTime(2026, 1, 12),
        );
        await tester.runAsync(() async {
          await RgpdLocalService.saveOrUpdatePatient(patient);
          await RgpdLocalService.clearCurrentPatient();
        });
        final savedPatients = await tester.runAsync(
          RgpdLocalService.getPatients,
        );
        expect(savedPatients, hasLength(1));

        await _pumpCockpit(tester, settle: false);

        expect(find.text('Consultation en cours'), findsOneWidget);
        expect(find.text('Patient non associé'), findsOneWidget);
        expect(find.text('DUPONT Alice'), findsNothing);

        await tester.tap(find.byType(RadarPatientContextBar));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        await _drainRealAsync(tester);

        expect(find.byType(PatientConsentScreen), findsOneWidget);
        await tester.runAsync(() async {
          await RgpdLocalService.setCurrentPatientId(patient.localId);
        });
        final selectedPatient = await tester.runAsync(
          RgpdLocalService.getCurrentPatient,
        );
        expect(selectedPatient, isNotNull);

        Navigator.of(tester.element(find.byType(PatientConsentScreen))).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        await _drainRealAsync(tester);

        expect(find.byType(RadarCockpitScreen), findsOneWidget);
        expect(find.text('DUPONT Alice'), findsOneWidget);
        expect(find.text('Consultation en cours'), findsOneWidget);
        expect(find.text('Patient non associé'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Bilan opens the historical BDK workflow', (tester) async {
      await _pumpCockpit(tester);

      await tester.ensureVisible(find.text('Bilan'));
      await tester.tap(find.text('Bilan'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BDKTypeScreen), findsOneWidget);
      expect(find.text('BDK Lombalgie'), findsOneWidget);
    });

    testWidgets('a rapid double tap opens only one BDK workflow', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.ensureVisible(find.text('Bilan'));
      await tester.tap(find.text('Bilan'));
      await tester.tap(find.text('Bilan'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(BDKTypeScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(BDKTypeScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(RadarCockpitScreen), findsOneWidget);
    });

    testWidgets('Documents opens the historical document workflow', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.ensureVisible(find.text('Documents'));
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(PrescriptionTypeScreen), findsOneWidget);
      expect(find.text('Rééducation'), findsOneWidget);
    });

    testWidgets('Historique opens the historical history workflow', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('Bilans'), findsWidgets);
    });

    testWidgets('Réglages opens the historical settings workflow', (
      tester,
    ) async {
      await _pumpCockpit(tester);

      await tester.tap(find.text('Réglages'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Informations MK'), findsOneWidget);
    });
  });
}

Future<void> _drainRealAsync(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(Duration.zero);
  });
  await tester.pump();
}

Future<void> _pumpCockpit(WidgetTester tester, {bool settle = true}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(const MaterialApp(home: RadarDemoShell()));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await _drainRealAsync(tester);
  }

  expect(find.byType(RadarCockpitScreen), findsOneWidget);
}
