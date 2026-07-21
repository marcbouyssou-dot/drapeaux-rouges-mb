import 'package:drapeaux_rouges_mb/features/radar/presentation/radar_demo_shell.dart';
import 'package:drapeaux_rouges_mb/main_radar.dart';
import 'package:drapeaux_rouges_mb/screens/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dedicated Radar entrypoint opens the Radar cockpit directly', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const RadarPreviewApp());
    await tester.pumpAndSettle();

    expect(find.byType(RadarDemoShell), findsOneWidget);
    expect(find.text('Radar'), findsOneWidget);
    expect(find.text('Évaluation clinique'), findsOneWidget);
    expect(find.text('Bilan'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.byType(AuthGate), findsNothing);
  });
}
