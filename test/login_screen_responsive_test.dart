import 'package:drapeaux_rouges_mb/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('phone landscape keeps login identity and footer visible', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    expect(find.text('URPS'), findsOneWidget);
    expect(find.text('Masseurs Kinésithérapeutes'), findsOneWidget);
    expect(find.text('Nouvelle Aquitaine'), findsOneWidget);
    expect(find.text('Outil d’aide au raisonnement clinique'), findsOneWidget);
    expect(find.text('Données sécurisées • RGPD • HDS'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('tablet landscape keeps wide login layout available', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    expect(find.text('URPS'), findsOneWidget);
    expect(find.text('Données sécurisées • RGPD • HDS'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
