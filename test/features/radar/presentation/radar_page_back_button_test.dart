import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the shared 44px back control and safely pops', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => const Scaffold(body: RadarPageBackButton()),
                ),
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.tooltip, 'Retour');
    expect(
      tester.getSize(find.byType(IconButton)).width,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester.getSize(find.byType(IconButton)).height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('Ouvrir'), findsOneWidget);
  });
}
