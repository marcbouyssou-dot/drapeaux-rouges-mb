import 'package:flutter/material.dart';

import '../../application/radar_clinical_history_recorder.dart';
import '../../application/radar_clinical_hard_stop_view_state.dart';
import '../../application/radar_clinical_region.dart';
import '../../application/radar_clinical_view_state.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_layout.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_patient_context.dart';
import '../widgets/radar_page_header.dart';
import '../widgets/radar_primary_button.dart';
import '../widgets/radar_surface_card.dart';

class RadarClinicalHardStopScreen extends StatelessWidget {
  const RadarClinicalHardStopScreen({
    super.key,
    required this.finalState,
    this.historyRecorder = const RadarClinicalHistoryRecorder(),
  });

  final RadarClinicalViewState finalState;
  final RadarClinicalHistoryRecorder historyRecorder;

  @override
  Widget build(BuildContext context) {
    return _RadarClinicalHardStopScreenBody(
      finalState: finalState,
      historyRecorder: historyRecorder,
    );
  }
}

class _RadarClinicalHardStopScreenBody extends StatefulWidget {
  const _RadarClinicalHardStopScreenBody({
    required this.finalState,
    required this.historyRecorder,
  });

  final RadarClinicalViewState finalState;
  final RadarClinicalHistoryRecorder historyRecorder;

  @override
  State<_RadarClinicalHardStopScreenBody> createState() =>
      _RadarClinicalHardStopScreenBodyState();
}

class _RadarClinicalHardStopScreenBodyState
    extends State<_RadarClinicalHardStopScreenBody> {
  @override
  void initState() {
    super.initState();
    _saveCompletedEvaluation();
  }

  void _saveCompletedEvaluation() {
    widget.historyRecorder
        .saveCompletedEvaluation(widget.finalState)
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Radar history save failed: $error');
        });
  }

  void _returnHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final hardStop = widget.finalState.hardStop;

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
                const Row(
                  children: [
                    RadarPageBackButton(),
                    SizedBox(width: RadarSpacing.md),
                    Expanded(child: RadarPatientContextBar()),
                  ],
                ),
                const SizedBox(height: RadarSpacing.cardGap),
                _HardStopDecisionCard(
                  title:
                      hardStop?.hardStopTitle ??
                      hardStop?.hardStopId ??
                      'Élément prioritaire détecté',
                  explanation: hardStop == null
                      ? 'Le parcours a été interrompu.'
                      : 'Les éléments recueillis justifient l’arrêt de l’évaluation et une orientation médicale adaptée.',
                  recommendation: 'Évaluation médicale urgente recommandée.',
                  clinicalContext: hardStop == null
                      ? const []
                      : ['Statut : ${_hardStopStateLabel(hardStop)}'],
                ),
                if (hardStop != null) ...[
                  if (hardStop.criticalArguments.isNotEmpty) ...[
                    const SizedBox(height: RadarSpacing.xl),
                    _HardStopSection(
                      title: 'Arguments cliniques',
                      lines: hardStop.criticalArguments,
                    ),
                  ],
                  const SizedBox(height: RadarSpacing.md),
                  _HardStopSection(
                    title: 'Contexte clinique',
                    lines: [
                      'Région : ${_regionLabel(hardStop.region)}',
                      'Statut : ${_hardStopStateLabel(hardStop)}',
                    ],
                  ),
                  const SizedBox(height: RadarSpacing.md),
                  _HardStopSection(
                    title: 'Traçabilité technique avancée',
                    lines: [
                      'Session : ${hardStop.sessionId}',
                      'Raison d’arrêt : ${hardStop.stopReason}',
                      if (hardStop.triggeringQuestionId != null)
                        'Question déclenchante : ${hardStop.triggeringQuestionId}',
                      if (hardStop.decisionLevel != null)
                        'Niveau fourni : ${hardStop.decisionLevel!.name}',
                      if (hardStop.clinicalFamilyId != null)
                        'Famille clinique : ${hardStop.clinicalFamilyId}',
                      if (hardStop.contextGates.isNotEmpty)
                        'Portes activées : ${hardStop.contextGates.map((gate) => gate.name).join(', ')}',
                      if (hardStop.clinicalTriggers.isNotEmpty)
                        'Déclencheurs activés : ${hardStop.clinicalTriggers.map((trigger) => trigger.name).join(', ')}',
                      'Moteur : ${hardStop.engineVersion}',
                      'Matrice : ${hardStop.matrixVersion}',
                      hardStop.validationStatus,
                    ],
                  ),
                ],
                const SizedBox(height: RadarSpacing.xl),
                RadarPrimaryButton(
                  label: 'Revenir à l’accueil',
                  onPressed: () => _returnHome(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _hardStopStateLabel(RadarClinicalHardStopViewState hardStop) {
    return switch (hardStop.hardStopState.name) {
      'suspected' => 'suspecté',
      'confirmed' => 'confirmé',
      'absent' => 'absent',
      _ => hardStop.hardStopState.name,
    };
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

class _HardStopDecisionCard extends StatelessWidget {
  const _HardStopDecisionCard({
    required this.title,
    required this.explanation,
    required this.recommendation,
    required this.clinicalContext,
  });

  final String title;
  final String explanation;
  final String recommendation;
  final List<String> clinicalContext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.signature),
        boxShadow: RadarShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadarSpacing.xl),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: RadarColors.clinicalDanger.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(RadarRadius.pill),
                ),
                child: const SizedBox(width: 4),
              ),
              const SizedBox(width: RadarSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HardStopBadge(),
                    const SizedBox(height: RadarSpacing.xl),
                    Text(title, style: RadarTextStyles.sectionTitle),
                    const SizedBox(height: RadarSpacing.cardGap),
                    Text(explanation, style: RadarTextStyles.body),
                    const SizedBox(height: RadarSpacing.cardGap),
                    Text(recommendation, style: RadarTextStyles.contextTitle),
                    if (clinicalContext.isNotEmpty) ...[
                      const SizedBox(height: RadarSpacing.xl),
                      for (final line in clinicalContext)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: RadarSpacing.sm,
                          ),
                          child: Text(line, style: RadarTextStyles.secondary),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HardStopBadge extends StatelessWidget {
  const _HardStopBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.clinicalDanger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadarSpacing.lg,
          vertical: RadarSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              color: RadarColors.clinicalDanger.withValues(alpha: 0.9),
              size: 16,
            ),
            const SizedBox(width: RadarSpacing.sm),
            Flexible(
              child: Text(
                'Urgence médicale',
                style: RadarTextStyles.badge.copyWith(
                  color: RadarColors.clinicalDanger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HardStopSection extends StatefulWidget {
  const _HardStopSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  State<_HardStopSection> createState() => _HardStopSectionState();
}

class _HardStopSectionState extends State<_HardStopSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return RadarSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              borderRadius: BorderRadius.circular(RadarRadius.card),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(RadarSpacing.cardGap),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: RadarTextStyles.contextTitle,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: RadarColors.blueGrey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      RadarSpacing.cardGap,
                      0,
                      RadarSpacing.cardGap,
                      RadarSpacing.cardGap,
                    ),
                    child: Column(
                      children: [
                        for (final line in widget.lines)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: RadarSpacing.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: RadarColors.blueGrey.withValues(
                                        alpha: 0.55,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        RadarSpacing.xs,
                                      ),
                                    ),
                                    child: const SizedBox.square(dimension: 5),
                                  ),
                                ),
                                const SizedBox(width: RadarSpacing.sm),
                                Expanded(
                                  child: Text(
                                    line,
                                    style: RadarTextStyles.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
