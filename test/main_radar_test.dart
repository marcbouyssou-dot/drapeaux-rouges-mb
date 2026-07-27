import 'dart:async';
import 'dart:io';

import 'package:drapeaux_rouges_mb/features/radar/presentation/radar_demo_shell.dart';
import 'package:drapeaux_rouges_mb/main_radar.dart';
import 'package:drapeaux_rouges_mb/screens/auth/radar_auth_gate.dart';
import 'package:drapeaux_rouges_mb/screens/login_screen.dart';
import 'package:drapeaux_rouges_mb/services/offline_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('radar_auth_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('settings_box');
  });

  tearDown(() => Hive.box('settings_box').clear());

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets(
    'dedicated Radar entrypoint starts with its authentication gate',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const RadarPreviewApp());
      await tester.pumpAndSettle();

      expect(find.byType(RadarAuthGate), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(RadarDemoShell), findsNothing);
      expect(find.text('Radar'), findsOneWidget);
      expect(find.text('Assistant de raisonnement clinique'), findsOneWidget);
    },
  );

  testWidgets('valid existing session opens the Radar cockpit', (tester) async {
    await _pumpGate(
      tester,
      sessionService: _FakeSessionService(authenticated: true),
    );

    expect(find.byType(RadarDemoShell), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('successful login replaces login with authenticated content', (
    tester,
  ) async {
    final sessionService = _FakeSessionService(authenticated: false);
    await _pumpGate(tester, sessionService: sessionService);

    await _enterCredentials(tester);
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(sessionService.successfulLoginCount, 1);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(RadarDemoShell), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(RadarDemoShell))).canPop(),
      isFalse,
    );
  });

  testWidgets('login technical error remains visible and blocks navigation', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      sessionService: _FakeSessionService(authenticated: false),
      loginAction: (_, _) async => throw StateError('network error'),
    );

    await _enterCredentials(tester);
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error-message')), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(RadarDemoShell), findsNothing);
  });

  testWidgets('double tap starts only one login operation', (tester) async {
    final pendingLogin = Completer<void>();
    var callCount = 0;
    await _pumpGate(
      tester,
      sessionService: _FakeSessionService(authenticated: false),
      loginAction: (_, _) {
        callCount++;
        return pendingLogin.future;
      },
    );

    await _enterCredentials(tester);
    final button = find.byKey(const Key('login-submit-button'));
    await tester.tap(button);
    await tester.tap(button);
    await tester.pump();

    expect(callCount, 1);
    pendingLogin.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('logout clears session and returns to Radar login', (
    tester,
  ) async {
    final sessionService = _FakeSessionService(authenticated: true);
    await _pumpGate(
      tester,
      sessionService: sessionService,
      authenticatedBuilder: (context, logout) {
        return Scaffold(
          body: FilledButton(
            key: const Key('test-logout-button'),
            onPressed: logout,
            child: const Text('Se déconnecter'),
          ),
        );
      },
    );

    await tester.tap(find.byKey(const Key('test-logout-button')));
    await tester.pumpAndSettle();

    expect(sessionService.clearCount, 1);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

Future<void> _pumpGate(
  WidgetTester tester, {
  required _FakeSessionService sessionService,
  LoginAction? loginAction,
  Widget Function(BuildContext, Future<void> Function())? authenticatedBuilder,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: RadarAuthGate(
        sessionService: sessionService,
        loginAction: loginAction,
        authenticatedBuilder: authenticatedBuilder,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _enterCredentials(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('login-email-field')),
    'kine@example.fr',
  );
  await tester.enterText(
    find.byKey(const Key('login-password-field')),
    'secret',
  );
}

class _FakeSessionService extends OfflineSessionService {
  _FakeSessionService({required this.authenticated});

  bool authenticated;
  int successfulLoginCount = 0;
  int clearCount = 0;

  @override
  Future<OfflineSession> getSession() async {
    final now = DateTime.now();
    return OfflineSession(
      authenticatedOnce: authenticated,
      lastSuccessfulLoginAt: authenticated ? now : null,
      validUntil: authenticated ? now.add(const Duration(days: 1)) : null,
    );
  }

  @override
  Future<void> recordSuccessfulLogin({DateTime? now}) async {
    successfulLoginCount++;
    authenticated = true;
  }

  @override
  Future<void> clearSession() async {
    clearCount++;
    authenticated = false;
  }
}
