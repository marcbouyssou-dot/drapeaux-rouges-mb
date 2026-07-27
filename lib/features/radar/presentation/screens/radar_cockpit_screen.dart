import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../screens/bdk/bdk_type_screen.dart';
import '../../../../screens/history_screen.dart';
import '../../../../screens/patient_consent_screen.dart';
import '../../../../screens/prescription/prescription_type_screen.dart';
import '../../../../screens/settings_screen.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_layout.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_action_card.dart';
import '../widgets/radar_bottom_navigation_bar.dart';
import '../widgets/radar_patient_context.dart';
import 'radar_clinical_start_screen.dart';

class RadarCockpitScreen extends StatefulWidget {
  const RadarCockpitScreen({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  State<RadarCockpitScreen> createState() => _RadarCockpitScreenState();
}

class _RadarCockpitScreenState extends State<RadarCockpitScreen> {
  int _patientContextVersion = 0;
  bool _navigationPending = false;

  Future<void> _openClinicalStart(BuildContext context) async {
    await _pushOnce(
      context,
      MaterialPageRoute(builder: (_) => const RadarClinicalStartScreen()),
    );
  }

  Future<void> _openPatientScreen(BuildContext context) async {
    final opened = await _pushOnce(
      context,
      MaterialPageRoute(builder: (_) => const PatientConsentScreen()),
    );

    if (!opened || !mounted) return;

    setState(() {
      _patientContextVersion++;
    });
  }

  Future<void> _openBdkTypeScreen(BuildContext context) async {
    await _pushOnce(
      context,
      CupertinoPageRoute(builder: (_) => const BDKTypeScreen()),
    );
  }

  Future<void> _openPrescriptionTypeScreen(BuildContext context) async {
    await _pushOnce(
      context,
      CupertinoPageRoute(builder: (_) => const PrescriptionTypeScreen()),
    );
  }

  Future<void> _openHistoryScreen(BuildContext context) async {
    await _pushOnce(
      context,
      CupertinoPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  Future<void> _openSettingsScreen(BuildContext context) async {
    await _pushOnce(
      context,
      CupertinoPageRoute(
        builder: (_) => SettingsScreen(onLogout: widget.onLogout),
      ),
    );
  }

  Future<bool> _pushOnce<T>(BuildContext context, Route<T> route) async {
    if (_navigationPending) return false;
    _navigationPending = true;
    try {
      await Navigator.of(context).push<T>(route);
      return true;
    } finally {
      _navigationPending = false;
    }
  }

  void _onBottomNavigationSelected(BuildContext context, int index) {
    if (index == 1) {
      _openHistoryScreen(context);
      return;
    }

    if (index == 2) {
      _openSettingsScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RadarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: RadarLayout.clinicalWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RadarSpacing.xl),
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: RadarSpacing.xxxl,
                                bottom: RadarSpacing.xxl,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _RadarCockpitHeader(),
                                  const SizedBox(height: RadarSpacing.xxl),
                                  RadarPatientContextBar(
                                    key: ValueKey(_patientContextVersion),
                                    onTap: () => _openPatientScreen(context),
                                  ),
                                  const SizedBox(height: RadarSpacing.xxl),
                                  RadarActionCard(
                                    title: 'Évaluation clinique',
                                    subtitle:
                                        'Détecter les situations à risque',
                                    description: 'Compatible accès direct',
                                    icon: Icons.health_and_safety_outlined,
                                    accentColor: RadarColors.primary,
                                    onTap: () => _openClinicalStart(context),
                                  ),
                                  const SizedBox(height: RadarSpacing.lg),
                                  RadarActionCard(
                                    title: 'Bilan',
                                    subtitle: 'BDK',
                                    description: 'Créer ou compléter un bilan',
                                    icon: Icons.assignment_outlined,
                                    accentColor: RadarColors.indigo,
                                    onTap: () => _openBdkTypeScreen(context),
                                  ),
                                  const SizedBox(height: RadarSpacing.lg),
                                  RadarActionCard(
                                    title: 'Documents',
                                    subtitle: 'Créer un document clinique',
                                    icon: Icons.folder_open_outlined,
                                    accentColor: RadarColors.slate,
                                    onTap: () =>
                                        _openPrescriptionTypeScreen(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: RadarSpacing.xl),
                    child: RadarBottomNavigationBar(
                      currentIndex: 0,
                      onDestinationSelected: (index) =>
                          _onBottomNavigationSelected(context, index),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarCockpitHeader extends StatelessWidget {
  const _RadarCockpitHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadarRadius.signature),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Radar', style: RadarTextStyles.screenTitle),
          SizedBox(height: RadarSpacing.xs),
          Text(
            'Assistant clinique du kinésithérapeute',
            style: RadarTextStyles.secondary,
          ),
        ],
      ),
    );
  }
}
