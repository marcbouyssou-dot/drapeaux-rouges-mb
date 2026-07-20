import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_action_card.dart';
import '../widgets/radar_bottom_navigation_bar.dart';
import '../widgets/radar_context_bar.dart';
import 'radar_clinical_start_screen.dart';

class RadarCockpitScreen extends StatelessWidget {
  const RadarCockpitScreen({super.key});

  void _openClinicalStart(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RadarClinicalStartScreen()));
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction disponible prochainement')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RadarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
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
                                  const RadarContextBar(
                                    patientName: 'Aucun patient sélectionné',
                                    status: 'Contexte patient neutre',
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
                                  const SizedBox(height: RadarSpacing.xl),
                                  RadarActionCard(
                                    title: 'Bilan',
                                    subtitle: 'BDK',
                                    description: 'Créer ou compléter un bilan',
                                    icon: Icons.assignment_outlined,
                                    accentColor: RadarColors.indigo,
                                    onTap: () => _showComingSoon(context),
                                  ),
                                  const SizedBox(height: RadarSpacing.xl),
                                  RadarActionCard(
                                    title: 'Documents',
                                    subtitle: 'Créer un document clinique',
                                    icon: Icons.folder_open_outlined,
                                    accentColor: RadarColors.slate,
                                    onTap: () => _showComingSoon(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: RadarSpacing.xl),
                    child: RadarBottomNavigationBar(currentIndex: 0),
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
            style: RadarTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
