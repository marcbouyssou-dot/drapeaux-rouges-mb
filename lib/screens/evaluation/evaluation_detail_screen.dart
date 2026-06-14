import 'package:flutter/material.dart';

import '../../models/clinical/clinical_models.dart';
import '../../models/evaluation_model.dart';
import '../../presentation/clinical_reasoning/clinical_reasoning_presenter.dart';
import '../../services/history_service.dart';
import '../../services/pdf_service.dart';
import '../../services/practitioner_profile_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/clinical_reasoning/clinical_alerts_card.dart';
import '../../widgets/clinical_reasoning/clinical_findings_card.dart';
import '../../widgets/clinical_reasoning/clinical_reasoning_section_card.dart';
import '../../widgets/clinical_reasoning/clinical_recommendations_card.dart';
import '../../widgets/clinical_reasoning/clinical_summary_card.dart';

class EvaluationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> evaluation;

  const EvaluationDetailScreen({super.key, required this.evaluation});

  String get evaluationId => evaluation['evaluationId']?.toString() ?? '';

  String get patientName {
    return evaluation['patientDisplayName']?.toString() ??
        evaluation['patientCode']?.toString() ??
        'Patient non renseigné';
  }

  String get patientExportCode {
    return evaluation['patientAnonymousId']?.toString() ??
        evaluation['patientCode']?.toString() ??
        'Patient non renseigné';
  }

  String get motif => evaluation['motif']?.toString() ?? 'Motif non renseigné';

  String get riskLevel {
    return evaluation['riskLevel']?.toString() ??
        evaluation['risk']?.toString() ??
        'Risque inconnu';
  }

  int get score {
    final value = evaluation['score'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int get checkedCount {
    final value = evaluation['checkedCount'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get decisionTitle {
    return evaluation['decisionTitle']?.toString() ?? 'Décision non renseignée';
  }

  String get decisionMessage {
    return evaluation['decisionMessage']?.toString() ??
        'Aucun message de décision enregistré.';
  }

  String get aiSummary {
    return evaluation['aiSummary']?.toString() ??
        'Synthèse non enregistrée pour ce bilan.';
  }

  List<Map<String, dynamic>> get checkedFlags {
    final raw = evaluation['checkedFlags'];
    if (raw is! List) return [];
    return raw.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  ClinicalReasoning? get savedClinicalReasoning {
    if (evaluation['clinicalReasoning'] is! Map) return null;

    return EvaluationModel.fromJson(evaluation).clinicalReasoning;
  }

  Color get riskColor {
    final lower = riskLevel.toLowerCase();

    if (lower.contains('critique')) return const Color(0xFFDC2626);
    if (lower.contains('élevé') || lower.contains('eleve')) {
      return const Color(0xFFF97316);
    }
    if (lower.contains('modéré') || lower.contains('modere')) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF22C55E);
  }

  String formatDate(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return 'Date inconnue';

    final date = DateTime.tryParse(raw);
    if (date == null) return raw;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }

  Map<String, List<Map<String, dynamic>>> buildPdfCategories() {
    final result = <String, List<Map<String, dynamic>>>{};

    for (final flag in checkedFlags) {
      final category = flag['category']?.toString() ?? motif;
      result.putIfAbsent(category, () => []);

      result[category]!.add({
        'title': flag['title']?.toString() ?? 'Drapeau rouge',
        'severity': flag['severity']?.toString() ?? 'Non renseigné',
        'checked': true,
        'tags': flag['tags'] ?? [],
      });
    }

    return result;
  }

  Future<void> exportPdf({required bool printable}) async {
    final practitioner = await PractitionerProfileService.getProfile();

    await PdfService.exportPdf(
      categories: buildPdfCategories(),
      score: score,
      checkedCount: checkedCount,
      riskLevel: riskLevel,
      patientCode: patientExportCode,
      motif: motif,
      decisionTitle: decisionTitle,
      decisionMessage: decisionMessage,
      aiSummary: aiSummary,
      clinicalReasoning: savedClinicalReasoning,
      printable: printable,
      practitioner: practitioner,
    );
  }

  void showPdfExportChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 54,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Exporter le PDF',
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                buildPdfChoiceTile(
                  icon: Icons.palette_outlined,
                  title: 'PDF couleur',
                  subtitle: 'Lecture écran, risque plus visible',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    exportPdf(printable: false);
                  },
                ),
                const SizedBox(height: 10),
                buildPdfChoiceTile(
                  icon: Icons.print_outlined,
                  title: 'PDF impression',
                  subtitle: 'Noir et blanc, moins d’encre',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    exportPdf(printable: true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPdfChoiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> confirmDelete(BuildContext context) async {
    if (evaluationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de supprimer ce bilan : identifiant manquant.',
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce bilan ?'),
          content: const Text(
            'Cette action supprimera uniquement ce bilan de l’historique local. '
            'Le patient ne sera pas supprimé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await HistoryService.deleteEvaluation(evaluationId);

    if (!context.mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final clinicalReasoning = savedClinicalReasoning;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: [
                buildPatientHeader(context),
                const SizedBox(height: AppSpacing.sm),
                buildEvaluationSummaryCard(),
                const SizedBox(height: AppSpacing.sm),
                buildDecisionCard(),
                if (clinicalReasoning != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  buildClinicalTimelineCard(clinicalReasoning),
                  const SizedBox(height: AppSpacing.sm),
                  buildClinicalReasoningBlock(clinicalReasoning),
                ],
                const SizedBox(height: AppSpacing.sm),
                buildFlagsSection(),
                const SizedBox(height: AppSpacing.sm),
                buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPatientHeader(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.medicalBlue,
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.textOnDark.withValues(alpha: 0.20),
                  ),
                ),
                child: IconButton(
                  tooltip: 'Retour',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  iconSize: 18,
                  color: AppColors.textOnDark,
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.textOnDark.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.textOnDark.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: AppColors.textOnDark,
                    size: 24,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(evaluation['date']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textOnDark.withValues(alpha: 0.82),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                buildHeaderChip(
                  icon: Icons.monitor_heart_outlined,
                  label: riskLevel,
                  color: AppColors.textOnDark,
                ),
                buildHeaderChip(
                  icon: Icons.medical_services_outlined,
                  label: motif,
                  color: AppColors.textOnDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildHeaderChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({required Widget child, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }

  Widget buildEvaluationSummaryCard() {
    return buildSectionCard(
      borderColor: riskColor.withValues(alpha: 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle(
            icon: Icons.summarize_outlined,
            title: 'Synthèse de l’évaluation',
            subtitle: formatDate(evaluation['date']),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              buildSummaryPill(
                icon: Icons.monitor_heart_rounded,
                label: 'Risque',
                value: riskLevel,
                color: riskColor,
              ),
              buildSummaryPill(
                icon: Icons.speed_rounded,
                label: 'Score',
                value: '$score',
                color: riskColor,
              ),
              buildSummaryPill(
                icon: Icons.flag_rounded,
                label: 'Drapeaux',
                value: '$checkedCount',
                color: AppColors.primary,
              ),
              buildSummaryPill(
                icon: Icons.medical_services_outlined,
                label: 'Motif',
                value: motif,
                color: AppColors.teal,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.raspberry.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: AppColors.raspberry,
                    size: 19,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orientation proposée',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        decisionTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDecisionCard() {
    return buildSectionCard(
      borderColor: riskColor.withValues(alpha: 0.22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: riskColor.withValues(alpha: 0.16)),
            ),
            child: Icon(Icons.route_rounded, color: riskColor, size: 27),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decisionTitle,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  decisionMessage,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClinicalReasoningBlock(ClinicalReasoning reasoning) {
    final severity = savedClinicalSeverity(reasoning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClinicalSummaryCard(summary: reasoning.summary),
        const SizedBox(height: AppSpacing.sm),
        ClinicalReasoningSectionCard(
          title: 'Sévérité maximale',
          icon: Icons.trending_up_rounded,
          color: const ClinicalReasoningPresenter().severityColor(severity),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ClinicalReasoningBadge(
                label: const ClinicalReasoningPresenter().severityLabel(
                  severity,
                ),
                color: const ClinicalReasoningPresenter().severityColor(
                  severity,
                ),
              ),
            ),
          ],
        ),
        if (reasoning.alerts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ClinicalAlertsCard(
            alerts: reasoning.alerts,
            color: const ClinicalReasoningPresenter().alertLevelColor(
              reasoning.alerts.first.level,
            ),
          ),
        ],
        if (reasoning.recommendations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ClinicalRecommendationsCard(
            recommendations: reasoning.recommendations,
          ),
        ],
        if (reasoning.findings.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ClinicalFindingsCard(findings: reasoning.findings),
        ],
      ],
    );
  }

  Widget buildClinicalTimelineCard(ClinicalReasoning reasoning) {
    return buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle(
            icon: Icons.timeline_rounded,
            title: 'Timeline clinique',
            subtitle: 'Lecture chronologique des éléments enregistrés.',
          ),
          const SizedBox(height: AppSpacing.md),
          buildTimelineItem(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Évaluation réalisée',
            value: '${formatDate(evaluation['date'])} · $motif',
            color: AppColors.primary,
            isFirst: true,
          ),
          buildTimelineItem(
            icon: Icons.flag_rounded,
            title: 'Drapeaux rouges détectés',
            value: '$checkedCount élément(s) retenu(s)',
            color: riskColor,
          ),
          buildTimelineItem(
            icon: Icons.monitor_heart_rounded,
            title: 'Niveau de risque retenu',
            value: '$riskLevel · score $score',
            color: riskColor,
          ),
          buildTimelineItem(
            icon: Icons.notification_important_outlined,
            title: 'Alertes cliniques',
            value: reasoning.alerts.isEmpty
                ? 'Aucune alerte sauvegardée'
                : '${reasoning.alerts.length} alerte(s) sauvegardée(s)',
            color: reasoning.alerts.isEmpty
                ? AppColors.textSecondary
                : riskColor,
          ),
          buildTimelineItem(
            icon: Icons.fact_check_outlined,
            title: 'Recommandations',
            value: reasoning.recommendations.isEmpty
                ? 'Aucune recommandation sauvegardée'
                : '${reasoning.recommendations.length} recommandation(s)',
            color: AppColors.primary,
          ),
          buildTimelineItem(
            icon: Icons.route_rounded,
            title: 'Orientation proposée',
            value: decisionTitle,
            color: AppColors.raspberry,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget buildTimelineItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 38,
          child: Column(
            children: [
              if (!isFirst)
                Container(width: 2, height: 8, color: AppColors.border),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              if (!isLast)
                Container(width: 2, height: 20, color: AppColors.border),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 3 : 11, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ClinicalSeverity maxClinicalSeverity(List<ClinicalFinding> findings) {
    if (findings.isEmpty) return ClinicalSeverity.unknown;

    return findings.map((finding) => finding.severity).reduce((current, next) {
      return severityRank(next) > severityRank(current) ? next : current;
    });
  }

  ClinicalSeverity savedClinicalSeverity(ClinicalReasoning reasoning) {
    if (reasoning.severity != null) return reasoning.severity!;

    final rawReasoning = evaluation['clinicalReasoning'];
    if (rawReasoning is Map && rawReasoning['severity'] != null) {
      final value = rawReasoning['severity'].toString();
      for (final severity in ClinicalSeverity.values) {
        if (severity.name == value) return severity;
      }
    }

    return maxClinicalSeverity(reasoning.findings);
  }

  int severityRank(ClinicalSeverity severity) {
    switch (severity) {
      case ClinicalSeverity.critical:
        return 4;
      case ClinicalSeverity.high:
        return 3;
      case ClinicalSeverity.moderate:
        return 2;
      case ClinicalSeverity.low:
        return 1;
      case ClinicalSeverity.unknown:
        return 0;
    }
  }

  Widget buildFlagsSection() {
    if (checkedFlags.isEmpty) return buildEmptyFlags();

    return buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle(
            icon: Icons.flag_rounded,
            title: 'Drapeaux rouges cochés',
            subtitle: '$checkedCount élément(s) retenu(s) dans ce bilan.',
          ),
          const SizedBox(height: AppSpacing.md),
          ...checkedFlags.map(buildFlagTile),
        ],
      ),
    );
  }

  Widget buildEmptyFlags() {
    return buildSectionCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceSuccess,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.successDark,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Aucun drapeau rouge coché dans ce bilan.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlagTile(Map<String, dynamic> flag) {
    final title = flag['title']?.toString() ?? 'Drapeau rouge';
    final severity = flag['severity']?.toString() ?? 'Non renseigné';
    final category = flag['category']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: riskColor.withValues(alpha: 0.14)),
            ),
            child: Icon(Icons.flag_rounded, color: riskColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null) ...[
                  Text(
                    category,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: riskColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      severity,
                      style: TextStyle(
                        color: riskColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => showPdfExportChoice(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Exporter PDF'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Supprimer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
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
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
