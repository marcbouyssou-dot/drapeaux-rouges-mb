import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class HomeRiskLegendCard extends StatelessWidget {
  const HomeRiskLegendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NIVEAUX DE RISQUE',
            style: TextStyle(
              color: Color(0xFFB7C5D8),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: AppSpacing.sm + 1),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              HomeRiskChip('Faible', AppColors.successDark, false),
              HomeRiskChip('Modéré', AppColors.warningDark, false),
              HomeRiskChip('Élevé', AppColors.danger, false),
              HomeRiskChip('Critique', AppColors.critical, true),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: active ? 1 : 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
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
        color: Color(0xFF334155),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceAlt, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl - 2),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
