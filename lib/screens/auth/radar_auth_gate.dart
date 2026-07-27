import 'package:flutter/material.dart';

import '../../features/radar/presentation/radar_demo_shell.dart';
import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../services/bdk_session_service.dart';
import '../../services/offline_session_service.dart';
import '../../services/rgpd_local_service.dart';
import '../login_screen.dart';

class RadarAuthGate extends StatefulWidget {
  RadarAuthGate({
    super.key,
    OfflineSessionService? sessionService,
    this.loginAction,
    this.authenticatedBuilder,
  }) : sessionService = sessionService ?? OfflineSessionService();

  final OfflineSessionService sessionService;
  final LoginAction? loginAction;
  final Widget Function(BuildContext context, Future<void> Function() logout)?
  authenticatedBuilder;

  @override
  State<RadarAuthGate> createState() => _RadarAuthGateState();
}

class _RadarAuthGateState extends State<RadarAuthGate> {
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await widget.sessionService.getSession();
    if (!mounted) return;
    setState(() {
      _isAuthenticated = session.isValid;
    });
  }

  void _handleAuthenticated() {
    if (!mounted) return;
    setState(() {
      _isAuthenticated = true;
    });
  }

  Future<void> _handleLogout() async {
    await RgpdLocalService.clearCurrentPatient();
    BDKSessionService.clear();
    await widget.sessionService.clearSession();
    if (!mounted) return;
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = _isAuthenticated;
    if (isAuthenticated == null) {
      return const Scaffold(
        backgroundColor: RadarColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isAuthenticated) {
      return LoginScreen(
        sessionService: widget.sessionService,
        loginAction: widget.loginAction,
        onAuthenticated: _handleAuthenticated,
      );
    }

    final authenticatedBuilder = widget.authenticatedBuilder;
    if (authenticatedBuilder != null) {
      return authenticatedBuilder(context, _handleLogout);
    }

    return RadarDemoShell(onLogout: _handleLogout);
  }
}
