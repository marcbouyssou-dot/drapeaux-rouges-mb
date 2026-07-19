import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_action_card.dart';
import '../widgets/radar_bottom_navigation_bar.dart';
import '../widgets/radar_context_bar.dart';
import '../widgets/radar_primary_button.dart';
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
      bottomNavigationBar: const RadarBottomNavigationBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RadarSpacing.md),
          children: [
            const SizedBox(height: RadarSpacing.sm),
            const Text('Radar', style: RadarTextStyles.display),
            const SizedBox(height: RadarSpacing.xs),
            const Text('Consultation en cours', style: RadarTextStyles.muted),
            const SizedBox(height: RadarSpacing.lg),
            const RadarContextBar(
              patientName: 'Marie Dupont',
              status: 'Consultation en cours',
            ),
            const SizedBox(height: RadarSpacing.lg),
            RadarPrimaryButton(
              label: 'Reprendre la consultation',
              icon: Icons.play_arrow,
              onPressed: () => _openClinicalStart(context),
            ),
            const SizedBox(height: RadarSpacing.lg),
            RadarActionCard(
              title: 'Évaluation clinique',
              subtitle: 'Démarrer le parcours de dépistage Radar',
              icon: Icons.health_and_safety_outlined,
              onTap: () => _openClinicalStart(context),
            ),
            const SizedBox(height: RadarSpacing.md),
            RadarActionCard(
              title: 'Bilan / BDK',
              subtitle: 'Créer ou compléter le bilan de la consultation',
              icon: Icons.assignment_outlined,
              onTap: () {},
            ),
            const SizedBox(height: RadarSpacing.md),
            RadarActionCard(
              title: 'Documents',
              subtitle: 'Synthèses, courriers et exports de consultation',
              icon: Icons.folder_open_outlined,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
