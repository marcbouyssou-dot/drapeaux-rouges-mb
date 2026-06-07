import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                120,
              ),
              children: [
                infoHeader(context),
                const SizedBox(height: AppSpacing.sm),
                infoCard(
                  icon: Icons.person_outline,
                  title: 'Éditeur',
                  text: 'Application drapeaux_rouges_MB.',
                ),
                infoCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Usage',
                  text:
                      'Outil professionnel d’aide au repérage des drapeaux rouges.',
                ),
                infoCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Prudence',
                  text:
                      'Cette application ne pose pas de diagnostic médical et ne remplace pas une évaluation par un professionnel de santé.',
                ),
                infoCard(
                  icon: Icons.privacy_tip_outlined,
                  title: 'RGPD',
                  text:
                      'Ne jamais saisir de données nominatives. Utiliser uniquement un code patient pseudonymisé.',
                ),
                infoCard(
                  icon: Icons.info_outline,
                  title: 'Version',
                  text: 'drapeaux_rouges_MB · Version 1.0.0',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoHeader(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.medicalBlue, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 42 : 52,
            height: compact ? 42 : 52,
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.textOnDark.withValues(alpha: 0.20),
              ),
            ),
            child: Icon(
              Icons.medical_information_rounded,
              color: Colors.white,
              size: compact ? 24 : 30,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            'drapeaux_rouges_MB',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title.copyWith(
              color: AppColors.textOnDark,
              fontSize: compact ? 20 : 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Application clinique de repérage rapide',
              style: TextStyle(
                color: AppColors.textOnDark.withValues(alpha: 0.82),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
