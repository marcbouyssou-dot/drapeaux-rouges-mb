import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/voice/voice_clinical_placeholder_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class HomeClinicalAssistantCard extends StatelessWidget {
  const HomeClinicalAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl - 2),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.soft,
                ),
                child: Image.asset(
                  'assets/images/logo_urps_modern.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSISTANT CLINIQUE URPS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Assistant Clinique URPS',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Socle prévu pour les prochaines évolutions cliniques, vocales et sécurisées.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _AssistantBadge(
                label: 'IA Vocale',
                color: AppColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const VoiceClinicalPlaceholderScreen(),
                    ),
                  );
                },
              ),
              const _AssistantBadge(label: 'Cloud HDS', color: AppColors.teal),
              const _AssistantBadge(
                label: 'Assistant Clinique',
                color: AppColors.raspberry,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Module de préparation produit, sans fonctionnalité active pour le moment.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantBadge extends StatelessWidget {
  const _AssistantBadge({required this.label, required this.color, this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    if (onTap == null) return badge;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: badge,
      ),
    );
  }
}

class HomeLegalBottomBand extends StatelessWidget {
  const HomeLegalBottomBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: const Text(
        'Outil d’aide au raisonnement clinique · Les données de santé doivent rester protégées · Ne remplace pas une évaluation médicale professionnelle.',
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
