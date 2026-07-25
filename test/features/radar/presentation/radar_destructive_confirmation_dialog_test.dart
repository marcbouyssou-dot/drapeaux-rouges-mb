import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_destructive_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returns false when destructive dialog is cancelled', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await showRadarDestructiveConfirmationDialog(
                  context,
                  title: 'Supprimer ?',
                  message: 'Cette action est irréversible.',
                  confirmLabel: 'Supprimer',
                );
              },
              child: const Text('Ouvrir'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer ?'), findsOneWidget);
    expect(find.text('Cette action est irréversible.'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('returns true when destructive dialog is confirmed', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await showRadarDestructiveConfirmationDialog(
                  context,
                  title: 'Réinitialiser ?',
                  message: 'Les données locales seront effacées.',
                  confirmLabel: 'Réinitialiser',
                );
              },
              child: const Text('Ouvrir'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
