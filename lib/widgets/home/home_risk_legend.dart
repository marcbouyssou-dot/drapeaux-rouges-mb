import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class HomeRiskLegendCard extends StatelessWidget {
  const HomeRiskLegendCard({super.key, required this.riskLevel});

  final String riskLevel;

  @override
  Widget build(BuildContext context) {
    final normalized = riskLevel.toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl - 2),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NIVEAUX DE RISQUE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 1),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              HomeRiskChip(
                'Faible',
                AppColors.successDark,
                normalized.contains('faible'),
              ),
              HomeRiskChip(
                'Modéré',
                AppColors.warningDark,
                normalized.contains('modéré') || normalized.contains('modere'),
              ),
              HomeRiskChip(
                'Élevé',
                AppColors.danger,
                normalized.contains('élevé') || normalized.contains('eleve'),
              ),
              HomeRiskChip(
                'Critique',
                AppColors.critical,
                normalized.contains('critique'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeRiskChip extends StatelessWidget {
  const HomeRiskChip(this.label, this.color, this.active, {super.key});

  final String label;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: active ? 1 : 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFF6B6B) : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFFF6B6B) : const Color(0xFF475569),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFooterNote extends StatelessWidget {
  const HomeFooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Outil d’aide clinique · Ne remplace pas le diagnostic médical',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class HomeDesktopInfoNote extends StatelessWidget {
  const HomeDesktopInfoNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg - 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceAlt, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: AppShadows.card,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Outil d’aide au raisonnement clinique. Les données de santé doivent rester protégées. Cette application ne remplace pas une évaluation médicale professionnelle.',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
