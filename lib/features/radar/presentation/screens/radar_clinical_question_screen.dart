import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';
import '../widgets/radar_question_option.dart';
import 'radar_clinical_summary_screen.dart';

class RadarClinicalQuestionScreen extends StatelessWidget {
  const RadarClinicalQuestionScreen({super.key});

  void _openSummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RadarClinicalSummaryScreen()),
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
                const SizedBox(height: RadarSpacing.xl),
                const Text('ÉVALUATION CLINIQUE', style: RadarTextStyles.label),
                const SizedBox(height: RadarSpacing.lg),
                const Text(
                  'La douleur descend-elle dans une jambe ?',
                  style: RadarTextStyles.title,
                ),
                const SizedBox(height: RadarSpacing.xl),
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
                        RadarQuestionOption(
                          label: 'Oui',
                          onTap: () => _openSummary(context),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: RadarColors.border,
                        ),
                        RadarQuestionOption(
                          label: 'Non',
                          onTap: () => _openSummary(context),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: RadarColors.border,
                        ),
                        RadarQuestionOption(
                          label: 'Des deux côtés',
                          onTap: () => _openSummary(context),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: RadarColors.border,
                        ),
                        RadarQuestionOption(
                          label: 'Impossible à préciser',
                          onTap: () => _openSummary(context),
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
