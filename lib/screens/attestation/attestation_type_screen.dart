import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../models/attestation/attestation_template.dart';
import 'attestation_history_screen.dart';
import 'patient_attestation_screen.dart';

class AttestationTypeScreen extends StatelessWidget {
  const AttestationTypeScreen({super.key});

  void openAttestation(BuildContext context, AttestationTemplate template) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => PatientAttestationScreen(template: template),
      ),
    );
  }

  void openHistory(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const AttestationHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xxl,
                ),
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Retour',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: RadarColors.surface,
                          foregroundColor: RadarColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              RadarRadius.small,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      IntrinsicWidth(
                        child: OutlinedButton.icon(
                          onPressed: () => openHistory(context),
                          icon: const Icon(
                            Icons.history_edu_outlined,
                            size: 18,
                          ),
                          label: const Text('Historique'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RadarColors.primary,
                            side: const BorderSide(color: RadarColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                RadarRadius.small,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RadarSpacing.xl),
                  const Text(
                    'Attestations',
                    style: RadarTextStyles.screenTitle,
                  ),
                  const SizedBox(height: RadarSpacing.sm),
                  const Text(
                    'Préparer une attestation patient et générer le PDF.',
                    style: RadarTextStyles.secondary,
                  ),
                  const SizedBox(height: RadarSpacing.xxl),
                  ...attestationTemplates.map(
                    (template) => Padding(
                      padding: const EdgeInsets.only(bottom: RadarSpacing.lg),
                      child: _AttestationTypeCard(
                        template: template,
                        onTap: () => openAttestation(context, template),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttestationTypeCard extends StatelessWidget {
  const _AttestationTypeCard({required this.template, required this.onTap});

  final AttestationTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(RadarRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        child: Container(
          padding: const EdgeInsets.all(RadarSpacing.xl),
          decoration: BoxDecoration(
            color: RadarColors.surface,
            borderRadius: BorderRadius.circular(RadarRadius.card),
            boxShadow: RadarShadows.card,
          ),
          child: Row(
            children: [
              Container(
                height: compact ? 44 : 50,
                width: compact ? 44 : 50,
                decoration: BoxDecoration(
                  color: template.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.small),
                ),
                child: Icon(
                  template.icon,
                  color: template.color,
                  size: compact ? 23 : 26,
                ),
              ),
              const SizedBox(width: RadarSpacing.lg),
              Expanded(
                child: Text(
                  template.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.question.copyWith(
                    color: template.color,
                    fontSize: compact ? 15.5 : 18,
                  ),
                ),
              ),
              const SizedBox(width: RadarSpacing.sm),
              _StatusBadge(template: template),
              const SizedBox(width: RadarSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                color: RadarColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.template});

  final AttestationTemplate template;

  @override
  Widget build(BuildContext context) {
    final color = template.isActive
        ? RadarColors.clinicalSuccess
        : RadarColors.clinicalWarning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Text(
        template.statusLabel,
        style: RadarTextStyles.caption.copyWith(color: color),
      ),
    );
  }
}
