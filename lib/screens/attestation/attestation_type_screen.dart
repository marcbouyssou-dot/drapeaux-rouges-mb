import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/attestation/attestation_template.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Retour',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => openHistory(context),
                      icon: const Icon(Icons.history_edu_outlined, size: 18),
                      label: const Text('Historique'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.borderStrong),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...attestationTemplates.map(
                  (template) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                height: compact ? 44 : 50,
                width: compact ? 44 : 50,
                decoration: BoxDecoration(
                  color: template.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: template.color.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  template.icon,
                  color: template.color,
                  size: compact ? 23 : 26,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  template.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: template.color,
                    fontSize: compact ? 15.5 : 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(template: template),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 28,
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
    final color = template.isActive ? AppColors.successDark : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        template.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
