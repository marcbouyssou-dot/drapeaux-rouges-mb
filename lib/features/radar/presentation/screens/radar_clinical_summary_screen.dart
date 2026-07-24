import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../application/radar_clinical_region.dart';
import '../../application/radar_clinical_summary_view_state.dart';
import '../../application/radar_clinical_view_state.dart';
import '../../../../screens/bdk/bdk_type_screen.dart';
import '../../../../services/bdk_session_service.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_layout.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_patient_context.dart';
import '../widgets/radar_decision_card.dart';

class RadarClinicalSummaryScreen extends StatelessWidget {
  const RadarClinicalSummaryScreen({super.key, this.finalState});

  final RadarClinicalViewState? finalState;

  void _closeSummary(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openBdk(BuildContext context) {
    final summary = finalState?.summary;
    final decision = summary?.decision ?? finalState?.decision;

    BDKSessionService.clear();
    BDKSessionService.loadFromClinicalSummary(
      BDKClinicalPrefill(
        regionLabel: _regionLabel(finalState?.region),
        decisionTitle: decision?.title ?? '',
        decisionSummary: decision?.summary ?? '',
        vigilanceMessage: decision?.vigilanceMessage ?? '',
        clinicalExplanation: summary?.shortExplanation ?? '',
        positiveFindings: [
          for (final answer in summary?.positiveAnswers ?? const [])
            answer.text,
        ],
        negativeFindings: [
          for (final answer in summary?.negativeAnswers ?? const [])
            answer.text,
        ],
      ),
    );
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const BDKTypeScreen()));
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
            constraints: const BoxConstraints(
              maxWidth: RadarLayout.clinicalWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                RadarSpacing.xl,
                RadarSpacing.xxxl,
                RadarSpacing.xl,
                RadarSpacing.xxl,
              ),
              children: [
                const RadarPatientContextBar(),
                const SizedBox(height: RadarSpacing.cardGap),
                const Text(
                  'Synthèse clinique',
                  style: RadarTextStyles.screenTitle,
                ),
                const SizedBox(height: RadarSpacing.cardGap),
                RadarDecisionCard(
                  title: decision?.title ?? 'Résumé clinique',
                  subtitle: _decisionSubtitle(summary),
                  body:
                      decision?.summary ??
                      'Résumé construit à partir des données disponibles.',
                  vigilance: decision?.vigilanceMessage ?? '',
                  decisionLevel:
                      summary?.decisionLevel ?? decision?.decisionLevel,
                  primaryActionLabel: 'Créer ou compléter le BDK',
                  onPrimaryAction: () => _openBdk(context),
                  secondaryActionLabel: 'Poursuivre la consultation',
                  onSecondaryAction: () => _closeSummary(context),
                  details: _SummaryDetails(summary: summary),
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

    return summary.hardStopTitle ??
        summary.primaryHypothesisTitle ??
        'Synthèse établie à partir des éléments recueillis';
  }
}

String _regionLabel(RadarClinicalRegion? region) {
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
    null => '',
  };
}

class _SummaryDetails extends StatelessWidget {
  const _SummaryDetails({required this.summary});

  final RadarClinicalSummaryViewState? summary;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    if (summary == null) {
      return const _SummaryDetailLines(
        title: 'Parcours clinique réalisé',
        lines: ['Aucune projection dynamique disponible.'],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.positiveAnswers.isNotEmpty)
          _SummaryDetailLines(
            title: 'Éléments ayant contribué à la décision',
            lines: [
              for (final answer in summary.positiveAnswers)
                'Réponse positive : ${answer.text}',
            ],
          ),
        if (summary.negativeAnswers.isNotEmpty)
          _SummaryDetailLines(
            title: 'Éléments rassurants ou négatifs utiles',
            lines: [
              for (final answer in summary.negativeAnswers)
                'Élément non retrouvé : ${answer.text}',
              if (summary.hardStopId == null)
                'Aucun Hard Stop identifié dans les données recueillies.',
            ],
          ),
        _SummaryDetailLines(
          title: 'Détails cliniques',
          lines: ['Région : ${_regionLabel(summary.region)}'],
        ),
        _SummaryDetailLines(
          title: 'Traçabilité technique avancée',
          lines: [
            'Session : ${summary.sessionId}',
            'Raison de fin : ${summary.endReason}',
            for (final flagId in summary.positiveFlagIds)
              'Signal clinique positif : $flagId',
            if (summary.contextGates.isNotEmpty)
              'Portes activées : ${summary.contextGates.map((gate) => gate.name).join(', ')}',
            if (summary.clinicalTriggers.isNotEmpty)
              'Déclencheurs activés : ${summary.clinicalTriggers.map((trigger) => trigger.name).join(', ')}',
            if (summary.contextActivations.isNotEmpty)
              for (final activation in summary.contextActivations)
                'Activation ${activation.id} via ${activation.source.name}'
                    '${activation.sourceQuestionId == null ? '' : ' après ${activation.sourceQuestionId}'}',
            '${summary.validationStatus} - matrice ${summary.matrixVersion}',
            'Mode : ${summary.operatingMode.name}',
            'Moteur : ${summary.engineVersion}',
          ],
        ),
      ],
    );
  }
}

class _SummaryDetailLines extends StatelessWidget {
  const _SummaryDetailLines({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: RadarSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: RadarTextStyles.contextTitle),
          const SizedBox(height: RadarSpacing.md),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: RadarSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: RadarColors.blueGrey.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(RadarSpacing.xs),
                      ),
                      child: const SizedBox.square(dimension: 5),
                    ),
                  ),
                  const SizedBox(width: RadarSpacing.sm),
                  Expanded(child: Text(line, style: RadarTextStyles.secondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
