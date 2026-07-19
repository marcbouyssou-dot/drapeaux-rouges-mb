import 'package:flutter/material.dart';

import '../../application/radar_clinical_region.dart';
import '../../application/radar_clinical_summary_view_state.dart';
import '../../application/radar_clinical_view_state.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';
import '../widgets/radar_decision_card.dart';
import '../widgets/radar_primary_button.dart';
import '../widgets/radar_secondary_action.dart';

class RadarClinicalSummaryScreen extends StatelessWidget {
  const RadarClinicalSummaryScreen({super.key, this.finalState});

  final RadarClinicalViewState? finalState;

  void _closeSummary(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final summary = finalState?.summary;
    final decision = summary?.decision ?? finalState?.decision;

    return Scaffold(
      backgroundColor: RadarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: RadarSpacing.md),
              children: [
                RadarContextBar(
                  patientName: summary == null
                      ? 'Session Radar'
                      : 'Session ${summary.sessionId}',
                  status: summary == null
                      ? 'Résumé clinique'
                      : 'Région : ${_regionLabel(summary.region)}',
                ),
                const SizedBox(height: RadarSpacing.lg),
                RadarDecisionCard(
                  title: decision?.title ?? 'Résumé clinique',
                  subtitle:
                      summary?.hardStopTitle ??
                      summary?.primaryHypothesisTitle ??
                      _decisionSubtitle(summary),
                  body:
                      decision?.summary ??
                      'Résumé construit à partir des données disponibles.',
                  vigilance: decision?.vigilanceMessage ?? '',
                ),
                const SizedBox(height: RadarSpacing.lg),
                if (summary == null)
                  const _SummarySection(
                    title: 'Parcours clinique réalisé',
                    lines: ['Aucune projection dynamique disponible.'],
                  )
                else ...[
                  if (summary.positiveAnswers.isNotEmpty)
                    _SummarySection(
                      title: 'Éléments ayant contribué à la décision',
                      lines: [
                        for (final answer in summary.positiveAnswers)
                          'Réponse positive : ${answer.text}',
                        for (final flagId in summary.positiveFlagIds)
                          'Signal V5 positif : $flagId',
                      ],
                    ),
                  if (summary.negativeAnswers.isNotEmpty)
                    _SummarySection(
                      title: 'Éléments rassurants ou négatifs utiles',
                      lines: [
                        for (final answer in summary.negativeAnswers)
                          'Élément non retrouvé : ${answer.text}',
                        if (summary.hardStopId == null)
                          'Aucun Hard Stop identifié dans les données recueillies.',
                      ],
                    ),
                  _SummarySection(
                    title: 'Parcours clinique réalisé',
                    lines: [
                      'Région : ${_regionLabel(summary.region)}',
                      'Raison de fin : ${summary.endReason}',
                      if (summary.contextGates.isNotEmpty)
                        'Portes activées : ${summary.contextGates.map((gate) => gate.name).join(', ')}',
                      if (summary.clinicalTriggers.isNotEmpty)
                        'Déclencheurs activés : ${summary.clinicalTriggers.map((trigger) => trigger.name).join(', ')}',
                      if (summary.contextActivations.isNotEmpty)
                        for (final activation in summary.contextActivations)
                          'Activation ${activation.id} via ${activation.source.name}'
                              '${activation.sourceQuestionId == null ? '' : ' après ${activation.sourceQuestionId}'}',
                    ],
                  ),
                  _SummarySection(
                    title: 'Statut expérimental et version',
                    lines: [
                      '${summary.validationStatus} - matrice ${summary.matrixVersion}',
                      'Mode : ${summary.operatingMode.name}',
                      'Moteur : ${summary.engineVersion}',
                    ],
                  ),
                ],
                const SizedBox(height: RadarSpacing.lg),
                RadarPrimaryButton(
                  label: 'Poursuivre la consultation',
                  onPressed: () => _closeSummary(context),
                ),
                const SizedBox(height: RadarSpacing.sm),
                RadarSecondaryAction(
                  label: 'Créer ou compléter le BDK',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _decisionSubtitle(RadarClinicalSummaryViewState? summary) {
    if (summary == null) {
      return 'Données de session non disponibles';
    }

    final level = summary.decisionLevel;
    if (level == null) {
      return 'Décision issue du flow clinique Radar';
    }

    return 'Niveau de décision : ${level.name}';
  }

  String _regionLabel(RadarClinicalRegion region) {
    return switch (region) {
      RadarClinicalRegion.lumbar => 'Lombaires',
      RadarClinicalRegion.cervical => 'Cou',
      RadarClinicalRegion.thoracic => 'Thorax / dos',
      RadarClinicalRegion.shoulderUpperLimbProximal => 'Épaule / bras',
      RadarClinicalRegion.upperLimbDistal => 'Coude / main',
      RadarClinicalRegion.hipLowerLimbProximal => 'Bassin / hanche',
      RadarClinicalRegion.kneeLeg => 'Genou / jambe',
      RadarClinicalRegion.ankleFoot => 'Cheville / pied',
      RadarClinicalRegion.diffuse => 'Douleur diffuse',
    };
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        border: Border.all(color: RadarColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: RadarSpacing.md),
        childrenPadding: const EdgeInsets.fromLTRB(
          RadarSpacing.md,
          0,
          RadarSpacing.md,
          RadarSpacing.md,
        ),
        title: Text(title, style: RadarTextStyles.sectionTitle),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(lines.join('\n\n'), style: RadarTextStyles.muted),
          ),
        ],
      ),
    );
  }
}
