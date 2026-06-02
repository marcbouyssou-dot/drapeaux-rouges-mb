import 'dart:io';

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
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
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
    await pumpHomeScreen(tester);

    await tester.tap(find.text('Patient'));
    await tester.pumpAndSettle();

    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);
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
