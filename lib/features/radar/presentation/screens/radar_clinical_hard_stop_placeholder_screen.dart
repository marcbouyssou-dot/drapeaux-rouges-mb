import 'package:flutter/material.dart';

import '../../application/radar_clinical_view_state.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';

class RadarClinicalHardStopPlaceholderScreen extends StatelessWidget {
  const RadarClinicalHardStopPlaceholderScreen({
    super.key,
    required this.finalState,
  });

  final RadarClinicalViewState finalState;

  @override
  Widget build(BuildContext context) {
    final decision = finalState.decision;

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
                const SizedBox(height: RadarSpacing.xl),
                const Text('ÉVALUATION CLINIQUE', style: RadarTextStyles.label),
                const SizedBox(height: RadarSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: RadarColors.surface,
                    border: Border.all(color: RadarColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(RadarSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.priority_high,
                          color: RadarColors.primary,
                          size: 28,
                        ),
                        const SizedBox(height: RadarSpacing.md),
                        Text(
                          decision?.title ?? 'Orientation prioritaire',
                          style: RadarTextStyles.title,
                        ),
                        const SizedBox(height: RadarSpacing.sm),
                        Text(
                          decision?.summary ??
                              'Un élément prioritaire a été identifié par le questionnaire.',
                          style: RadarTextStyles.body,
                        ),
                        const SizedBox(height: RadarSpacing.md),
                        Text(
                          decision?.vigilanceMessage ??
                              'Suivre la conduite adaptée avant de poursuivre.',
                          style: RadarTextStyles.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
