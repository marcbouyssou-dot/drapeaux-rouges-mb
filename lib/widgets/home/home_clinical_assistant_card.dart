import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/voice/voice_clinical_placeholder_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class HomeClinicalAssistantCard extends StatelessWidget {
  const HomeClinicalAssistantCard({
    super.key,
    this.compact = false,
    this.onAdaptiveEvaluationTap,
  });

  final bool compact;
  final VoidCallback? onAdaptiveEvaluationTap;

  @override
  Widget build(BuildContext context) {
    final hasAdaptiveEntry = onAdaptiveEvaluationTap != null;
    final cardPadding = compact || hasAdaptiveEntry
        ? AppSpacing.md
        : AppSpacing.lg;
    final sectionGap = compact || hasAdaptiveEntry
        ? AppSpacing.sm
        : AppSpacing.lg;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
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
                width: compact ? 54 : 74,
                height: compact ? 50 : 70,
                padding: EdgeInsets.all(compact ? 2 : 4),
                child: Image.asset(
                  'assets/icons/urps_pictogram_official_transparent.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assistant clinique URPS',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: compact ? 16 : 21,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: compact ? 5 : AppSpacing.sm),
                    const Text(
                      'Aide au raisonnement clinique',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Socle prévu pour les prochaines évolutions cliniques, vocales et sécurisées.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sectionGap),
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
              const _AssistantBadge(
                label: 'Assistant Clinique',
                color: AppColors.raspberry,
              ),
            ],
          ),
          if (onAdaptiveEvaluationTap != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _AdaptiveEvaluationEntry(onTap: onAdaptiveEvaluationTap!),
          ],
          SizedBox(height: sectionGap),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
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

class _AdaptiveEvaluationEntry extends StatelessWidget {
  const _AdaptiveEvaluationEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('adaptive-v5-home-entry'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.science_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Évaluation clinique adaptative — expérimental',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Prototype de raisonnement clinique V5. Ne remplace pas encore le parcours actuel.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
