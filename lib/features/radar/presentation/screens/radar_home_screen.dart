import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_layout.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_action_card.dart';
import '../widgets/radar_bottom_navigation_bar.dart';
import '../widgets/radar_context_bar.dart';
import 'radar_clinical_start_screen.dart';

class RadarHomeScreen extends StatelessWidget {
  const RadarHomeScreen({super.key});

  void _openClinicalStart(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RadarClinicalStartScreen()));
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
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RadarSpacing.md,
                      vertical: RadarSpacing.lg,
                    ),
                    children: [
                      const Text('Radar', style: RadarTextStyles.display),
                      const SizedBox(height: RadarSpacing.xs),
                      const Text(
                        'Consultation en cours',
                        style: RadarTextStyles.muted,
                      ),
                      const SizedBox(height: RadarSpacing.xl),
                      const RadarContextBar(
                        patientName: 'Marie Dupont',
                        status: 'Consultation en cours',
                      ),
                      const SizedBox(height: RadarSpacing.md),
                      _ResumeConsultationButton(
                        onPressed: () => _openClinicalStart(context),
                      ),
                      const SizedBox(height: RadarSpacing.xl),
                      RadarActionCard(
                        title: 'Évaluation clinique',
                        subtitle: 'Compatible accès direct',
                        icon: Icons.health_and_safety_outlined,
                        onTap: () => _openClinicalStart(context),
                      ),
                      const SizedBox(height: RadarSpacing.md),
                      RadarActionCard(
                        title: 'Bilan',
                        subtitle: 'BDK',
                        description: 'Créer ou compléter un BDK',
                        icon: Icons.assignment_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(height: RadarSpacing.md),
                      RadarActionCard(
                        title: 'Documents',
                        subtitle: 'Consulter ou créer un document',
                        icon: Icons.folder_open_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const RadarBottomNavigationBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumeConsultationButton extends StatelessWidget {
  const _ResumeConsultationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.play_arrow, size: 17),
        label: const Text('Reprendre la consultation'),
        style: OutlinedButton.styleFrom(
          backgroundColor: RadarColors.surface,
          foregroundColor: RadarColors.primary,
          side: const BorderSide(color: RadarColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
          ),
          textStyle: RadarTextStyles.secondary.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
