import 'package:flutter/material.dart';

import '../../application/radar_clinical_pathway_definition.dart';
import '../../application/radar_clinical_region.dart';
import '../../application/radar_clinical_session_controller.dart';
import '../../application/radar_regional_clinical_orchestrator.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_layout.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_patient_context.dart';
import '../widgets/radar_page_header.dart';
import '../widgets/radar_region_action.dart';
import 'radar_clinical_question_screen.dart';

class RadarClinicalStartScreen extends StatelessWidget {
  const RadarClinicalStartScreen({
    super.key,
    this.initialContext = const RadarClinicalInitialContext(),
  });

  final RadarClinicalInitialContext initialContext;

  void _openQuestion(BuildContext context, RadarClinicalRegion region) {
    final orchestrator = RadarRegionalClinicalOrchestrator();
    final controller = RadarClinicalSessionController(
      orchestrator: orchestrator,
    );
    final initialState = controller.startSession(
      region: region,
      initialContext: initialContext,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RadarClinicalQuestionScreen(
          controller: controller,
          initialState: initialState,
        ),
      ),
    );
  }

  void _handleRegionTap(BuildContext context, _RadarRegionOption option) {
    _openQuestion(context, option.region);
  }

  @override
  Widget build(BuildContext context) {
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
                RadarSpacing.xl,
                RadarSpacing.xl,
                RadarSpacing.xl,
              ),
              children: [
                const Row(
                  children: [
                    RadarPageBackButton(),
                    SizedBox(width: RadarSpacing.md),
                    Expanded(child: RadarPatientContextBar()),
                  ],
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
                  regions: const [
                    // Tête / Face reste masquée en RC1 tant qu'aucun parcours
                    // clinique fonctionnel ne lui est associé.
                    _RadarRegionOption('Cou', RadarClinicalRegion.cervical),
                  ],
                  onRegionTap: (option) => _handleRegionTap(context, option),
                ),
                _RegionGroup(
                  title: 'MEMBRE SUPÉRIEUR',
                  regions: const [
                    _RadarRegionOption(
                      'Épaule / Bras',
                      RadarClinicalRegion.shoulderUpperLimbProximal,
                    ),
                    _RadarRegionOption(
                      'Coude / Main',
                      RadarClinicalRegion.upperLimbDistal,
                    ),
                  ],
                  onRegionTap: (option) => _handleRegionTap(context, option),
                ),
                _RegionGroup(
                  title: 'TRONC',
                  regions: const [
                    _RadarRegionOption(
                      'Thorax / Dos',
                      RadarClinicalRegion.thoracic,
                    ),
                    _RadarRegionOption('Lombaires', RadarClinicalRegion.lumbar),
                  ],
                  onRegionTap: (option) => _handleRegionTap(context, option),
                ),
                _RegionGroup(
                  title: 'MEMBRE INFÉRIEUR',
                  regions: const [
                    _RadarRegionOption(
                      'Bassin / Hanche',
                      RadarClinicalRegion.hipLowerLimbProximal,
                    ),
                    _RadarRegionOption('Genou', RadarClinicalRegion.kneeLeg),
                    _RadarRegionOption(
                      'Cheville / Pied',
                      RadarClinicalRegion.ankleFoot,
                    ),
                  ],
                  onRegionTap: (option) => _handleRegionTap(context, option),
                ),
                _RegionGroup(
                  title: 'AUTRE',
                  regions: const [
                    _RadarRegionOption(
                      'Autre localisation',
                      RadarClinicalRegion.diffuse,
                    ),
                  ],
                  onRegionTap: (option) => _handleRegionTap(context, option),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarRegionOption {
  const _RadarRegionOption(this.label, this.region);

  final String label;
  final RadarClinicalRegion region;
}

class _RegionGroup extends StatelessWidget {
  const _RegionGroup({
    required this.title,
    required this.regions,
    required this.onRegionTap,
  });

  final String title;
  final List<_RadarRegionOption> regions;
  final ValueChanged<_RadarRegionOption> onRegionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RadarSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: RadarTextStyles.categoryLabel),
          const SizedBox(height: RadarSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadarRadius.card),
            child: Column(
              children: [
                for (final option in regions) ...[
                  RadarRegionAction(
                    label: option.label,
                    onTap: () => onRegionTap(option),
                  ),
                  if (option != regions.last)
                    const SizedBox(height: RadarSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
