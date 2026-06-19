import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/connectivity_service.dart';
import '../../services/offline_session_service.dart';
import '../login_screen.dart';
import '../main_navigation_screen.dart';
import 'first_login_required_screen.dart';

const String appBuildMarker = 'authgate-fix-2026-06-18-1707';

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
  static const Duration authGateTimeout = Duration(seconds: 5);

  late Future<_AuthGateDecision> _decisionFuture;
  String currentStep = 'AUTH_GATE_NOT_STARTED';

  @override
  void initState() {
    super.initState();
    debugPrint('[BOOT][AuthGate] initState()');
    _decisionFuture = decide();
  }

  Future<_AuthGateDecision> decide() async {
    return _decideRoute().timeout(
      authGateTimeout,
      onTimeout: () {
        final message =
            'Timeout AuthGate après ${authGateTimeout.inSeconds}s. '
            'Étape bloquante : $currentStep';
        debugPrint('[BOOT][AuthGate] $message');
        return _AuthGateDecision.diagnostic(
          step: currentStep,
          message: message,
        );
      },
    );
  }

  Future<_AuthGateDecision> _decideRoute() async {
    try {
      _setStep('INITIALIZING CONNECTIVITY');
      widget.connectivityService.startListening();
      final online = widget.connectivityService.isOnline;

      _setStep('LOADING OFFLINE SESSION');
      final session = await widget.sessionService.getSession();

      _setStep('DECIDING ROUTE');
      if (online) {
        debugPrint(
          '[BOOT][AuthGate] route=login online '
          '(offline session is not an online auth token)',
        );
        return _AuthGateDecision.login(
          isOnline: online,
          hasValidOfflineSession: session.isValid,
          sessionExpired: session.isExpired,
        );
      }

      if (session.isValid) {
        debugPrint('[BOOT][AuthGate] route=app offline');
        return _AuthGateDecision.app(
          isOffline: true,
          isOnline: online,
          hasValidOfflineSession: session.isValid,
          sessionExpired: session.isExpired,
        );
      }

      if (session.isExpired) {
        debugPrint('[BOOT][AuthGate] route=renewRequired offline');
        return _AuthGateDecision.renewRequired(
          isOnline: online,
          hasValidOfflineSession: session.isValid,
          sessionExpired: session.isExpired,
        );
      }

      debugPrint('[BOOT][AuthGate] route=firstLoginRequired offline');
      return _AuthGateDecision.firstLoginRequired(
        isOnline: online,
        hasValidOfflineSession: session.isValid,
        sessionExpired: session.isExpired,
      );
    } catch (error, stackTrace) {
      debugPrint('[BOOT][AuthGate] ERROR at $currentStep: $error');
      debugPrint(stackTrace.toString());
      return _AuthGateDecision.diagnostic(
        step: currentStep,
        message: error.toString(),
      );
    }
  }

  void _setStep(String step) {
    currentStep = step;
    debugPrint('[BOOT][AuthGate] $step');
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
            return _buildWithDebugBanner(decision, const LoginScreen());
          case _AuthGateDecisionType.app:
            return _buildWithDebugBanner(
              decision,
              MainNavigationScreen(initialOffline: decision.isOffline),
            );
          case _AuthGateDecisionType.firstLoginRequired:
            return _buildWithDebugBanner(
              decision,
              const FirstLoginRequiredScreen(
                title: 'Première connexion requise',
                message:
                    'Vous devez vous identifier une première fois avec une connexion internet.',
              ),
            );
          case _AuthGateDecisionType.renewRequired:
            return _buildWithDebugBanner(
              decision,
              const FirstLoginRequiredScreen(
                title: 'Connexion requise pour renouveler la session',
                message:
                    'Votre accès hors ligne a expiré. Reconnectez-vous avec une connexion internet.',
              ),
            );
          case _AuthGateDecisionType.diagnostic:
            return _buildWithDebugBanner(
              decision,
              AuthGateDiagnosticScreen(
                step: decision.step ?? currentStep,
                message: decision.message ?? 'Erreur inconnue.',
              ),
            );
        }
      },
    );
  }

  Widget _buildWithDebugBanner(_AuthGateDecision decision, Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _AuthGateDebugBanner(decision: decision),
        ),
      ],
    );
  }
}

enum _AuthGateDecisionType {
  login,
  app,
  firstLoginRequired,
  renewRequired,
  diagnostic,
}

class _AuthGateDecision {
  const _AuthGateDecision._(
    this.type, {
    this.isOffline = false,
    this.isOnline,
    this.hasValidOfflineSession,
    this.sessionExpired,
    this.step,
    this.message,
  });

  factory _AuthGateDecision.login({
    required bool isOnline,
    required bool hasValidOfflineSession,
    required bool sessionExpired,
  }) => _AuthGateDecision._(
    _AuthGateDecisionType.login,
    isOnline: isOnline,
    hasValidOfflineSession: hasValidOfflineSession,
    sessionExpired: sessionExpired,
  );

  factory _AuthGateDecision.app({
    required bool isOffline,
    required bool isOnline,
    required bool hasValidOfflineSession,
    required bool sessionExpired,
  }) => _AuthGateDecision._(
    _AuthGateDecisionType.app,
    isOffline: isOffline,
    isOnline: isOnline,
    hasValidOfflineSession: hasValidOfflineSession,
    sessionExpired: sessionExpired,
  );

  factory _AuthGateDecision.firstLoginRequired({
    required bool isOnline,
    required bool hasValidOfflineSession,
    required bool sessionExpired,
  }) => _AuthGateDecision._(
    _AuthGateDecisionType.firstLoginRequired,
    isOnline: isOnline,
    hasValidOfflineSession: hasValidOfflineSession,
    sessionExpired: sessionExpired,
  );

  factory _AuthGateDecision.renewRequired({
    required bool isOnline,
    required bool hasValidOfflineSession,
    required bool sessionExpired,
  }) => _AuthGateDecision._(
    _AuthGateDecisionType.renewRequired,
    isOnline: isOnline,
    hasValidOfflineSession: hasValidOfflineSession,
    sessionExpired: sessionExpired,
  );

  factory _AuthGateDecision.diagnostic({
    required String step,
    required String message,
  }) => _AuthGateDecision._(
    _AuthGateDecisionType.diagnostic,
    isOnline: null,
    hasValidOfflineSession: null,
    sessionExpired: null,
    step: step,
    message: message,
  );

  final _AuthGateDecisionType type;
  final bool isOffline;
  final bool? isOnline;
  final bool? hasValidOfflineSession;
  final bool? sessionExpired;
  final String? step;
  final String? message;

  String get routeLabel {
    switch (type) {
      case _AuthGateDecisionType.login:
        return 'login';
      case _AuthGateDecisionType.app:
        return isOffline ? 'app-offline' : 'app-online';
      case _AuthGateDecisionType.firstLoginRequired:
        return 'first-login-required';
      case _AuthGateDecisionType.renewRequired:
        return 'renew-required';
      case _AuthGateDecisionType.diagnostic:
        return 'diagnostic';
    }
  }
}

class _AuthGateDebugBanner extends StatelessWidget {
  const _AuthGateDebugBanner({required this.decision});

  final _AuthGateDecision decision;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final text = [
      appBuildMarker,
      'online=${decision.isOnline?.toString() ?? 'unknown'}',
      'route=${decision.routeLabel}',
      'validOffline=${decision.hasValidOfflineSession?.toString() ?? 'unknown'}',
      'expired=${decision.sessionExpired?.toString() ?? 'unknown'}',
    ].join(' · ');

    return Material(
      color: const Color(0xFFE11D48).withValues(alpha: 0.92),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, topPadding + 4, 8, 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            height: 1.2,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class AuthGateDiagnosticScreen extends StatelessWidget {
  const AuthGateDiagnosticScreen({
    super.key,
    required this.step,
    required this.message,
  });

  final String step;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF032052),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.bug_report_outlined,
                            color: Color(0xFF2563EB),
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Diagnostic démarrage offline',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Étape bloquante',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        step,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Message',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
