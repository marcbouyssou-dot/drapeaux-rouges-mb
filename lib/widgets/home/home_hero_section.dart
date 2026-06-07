import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 42, 22, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.medicalBlue, AppColors.medicalBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'URPS MK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nouvelle-Aquitaine',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: AppColors.success, size: 7),
                SizedBox(width: 7),
                Text(
                  'Accès Direct MK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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

class HomePatientClinicalCard extends StatelessWidget {
  const HomePatientClinicalCard({
    super.key,
    required this.hasPatient,
    required this.patientDisplayName,
  });

  final bool hasPatient;
  final String patientDisplayName;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl - 2),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004A8F).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            decoration: BoxDecoration(
              color: hasPatient
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: hasPatient
                    ? AppColors.success.withValues(alpha: 0.22)
                    : AppColors.warning.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(
              hasPatient
                  ? Icons.verified_user_outlined
                  : Icons.no_accounts_outlined,
              color: hasPatient ? AppColors.successDark : AppColors.warningDark,
              size: compact ? 22 : 25,
            ),
          ),
          SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BILAN CLINIQUE',
                  style: TextStyle(
                    color: AppColors.raspberry,
                    fontSize: compact ? 9.5 : 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: compact ? 1.1 : 1.7,
                  ),
                ),
                SizedBox(height: compact ? 4 : 8),
                Text(
                  hasPatient ? patientDisplayName : 'Patient non renseigné',
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.medicalBlue,
                    fontSize: compact ? 18 : 21,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    hasPatient
                        ? 'Évaluation clinique en cours'
                        : 'Mode anonyme possible, patient conseillé pour la traçabilité',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 9 : 11,
              vertical: compact ? 6 : 7,
            ),
            decoration: BoxDecoration(
              color: hasPatient
                  ? const Color(0xFFEFFAF4)
                  : AppColors.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: hasPatient
                    ? const Color(0xFFCBEED8)
                    : AppColors.warning.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: hasPatient
                      ? AppColors.successDark
                      : AppColors.warningDark,
                  size: 7,
                ),
                const SizedBox(width: AppSpacing.sm - 1),
                Text(
                  hasPatient ? 'ACTIF' : 'ANONYME',
                  style: TextStyle(
                    color: hasPatient
                        ? const Color(0xFF166534)
                        : AppColors.warningDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
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
