import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/clinical/clinical_models.dart';
import '../../models/evaluation_model.dart';
import '../../services/bdk_session_service.dart';
import '../../services/clinical_reasoning_service.dart';
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
    final reasoning = ClinicalReasoningService().buildFromEvaluation(
      evaluation: EvaluationModel(
        evaluationId: 'result_${DateTime.now().microsecondsSinceEpoch}',
        patientLocalId: null,
        patientAnonymousId: null,
        patientDisplayName: patientDisplayName,
        date: DateTime.now(),
        motif: selectedCategory,
        score: score,
        riskLevel: riskLevel,
        checkedCount: checkedCount,
        checkedFlags: checkedFlags,
        decisionTitle: DecisionEngineService.decisionTitle(
          score: score,
          selectedCategory: selectedCategory,
          categories: categories,
        ),
        decisionMessage: decisionMessage,
        aiSummary: aiSummary,
      ),
    );

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

          _ClinicalSummaryCard(summary: reasoning.summary),

          if (reasoning.alerts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ClinicalSectionCard(
              title: 'Alertes cliniques',
              icon: Icons.notification_important_outlined,
              color: medicalRiskColor,
              children: reasoning.alerts
                  .map((alert) => _ClinicalAlertItem(alert: alert))
                  .toList(growable: false),
            ),
          ],

          if (reasoning.recommendations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ClinicalSectionCard(
              title: 'Recommandations',
              icon: Icons.fact_check_outlined,
              color: AppColors.primary,
              children: reasoning.recommendations
                  .map(
                    (recommendation) => _ClinicalRecommendationItem(
                      recommendation: recommendation,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],

          if (reasoning.findings.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ClinicalSectionCard(
              title: 'Éléments retenus',
              icon: Icons.checklist_rounded,
              color: AppColors.textSecondary,
              children: reasoning.findings
                  .map((finding) => _ClinicalFindingItem(finding: finding))
                  .toList(growable: false),
            ),
          ],

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

class _ClinicalSummaryCard extends StatelessWidget {
  const _ClinicalSummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _ClinicalSectionCard(
      title: 'Synthèse clinique',
      icon: Icons.insights_rounded,
      color: AppColors.primary,
      children: [
        Text(
          summary,
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ClinicalSectionCard extends StatelessWidget {
  const _ClinicalSectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._withDividers(children),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final widgets = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      if (index > 0) {
        widgets.add(
          const Divider(height: AppSpacing.md, color: AppColors.border),
        );
      }
      widgets.add(items[index]);
    }
    return widgets;
  }
}

class _ClinicalAlertItem extends StatelessWidget {
  const _ClinicalAlertItem({required this.alert});

  final ClinicalAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = _alertLevelColor(alert.level);

    return _ClinicalTextItem(
      title: alert.title,
      body: alert.message,
      trailingLabel: _alertLevelLabel(alert.level),
      trailingColor: color,
    );
  }
}

class _ClinicalRecommendationItem extends StatelessWidget {
  const _ClinicalRecommendationItem({required this.recommendation});

  final ClinicalRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return _ClinicalTextItem(
      title: recommendation.title,
      body: recommendation.description,
      trailingLabel: _recommendationPriorityLabel(recommendation.priority),
      trailingColor: _recommendationPriorityColor(recommendation.priority),
    );
  }
}

class _ClinicalFindingItem extends StatelessWidget {
  const _ClinicalFindingItem({required this.finding});

  final ClinicalFinding finding;

  @override
  Widget build(BuildContext context) {
    return _ClinicalTextItem(
      title: finding.label,
      body:
          '${_findingCategoryLabel(finding.category)} · ${_severityLabel(finding.severity)}',
      trailingLabel: _severityLabel(finding.severity),
      trailingColor: _severityColor(finding.severity),
    );
  }
}

class _ClinicalTextItem extends StatelessWidget {
  const _ClinicalTextItem({
    required this.title,
    required this.body,
    required this.trailingLabel,
    required this.trailingColor,
  });

  final String title;
  final String body;
  final String trailingLabel;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ClinicalBadge(label: trailingLabel, color: trailingColor),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ClinicalBadge extends StatelessWidget {
  const _ClinicalBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
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

Color _alertLevelColor(ClinicalAlertLevel level) {
  switch (level) {
    case ClinicalAlertLevel.info:
      return AppColors.primary;
    case ClinicalAlertLevel.warning:
      return AppColors.warning;
    case ClinicalAlertLevel.urgent:
    case ClinicalAlertLevel.critical:
      return AppColors.danger;
  }
}

String _alertLevelLabel(ClinicalAlertLevel level) {
  switch (level) {
    case ClinicalAlertLevel.info:
      return 'Info';
    case ClinicalAlertLevel.warning:
      return 'Vigilance';
    case ClinicalAlertLevel.urgent:
      return 'Urgent';
    case ClinicalAlertLevel.critical:
      return 'Critique';
  }
}

Color _recommendationPriorityColor(ClinicalRecommendationPriority priority) {
  switch (priority) {
    case ClinicalRecommendationPriority.low:
      return AppColors.textSecondary;
    case ClinicalRecommendationPriority.medium:
      return AppColors.primary;
    case ClinicalRecommendationPriority.high:
      return AppColors.warning;
    case ClinicalRecommendationPriority.urgent:
      return AppColors.danger;
  }
}

String _recommendationPriorityLabel(ClinicalRecommendationPriority priority) {
  switch (priority) {
    case ClinicalRecommendationPriority.low:
      return 'Faible';
    case ClinicalRecommendationPriority.medium:
      return 'Moyenne';
    case ClinicalRecommendationPriority.high:
      return 'Haute';
    case ClinicalRecommendationPriority.urgent:
      return 'Urgente';
  }
}

Color _severityColor(ClinicalSeverity severity) {
  switch (severity) {
    case ClinicalSeverity.low:
      return AppColors.success;
    case ClinicalSeverity.moderate:
      return AppColors.warning;
    case ClinicalSeverity.high:
    case ClinicalSeverity.critical:
      return AppColors.danger;
    case ClinicalSeverity.unknown:
      return AppColors.textSecondary;
  }
}

String _severityLabel(ClinicalSeverity severity) {
  switch (severity) {
    case ClinicalSeverity.low:
      return 'Faible';
    case ClinicalSeverity.moderate:
      return 'Modérée';
    case ClinicalSeverity.high:
      return 'Élevée';
    case ClinicalSeverity.critical:
      return 'Critique';
    case ClinicalSeverity.unknown:
      return 'Non précisée';
  }
}

String _findingCategoryLabel(ClinicalFindingCategory category) {
  switch (category) {
    case ClinicalFindingCategory.general:
      return 'Général';
    case ClinicalFindingCategory.cardiovascular:
      return 'Cardiovasculaire';
    case ClinicalFindingCategory.respiratory:
      return 'Respiratoire';
    case ClinicalFindingCategory.neurological:
      return 'Neurologique';
    case ClinicalFindingCategory.infectious:
      return 'Infectieux';
    case ClinicalFindingCategory.mentalHealth:
      return 'Santé mentale';
    case ClinicalFindingCategory.musculoskeletal:
      return 'Musculosquelettique';
    case ClinicalFindingCategory.other:
      return 'Autre';
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
