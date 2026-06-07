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
                AppSpacing.md,
                AppSpacing.md,
                120,
              ),
              children: [
                infoHeader(),
                const SizedBox(height: AppSpacing.md),
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

  Widget infoHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.textOnDark.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.medical_information_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'drapeaux_rouges_MB',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title.copyWith(
              color: AppColors.textOnDark,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
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
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  text,
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
