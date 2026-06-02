import 'dart:io';

import 'package:drapeaux_rouges_mb/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  void reset() {
    pushCount = 0;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (previousRoute != null) {
      pushCount += 1;
    }
  }
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    tempDir = await Directory.systemTemp.createTemp('home_screen_test_');
    Hive.init(tempDir.path);

    await Hive.openBox('patients_box');
    await Hive.openBox('evaluations_box');
    await Hive.openBox('settings_box');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    NavigatorObserver? navigatorObserver,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [
          if (navigatorObserver != null) navigatorObserver,
        ],
        home: const HomeScreen(),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('shows home screen actions and start button', (tester) async {
    await pumpHomeScreen(tester);

    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('BDK'), findsOneWidget);
    expect(find.text('Prescription'), findsOneWidget);
    expect(find.text('Commencer le dépistage clinique'), findsOneWidget);
  });

  testWidgets('opens patient screen from Patient card', (tester) async {
    final navigatorObserver = TestNavigatorObserver();

    await pumpHomeScreen(tester, navigatorObserver: navigatorObserver);
    navigatorObserver.reset();

    final patientCardSubtitle = find.text('Dossier patient et consentement');
    final patientCard = find.ancestor(
      of: patientCardSubtitle,
      matching: find.byType(InkWell),
    );

    await tester.ensureVisible(patientCardSubtitle);
    await tester.tap(patientCard);
    await tester.pumpAndSettle();

    expect(navigatorObserver.pushCount, 1);
  });

  testWidgets('opens BDK screen from BDK card', (tester) async {
    await pumpHomeScreen(tester);

    await tester.tap(find.text('BDK'));
    await tester.pumpAndSettle();

    expect(find.text('BDK Lombalgie'), findsOneWidget);
  });

  testWidgets('opens prescription screen from Prescription card', (tester) async {
    await pumpHomeScreen(tester);

    await tester.tap(find.text('Prescription'));
    await tester.pumpAndSettle();

    expect(find.text('Rééducation'), findsOneWidget);
  });
}
