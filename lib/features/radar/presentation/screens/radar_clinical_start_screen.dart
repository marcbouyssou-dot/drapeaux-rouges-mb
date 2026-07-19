import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';
import '../widgets/radar_region_action.dart';
import 'radar_clinical_question_screen.dart';

class RadarClinicalStartScreen extends StatelessWidget {
  const RadarClinicalStartScreen({super.key});

  void _openQuestion(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RadarClinicalQuestionScreen()),
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: RadarSpacing.md),
              children: [
                const RadarContextBar(
                  patientName: 'Marie Dupont',
                  status: 'Consultation en cours',
                ),
                const SizedBox(height: RadarSpacing.lg),
                const Text(
                  'Où se situe le problème ?',
                  style: RadarTextStyles.title,
                ),
                const SizedBox(height: RadarSpacing.sm),
                const Text(
                  'Sélectionnez la région principalement concernée.',
                  style: RadarTextStyles.muted,
                ),
                const SizedBox(height: RadarSpacing.lg),
                _RegionGroup(
                  title: 'TÊTE ET COU',
                  regions: const ['Tête / Face', 'Cou'],
                  onRegionTap: () => _openQuestion(context),
                ),
                _RegionGroup(
                  title: 'MEMBRE SUPÉRIEUR',
                  regions: const ['Épaule / Bras', 'Coude / Main'],
                  onRegionTap: () => _openQuestion(context),
                ),
                _RegionGroup(
                  title: 'TRONC',
                  regions: const ['Thorax', 'Dos', 'Lombaires'],
                  onRegionTap: () => _openQuestion(context),
                ),
                _RegionGroup(
                  title: 'MEMBRE INFÉRIEUR',
                  regions: const [
                    'Bassin / Hanche',
                    'Genou',
                    'Cheville / Pied',
                  ],
                  onRegionTap: () => _openQuestion(context),
                ),
                _RegionGroup(
                  title: 'AUTRE',
                  regions: const ['Autre localisation'],
                  onRegionTap: () => _openQuestion(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionGroup extends StatelessWidget {
  const _RegionGroup({
    required this.title,
    required this.regions,
    required this.onRegionTap,
  });

  final String title;
  final List<String> regions;
  final VoidCallback onRegionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: RadarTextStyles.label),
          const SizedBox(height: 5),
          DecoratedBox(
            decoration: BoxDecoration(
              color: RadarColors.surface,
              border: Border.all(color: RadarColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  for (final region in regions) ...[
                    RadarRegionAction(label: region, onTap: onRegionTap),
                    if (region != regions.last)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: RadarColors.border,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
