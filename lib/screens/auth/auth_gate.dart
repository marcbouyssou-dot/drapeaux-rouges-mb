import 'package:flutter/material.dart';

import '../../services/connectivity_service.dart';
import '../../services/offline_session_service.dart';
import '../login_screen.dart';
import '../main_navigation_screen.dart';
import 'first_login_required_screen.dart';

class AuthGate extends StatefulWidget {
  AuthGate({
    super.key,
    OfflineSessionService? sessionService,
    ConnectivityService? connectivityService,
  }) : sessionService = sessionService ?? OfflineSessionService(),
       connectivityService =
           connectivityService ?? ConnectivityService.instance;

  final OfflineSessionService sessionService;
  final ConnectivityService connectivityService;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<_AuthGateDecision> _decisionFuture;

  @override
  void initState() {
    super.initState();
    widget.connectivityService.startListening();
    _decisionFuture = decide();
  }

  Future<_AuthGateDecision> decide() async {
    final online = widget.connectivityService.isOnline;
    final session = await widget.sessionService.getSession();

    if (online) {
      if (session.isValid) {
        return _AuthGateDecision.app(isOffline: false);
      }
      return _AuthGateDecision.login();
    }

    if (session.isValid) {
      return _AuthGateDecision.app(isOffline: true);
    }

    if (session.isExpired) {
      return _AuthGateDecision.renewRequired();
    }

    return _AuthGateDecision.firstLoginRequired();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AuthGateDecision>(
      future: _decisionFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF032052),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        final decision = snapshot.data!;
        switch (decision.type) {
          case _AuthGateDecisionType.login:
            return const LoginScreen();
          case _AuthGateDecisionType.app:
            return MainNavigationScreen(initialOffline: decision.isOffline);
          case _AuthGateDecisionType.firstLoginRequired:
            return const FirstLoginRequiredScreen(
              title: 'Première connexion requise',
              message:
                  'Vous devez vous identifier une première fois avec une connexion internet.',
            );
          case _AuthGateDecisionType.renewRequired:
            return const FirstLoginRequiredScreen(
              title: 'Connexion requise pour renouveler la session',
              message:
                  'Votre accès hors ligne a expiré. Reconnectez-vous avec une connexion internet.',
            );
        }
      },
    );
  }
}

enum _AuthGateDecisionType { login, app, firstLoginRequired, renewRequired }

class _AuthGateDecision {
  const _AuthGateDecision._(this.type, {this.isOffline = false});

  factory _AuthGateDecision.login() =>
      const _AuthGateDecision._(_AuthGateDecisionType.login);

  factory _AuthGateDecision.app({required bool isOffline}) =>
      _AuthGateDecision._(_AuthGateDecisionType.app, isOffline: isOffline);

  factory _AuthGateDecision.firstLoginRequired() =>
      const _AuthGateDecision._(_AuthGateDecisionType.firstLoginRequired);

  factory _AuthGateDecision.renewRequired() =>
      const _AuthGateDecision._(_AuthGateDecisionType.renewRequired);

  final _AuthGateDecisionType type;
  final bool isOffline;
}
