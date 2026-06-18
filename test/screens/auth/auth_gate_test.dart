import 'dart:io';

import 'package:drapeaux_rouges_mb/screens/auth/auth_gate.dart';
import 'package:drapeaux_rouges_mb/screens/auth/first_login_required_screen.dart';
import 'package:drapeaux_rouges_mb/screens/login_screen.dart';
import 'package:drapeaux_rouges_mb/screens/main_navigation_screen.dart';
import 'package:drapeaux_rouges_mb/services/connectivity_service.dart';
import 'package:drapeaux_rouges_mb/services/offline_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    tempDir = await Directory.systemTemp.createTemp('auth_gate_test_');
    Hive.init(tempDir.path);

    await Hive.openBox('patients_box');
    await Hive.openBox('evaluations_box');
    await Hive.openBox('settings_box');
    await Hive.openBox('access_direct_box');
  });

  tearDown(() async {
    ConnectivityService.instance.clearTestOverride();
    await Hive.box('patients_box').clear();
    await Hive.box('evaluations_box').clear();
    await Hive.box('settings_box').clear();
    await Hive.box('access_direct_box').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('offline with valid local session opens the app', (tester) async {
    ConnectivityService.instance.emitStatusForTests(false);

    await pumpAuthGate(tester, session: validSession());

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('offline without previous login shows first login required', (
    tester,
  ) async {
    ConnectivityService.instance.emitStatusForTests(false);

    await pumpAuthGate(
      tester,
      session: const OfflineSession(
        authenticatedOnce: false,
        lastSuccessfulLoginAt: null,
        validUntil: null,
      ),
    );

    expect(find.byType(FirstLoginRequiredScreen), findsOneWidget);
    expect(find.text('Première connexion requise'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('online without local session shows login screen', (
    tester,
  ) async {
    ConnectivityService.instance.emitStatusForTests(true);

    await pumpAuthGate(
      tester,
      session: const OfflineSession(
        authenticatedOnce: false,
        lastSuccessfulLoginAt: null,
        validUntil: null,
      ),
    );

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('online with expired session shows login screen', (tester) async {
    ConnectivityService.instance.emitStatusForTests(true);

    await pumpAuthGate(tester, session: expiredSession());

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('offline with expired session asks for renewal', (tester) async {
    ConnectivityService.instance.emitStatusForTests(false);

    await pumpAuthGate(tester, session: expiredSession());

    expect(find.byType(FirstLoginRequiredScreen), findsOneWidget);
    expect(
      find.text('Connexion requise pour renouveler la session'),
      findsOneWidget,
    );
    expect(find.byType(LoginScreen), findsNothing);
  });
}

Future<void> pumpAuthGate(
  WidgetTester tester, {
  required OfflineSession session,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: AuthGate(
        sessionService: _FakeOfflineSessionService(session),
        connectivityService: ConnectivityService.instance,
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

OfflineSession validSession() {
  final now = DateTime.now();
  return OfflineSession(
    authenticatedOnce: true,
    lastSuccessfulLoginAt: now.subtract(const Duration(days: 1)),
    validUntil: now.add(const Duration(days: 30)),
  );
}

OfflineSession expiredSession() {
  final now = DateTime.now();
  return OfflineSession(
    authenticatedOnce: true,
    lastSuccessfulLoginAt: now.subtract(const Duration(days: 120)),
    validUntil: now.subtract(const Duration(days: 1)),
  );
}

class _FakeOfflineSessionService extends OfflineSessionService {
  _FakeOfflineSessionService(this.session);

  final OfflineSession session;

  @override
  Future<OfflineSession> getSession() async => session;
}
