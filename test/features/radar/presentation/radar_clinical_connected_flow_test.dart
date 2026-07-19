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
      expect(find.textContaining('essoufflement brutal'), findsOneWidget);
      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsNothing,
      );
    });
  });
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
