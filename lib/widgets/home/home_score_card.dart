import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class HomeScoreCard extends StatelessWidget {
  const HomeScoreCard({
    super.key,
    required this.score,
    required this.checkedCount,
    required this.riskLevel,
    required this.riskColor,
    required this.hasPatient,
    required this.patientDisplayName,
    required this.onTap,
  });

  final int score;
  final int checkedCount;
  final String riskLevel;
  final Color riskColor;
  final bool hasPatient;
  final String patientDisplayName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final riskPercent = (score * 10).clamp(0, 100).toInt();
    final hasSignals = checkedCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl - 2),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 332),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.topRight,
              radius: 1.25,
              colors: [
                AppColors.darkSurfaceAlt,
                AppColors.darkSurface,
                AppColors.darkBackground,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl - 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 60,
                spreadRadius: 8,
                offset: const Offset(0, 22),
              ),
              BoxShadow(
                color: AppColors.raspberry.withValues(alpha: 0.14),
                blurRadius: 50,
                spreadRadius: 2,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFF020617).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DÉPISTAGE CLINIQUE',
                          style: TextStyle(
                            color: Color(0xFF8EA0B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textOnDark.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.textOnDark.withValues(
                                alpha: 0.10,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Score actuel',
                            style: TextStyle(
                              color: Color(0xFFDDE7F3),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.raspberry.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.raspberry.withValues(alpha: 0.42),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$riskPercent%',
                          style: const TextStyle(
                            color: AppColors.textOnDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            color: AppColors.raspberry,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      riskLevel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFDDE7F3),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                hasPatient
                    ? '$patientDisplayName · Évaluation en cours'
                    : 'Patient non renseigné · Prêt à évaluer',
                style: const TextStyle(
                  color: Color(0xFFB8C5D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: HomeDecisionIndicator(
                      dotColor: riskColor,
                      value: hasSignals ? '$checkedCount signe(s)' : 'Aucun',
                      label: 'NIVEAU DE RISQUE',
                    ),
                  ),
                  const HomeMetricDivider(),
                  Expanded(
                    child: HomeDecisionIndicator(
                      dotColor: hasPatient
                          ? AppColors.success
                          : AppColors.warning,
                      value: hasPatient ? 'Patient actif' : 'Anonyme',
                      label: 'STATUT CLINIQUE',
                    ),
                  ),
                  const HomeMetricDivider(),
                  Expanded(
                    child: HomeDecisionIndicator(
                      dotColor: AppColors.info,
                      value: hasSignals ? 'Voir décision' : 'Démarrer',
                      label: 'ORIENTATION',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.raspberry, AppColors.raspberryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.raspberry.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.textOnDark,
                      size: 22,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'Commencer le dépistage clinique',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
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

class HomeDecisionIndicator extends StatelessWidget {
  const HomeDecisionIndicator({
    super.key,
    required this.dotColor,
    required this.value,
    required this.label,
  });

  final Color dotColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
      ],
    );
  }
}

class HomeMetricDivider extends StatelessWidget {
  const HomeMetricDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.17),
    );
  }
}
