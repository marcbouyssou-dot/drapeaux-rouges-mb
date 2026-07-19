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
        child: ListView(
          padding: const EdgeInsets.all(RadarSpacing.md),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Retour',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: RadarColors.mutedInk),
              ),
            ),
            const SizedBox(height: RadarSpacing.sm),
            const RadarContextBar(
              patientName: 'Marie Dupont',
              status: 'Lombaires',
            ),
            const SizedBox(height: RadarSpacing.lg),
            const Text(
              'La douleur descend-elle dans une jambe ?',
              style: RadarTextStyles.title,
            ),
            const SizedBox(height: RadarSpacing.sm),
            const Text(
              'Choisissez la réponse la plus proche des éléments recueillis.',
              style: RadarTextStyles.muted,
            ),
            const SizedBox(height: RadarSpacing.xl),
            RadarQuestionOption(
              label: 'Oui',
              onTap: () => _openSummary(context),
            ),
            const SizedBox(height: RadarSpacing.sm),
            RadarQuestionOption(
              label: 'Non',
              onTap: () => _openSummary(context),
            ),
            const SizedBox(height: RadarSpacing.sm),
            RadarQuestionOption(
              label: 'Des deux côtés',
              onTap: () => _openSummary(context),
            ),
            const SizedBox(height: RadarSpacing.sm),
            RadarQuestionOption(
              label: 'Impossible à préciser',
              onTap: () => _openSummary(context),
            ),
          ],
        ),
      ),
    );
  }
}
