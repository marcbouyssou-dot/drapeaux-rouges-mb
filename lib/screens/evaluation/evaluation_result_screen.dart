import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/bdk_session_service.dart';
import '../../services/decision_engine_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../bdk/bdk_type_screen.dart';

class EvaluationResultScreen extends StatelessWidget {
  const EvaluationResultScreen({
    super.key,
    required this.score,
    required this.checkedCount,
    required this.riskLevel,
    required this.riskColor,
    required this.selectedCategory,
    required this.categories,
    required this.patientDisplayName,
    required this.aiSummary,
    required this.checkedFlags,
    required this.decisionMessage,
    required this.onReset,
    required this.onSave,
    required this.onExportPdf,
  });

  final int score;
  final int checkedCount;
  final String riskLevel;
  final Color riskColor;
  final String selectedCategory;
  final Map<String, List<Map<String, dynamic>>> categories;
  final String patientDisplayName;
  final String aiSummary;
  final List<Map<String, dynamic>> checkedFlags;
  final String decisionMessage;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final Color medicalRiskColor = _medicalRiskColor(riskLevel);
    final compact = MediaQuery.sizeOf(context).width < 430;

    final decisionTitle = DecisionEngineService.decisionTitle(
      score: score,
      selectedCategory: selectedCategory,
      categories: categories,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Résultat'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          compact ? AppSpacing.xs : AppSpacing.sm,
          AppSpacing.md,
          120,
        ),
        children: [
          Container(
            padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  medicalRiskColor,
                  medicalRiskColor.withValues(alpha: 0.86),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: [
                BoxShadow(
                  color: medicalRiskColor.withValues(alpha: 0.20),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: compact ? 44 : 54,
                      height: compact ? 44 : 54,
                      decoration: BoxDecoration(
                        color: AppColors.textOnDark.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.textOnDark.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(
                        Icons.monitor_heart_rounded,
                        color: AppColors.textOnDark,
                        size: compact ? 26 : 32,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textOnDark.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.textOnDark.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Text(
                        'Score $score',
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),

                Text(
                  riskLevel,
                  style: TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: compact ? 24 : 30,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  '$checkedCount drapeau(x) rouge(s) détecté(s)',
                  style: TextStyle(
                    color: AppColors.textOnDark.withValues(alpha: 0.90),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (!compact) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    patientDisplayName,
                    style: TextStyle(
                      color: AppColors.textOnDark.withValues(alpha: 0.76),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _ResultCard(
            icon: Icons.route_rounded,
            title: 'Orientation recommandée',
            text: '$decisionTitle\n$decisionMessage',
            color: medicalRiskColor,
          ),

          const SizedBox(height: AppSpacing.md),

          _ResultCard(
            icon: Icons.psychology_alt_outlined,
            title: 'Résumé clinique',
            text: aiSummary,
            color: AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.md),

          const _SafetyNote(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            border: const Border(top: BorderSide(color: AppColors.border)),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onReset();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réinitialiser'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Sauver'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onExportPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    BDKSessionService.loadFromEvaluation(
                      selectedCategory: selectedCategory,
                      score: score,
                      risk: riskLevel,
                      checkedFlagsData: checkedFlags,
                      aiSummary: aiSummary,
                      decisionMessage: decisionMessage,
                    );

                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const BDKTypeScreen()),
                    );
                  },
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Préparer un BDK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: color.withValues(alpha: 0.16)),
            ),
            child: Icon(icon, color: color, size: 27),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  text,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Aide au repérage clinique uniquement. Cette application ne remplace pas une évaluation médicale professionnelle.',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}

Color _medicalRiskColor(String riskLevel) {
  final risk = riskLevel.toLowerCase();

  if (risk.contains('critique')) {
    return AppColors.danger;
  }

  if (risk.contains('élevé') || risk.contains('eleve')) {
    return AppColors.danger;
  }

  if (risk.contains('modéré') || risk.contains('modere')) {
    return AppColors.warning;
  }

  return AppColors.success;
}
