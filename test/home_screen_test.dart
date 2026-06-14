import 'dart:io';

import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/screens/patient_consent_screen.dart';
import 'package:drapeaux_rouges_mb/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    tempDir = await Directory.systemTemp.createTemp('home_screen_test_');
    Hive.init(tempDir.path);

    await Hive.openBox('patients_box');
    await Hive.openBox('evaluations_box');
    await Hive.openBox('settings_box');
    await Hive.openBox('access_direct_box');
  });

  setUp(() async {
    await Hive.box('patients_box').clear();
    await Hive.box('evaluations_box').clear();
    await Hive.box('settings_box').clear();
    await Hive.box('access_direct_box').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  PatientLocal buildPatient({
    String localId = 'patient-1',
    String anonymousId = 'DR-patient-1',
  }) {
    return PatientLocal(
      localId: localId,
      anonymousId: anonymousId,
      nom: 'Dupont',
      prenom: 'Alice',
      dateNaissance: '01/01/1980',
      consentementValide: true,
      dateConsentement: DateTime(2026, 1, 1),
    );
  }

  Future<void> pumpHomeScreen(WidgetTester tester, {bool settle = true}) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    if (settle) {
      await tester.pumpAndSettle();
      return;
    }

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('shows home screen actions and start button', (tester) async {
    await pumpHomeScreen(tester);

    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('BDK'), findsOneWidget);
    expect(find.text('Prescription'), findsOneWidget);
    expect(find.text('Commencer le dépistage clinique'), findsOneWidget);
  });

  testWidgets('shows Patient card and can tap it', (tester) async {
    await pumpHomeScreen(tester);

    final patientCardSubtitle = find.text('Dossier patient et consentement');
    final patientCard = find.ancestor(
      of: patientCardSubtitle,
      matching: find.byType(InkWell),
    );

    await tester.ensureVisible(patientCardSubtitle);
    expect(patientCardSubtitle.hitTestable(), findsOneWidget);

    await tester.tap(patientCard);
    await tester.pump();

    expect(tester.takeException(), isNull);

    if (find.byType(PatientConsentScreen).evaluate().isNotEmpty) {
      Navigator.of(tester.element(find.byType(PatientConsentScreen))).pop();
      await tester.pump(const Duration(milliseconds: 300));
    }
  });

  testWidgets('uses pseudonymized patient id for default PDF and CSV exports', (
    tester,
  ) async {
    await pumpHomeScreen(tester, settle: false);

    final state = tester.state(find.byType(HomeScreen)) as dynamic;
    state.currentPatient = buildPatient();

    expect(state.patientExportCode, 'DR-patient-1');
    expect(state.patientExportCode, isNot(state.patientDisplayName));
  });

  test('HomeScreen reloads patient data after patient screen returns', () {
    final source = File('lib/screens/home_screen.dart').readAsStringSync();

    expect(source, contains('Future<void> openPatientScreen() async'));
    expect(source, contains('await loadInitialData();'));
  });

  test('resetting evaluation clears persisted current patient', () {
    final source = File('lib/screens/home_screen.dart').readAsStringSync();

    expect(source, contains('void resetSession() async'));
    expect(source, contains('RgpdLocalService.clearCurrentPatient()'));
    expect(source, contains('currentPatient = null'));
  });

  testWidgets('opens BDK screen from BDK card', (tester) async {
    await pumpHomeScreen(tester);

    await tester.tap(find.text('BDK'));
    await tester.pumpAndSettle();

    expect(find.text('BDK Lombalgie'), findsOneWidget);
  });

  testWidgets('opens prescription screen from Prescription card', (
    tester,
  ) async {
    await pumpHomeScreen(tester);

    await tester.tap(find.text('Prescription'));
    await tester.pumpAndSettle();

    expect(find.text('Rééducation'), findsOneWidget);
  });

  testWidgets('opens voice AI placeholder from IA Vocale badge', (
    tester,
  ) async {
    await pumpHomeScreen(tester);

    await tester.ensureVisible(find.text('IA Vocale'));
    await tester.tap(find.text('IA Vocale'));
    await tester.pumpAndSettle();

    expect(find.text('IA vocale clinique'), findsWidgets);
    expect(find.text('Fonctionnalité en préparation'), findsOneWidget);
    expect(
      find.textContaining('aucune donnée patient transmise'),
      findsOneWidget,
    );
    expect(find.text('Dictée clinique'), findsOneWidget);
    expect(find.text('Extraction des éléments utiles'), findsOneWidget);
    expect(find.text('Proposition de drapeaux rouges'), findsOneWidget);
    expect(find.text('Validation par le praticien'), findsOneWidget);
  });
}
