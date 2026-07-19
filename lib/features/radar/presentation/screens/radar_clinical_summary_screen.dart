import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';
import '../widgets/radar_decision_card.dart';
import '../widgets/radar_primary_button.dart';
import '../widgets/radar_secondary_action.dart';

class RadarClinicalSummaryScreen extends StatelessWidget {
  const RadarClinicalSummaryScreen({super.key});

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
              status: 'Synthèse verte',
            ),
            const SizedBox(height: RadarSpacing.lg),
            const RadarDecisionCard(
              title: 'Prise en charge possible',
              subtitle:
                  'Aucun drapeau rouge identifié. La consultation peut se poursuivre avec surveillance clinique habituelle.',
            ),
            const SizedBox(height: RadarSpacing.lg),
            RadarPrimaryButton(
              label: 'Poursuivre la consultation',
              icon: Icons.arrow_forward,
              onPressed: () {},
            ),
            const SizedBox(height: RadarSpacing.sm),
            RadarSecondaryAction(
              label: 'Créer ou compléter le BDK',
              icon: Icons.assignment_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: RadarSpacing.sm),
            RadarSecondaryAction(
              label: 'Télécharger la synthèse (PDF)',
              icon: Icons.picture_as_pdf_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: RadarSpacing.lg),
            const _AnalysisDetails(),
          ],
        ),
      ),
    );
  }
}

class _AnalysisDetails extends StatelessWidget {
  const _AnalysisDetails();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        border: Border.all(color: RadarColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(horizontal: RadarSpacing.md),
        childrenPadding: EdgeInsets.fromLTRB(
          RadarSpacing.md,
          0,
          RadarSpacing.md,
          RadarSpacing.md,
        ),
        title: Text(
          'Voir les détails de l’analyse',
          style: RadarTextStyles.sectionTitle,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Prototype statique Radar. Région : Lombaires. Question : douleur descendant dans une jambe. Synthèse de démonstration : aucun drapeau rouge identifié.',
              style: RadarTextStyles.muted,
            ),
          ),
        ],
      ),
    );
  }
}
