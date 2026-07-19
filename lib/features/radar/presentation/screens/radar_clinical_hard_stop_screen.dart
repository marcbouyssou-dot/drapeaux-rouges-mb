import 'package:flutter/material.dart';

import '../../application/radar_clinical_hard_stop_view_state.dart';
import '../../application/radar_clinical_region.dart';
import '../../application/radar_clinical_view_state.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';
import '../widgets/radar_primary_button.dart';

class RadarClinicalHardStopScreen extends StatelessWidget {
  const RadarClinicalHardStopScreen({super.key, required this.finalState});

  final RadarClinicalViewState finalState;

  void _returnHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final hardStop = finalState.hardStop;

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
                  patientName: hardStop == null
                      ? 'Session Radar'
                      : 'Session ${hardStop.sessionId}',
                  status: hardStop == null
                      ? 'Parcours interrompu'
                      : 'Région : ${_regionLabel(hardStop.region)}',
                ),
                const SizedBox(height: RadarSpacing.xl),
                const Text(
                  'ARRÊT DU PARCOURS CLINIQUE',
                  style: RadarTextStyles.label,
                ),
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
                          hardStop?.hardStopTitle ??
                              hardStop?.hardStopId ??
                              'Élément prioritaire détecté',
                          style: RadarTextStyles.title,
                        ),
                        const SizedBox(height: RadarSpacing.sm),
                        Text(
                          hardStop == null
                              ? 'Le parcours a été interrompu.'
                              : 'Le parcours a été interrompu par le moteur clinique V5.',
                          style: RadarTextStyles.body,
                        ),
                        if (hardStop != null) ...[
                          const SizedBox(height: RadarSpacing.md),
                          Text(
                            'Statut : ${_hardStopStateLabel(hardStop)}',
                            style: RadarTextStyles.muted,
                          ),
                          if (hardStop.hardStopId != null) ...[
                            const SizedBox(height: RadarSpacing.sm),
                            Text(
                              'Identifiant : ${hardStop.hardStopId}',
                              style: RadarTextStyles.muted,
                            ),
                          ],
                          if (hardStop.decisionLevel != null) ...[
                            const SizedBox(height: RadarSpacing.sm),
                            Text(
                              'Niveau fourni : ${hardStop.decisionLevel!.name}',
                              style: RadarTextStyles.muted,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                if (hardStop != null) ...[
                  if (hardStop.criticalArguments.isNotEmpty) ...[
                    const SizedBox(height: RadarSpacing.lg),
                    _HardStopSection(
                      title: 'Données ayant contribué à l’arrêt',
                      lines: hardStop.criticalArguments,
                    ),
                  ],
                  const SizedBox(height: RadarSpacing.lg),
                  _HardStopSection(
                    title: 'Contexte et traçabilité',
                    lines: [
                      'Région : ${_regionLabel(hardStop.region)}',
                      'Raison d’arrêt : ${hardStop.stopReason}',
                      if (hardStop.triggeringQuestionId != null)
                        'Question déclenchante : ${hardStop.triggeringQuestionId}',
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
                const SizedBox(height: RadarSpacing.lg),
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

class _HardStopSection extends StatelessWidget {
  const _HardStopSection({required this.title, required this.lines});

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
