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
              status: 'Consultation en cours',
            ),
            const SizedBox(height: RadarSpacing.lg),
            const Text('Groupes anatomiques', style: RadarTextStyles.title),
            const SizedBox(height: RadarSpacing.sm),
            const Text(
              'Sélectionnez la région concernée pour orienter le questionnaire.',
              style: RadarTextStyles.muted,
            ),
            const SizedBox(height: RadarSpacing.lg),
            RadarRegionAction(
              label: 'Lombaires',
              selected: true,
              onTap: () => _openQuestion(context),
            ),
            const SizedBox(height: RadarSpacing.sm),
            RadarRegionAction(label: 'Cervicales', onTap: () {}),
            const SizedBox(height: RadarSpacing.sm),
            RadarRegionAction(label: 'Épaule', onTap: () {}),
            const SizedBox(height: RadarSpacing.sm),
            RadarRegionAction(label: 'Genou', onTap: () {}),
            const SizedBox(height: RadarSpacing.sm),
            RadarRegionAction(label: 'Cheville / pied', onTap: () {}),
          ],
        ),
      ),
    );
  }
}
