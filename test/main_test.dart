import 'dart:io';

import 'package:drapeaux_rouges_mb/features/radar/presentation/radar_demo_shell.dart';
import 'package:drapeaux_rouges_mb/main.dart';
import 'package:drapeaux_rouges_mb/screens/auth/auth_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RedFlagsApp initial route', () {
    testWidgets('opens RadarDemoShell for the debug radar route', (
      tester,
    ) async {
      await tester.pumpWidget(
        const RedFlagsApp(initialRouteName: kRadarDemoRoute),
      );

      expect(find.byType(RadarDemoShell), findsOneWidget);
      expect(find.byType(AuthGate), findsNothing);
    });

    testWidgets('keeps AuthGate for the normal route', (tester) async {
      await tester.pumpWidget(const RedFlagsApp(initialRouteName: '/'));

      expect(find.byType(AuthGate), findsOneWidget);
      expect(find.byType(RadarDemoShell), findsNothing);
    });

    test('keeps root routing outside clinical layers', () {
      final source = File('lib/main.dart').readAsStringSync();

      expect(source, contains('kRadarDemoRoute'));
      expect(source, isNot(contains('/application/')));
      expect(source, isNot(contains('/domain/')));
      expect(source, isNot(contains('ClinicalAdaptiveQuestionEngineV5')));
      expect(source, isNot(contains('RadarRegionalClinicalOrchestrator')));
    });
  });
}
