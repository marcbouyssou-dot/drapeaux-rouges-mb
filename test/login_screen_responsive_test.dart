import 'package:drapeaux_rouges_mb/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('small iPhone keeps the Radar login form accessible', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    expect(find.text('Radar'), findsOneWidget);
    expect(find.text('Assistant de raisonnement clinique'), findsOneWidget);
    expect(find.byKey(const Key('login-email-field')), findsOneWidget);
    expect(find.byKey(const Key('login-password-field')), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web width keeps the login card centered and available', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    expect(find.text('Radar'), findsOneWidget);
    expect(find.byKey(const Key('login-submit-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password visibility can be toggled', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    EditableText passwordField() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('login-password-field')),
        matching: find.byType(EditableText),
      ),
    );

    expect(passwordField().obscureText, isTrue);
    await tester.tap(find.byKey(const Key('login-password-visibility')));
    await tester.pump();
    expect(passwordField().obscureText, isFalse);
  });

  testWidgets('empty fields show validation without starting login', (
    tester,
  ) async {
    var callCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          loginAction: (_, _) async {
            callCount++;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pump();

    expect(find.text('Saisissez votre adresse e-mail.'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);
    expect(callCount, 0);
  });
}
