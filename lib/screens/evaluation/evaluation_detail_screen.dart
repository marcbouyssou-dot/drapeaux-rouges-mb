import 'package:flutter/material.dart';

import '../../models/clinical/clinical_models.dart';
import '../../models/evaluation_model.dart';
import '../../presentation/clinical_reasoning/clinical_reasoning_presenter.dart';
import '../../services/history_service.dart';
import '../../services/pdf_service.dart';
import '../../services/practitioner_profile_service.dart';
import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/widgets/radar_destructive_confirmation_dialog.dart';
import '../../features/radar/presentation/widgets/radar_page_header.dart';
import '../../features/radar/presentation/widgets/radar_surface_card.dart';

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

    if (lower.contains('critique')) return RadarColors.clinicalDanger;
    if (lower.contains('élevé') || lower.contains('eleve')) {
      return RadarColors.clinicalWarning;
    }
    if (lower.contains('modéré') || lower.contains('modere')) {
      return RadarColors.clinicalWarning;
    }

    return RadarColors.clinicalSuccess;
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
      backgroundColor: RadarColors.surface.withValues(alpha: 0),
      builder: (sheetContext) {
        return SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: RadarColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(RadarRadius.signature),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                RadarSpacing.xl,
                RadarSpacing.md,
                RadarSpacing.xl,
                RadarSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: RadarColors.divider,
                      borderRadius: BorderRadius.circular(RadarRadius.pill),
                    ),
                    child: const SizedBox(height: 5, width: 54),
                  ),
                  const SizedBox(height: RadarSpacing.cardGap),
                  Text('Exporter le PDF', style: RadarTextStyles.sectionTitle),
                  const SizedBox(height: RadarSpacing.lg),
                  buildPdfChoiceTile(
                    icon: Icons.palette_outlined,
                    title: 'PDF couleur',
                    subtitle: 'Lecture écran, risque plus visible',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      exportPdf(printable: false);
                    },
                  ),
                  const SizedBox(height: RadarSpacing.sm),
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
    return RadarSurfaceCard(
      padding: EdgeInsets.zero,
      boxShadow: const [],
      child: Material(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadarRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(RadarSpacing.lg),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: RadarColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(icon, color: RadarColors.primary, size: 24),
                  ),
                ),
                const SizedBox(width: RadarSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: RadarTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(subtitle, style: RadarTextStyles.secondary),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RadarColors.textMuted,
                ),
              ],
            ),
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

    final confirm = await showRadarDestructiveConfirmationDialog(
      context,
      title: 'Supprimer ce bilan ?',
      message:
          'Cette action supprimera uniquement ce bilan de l’historique '
          'local. Le patient ne sera pas supprimé.',
      confirmLabel: 'Supprimer',
    );

    if (!confirm) return;

    await HistoryService.deleteEvaluation(evaluationId);

    if (!context.mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final clinicalReasoning = savedClinicalReasoning;

    return Scaffold(
      backgroundColor: RadarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: RadarLayout.historyWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                RadarSpacing.xl,
                RadarSpacing.lg,
                RadarSpacing.xl,
                RadarSpacing.xxxl,
              ),
              children: [
                buildPatientHeader(context),
                const SizedBox(height: RadarSpacing.xl),
                buildEvaluationSummaryCard(),
                const SizedBox(height: RadarSpacing.lg),
                buildDecisionCard(),
                if (clinicalReasoning != null) ...[
                  const SizedBox(height: RadarSpacing.lg),
                  buildClinicalTimelineCard(clinicalReasoning),
                  const SizedBox(height: RadarSpacing.lg),
                  buildClinicalReasoningBlock(clinicalReasoning),
                ],
                const SizedBox(height: RadarSpacing.lg),
                buildFlagsSection(),
                const SizedBox(height: RadarSpacing.xl),
                buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPatientHeader(BuildContext context) {
    return RadarPageHeader(
      title: patientName,
      subtitle: '${formatDate(evaluation['date'])} · $motif',
      onBack: () => Navigator.pop(context),
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          color: riskColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(RadarRadius.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RadarSpacing.md,
            vertical: RadarSpacing.sm,
          ),
          child: Text(
            riskLevel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RadarTextStyles.badge.copyWith(color: riskColor),
          ),
        ),
      ),
    );
  }

  Widget buildSectionCard({required Widget child, Color? borderColor}) {
    return RadarSurfaceCard(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      border: borderColor == null ? null : Border.all(color: borderColor),
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
          const SizedBox(height: RadarSpacing.md),
          Wrap(
            spacing: RadarSpacing.sm,
            runSpacing: RadarSpacing.sm,
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
                color: RadarColors.primary,
              ),
              buildSummaryPill(
                icon: Icons.medical_services_outlined,
                label: 'Motif',
                value: motif,
                color: RadarColors.indigo,
              ),
            ],
          ),
          const SizedBox(height: RadarSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(RadarSpacing.sm),
            decoration: BoxDecoration(
              color: RadarColors.surfaceMuted,
              borderRadius: BorderRadius.circular(RadarRadius.card),
              border: Border.all(color: RadarColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: RadarColors.indigo.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: RadarColors.indigo,
                    size: 19,
                  ),
                ),
                const SizedBox(width: RadarSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orientation proposée',
                        style: RadarTextStyles.caption.copyWith(
                          color: RadarColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        decisionTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.body.copyWith(
                          color: RadarColors.textPrimary,
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
        borderRadius: BorderRadius.circular(RadarRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: RadarSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.caption.copyWith(
                    color: RadarColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.badge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
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
              borderRadius: BorderRadius.circular(RadarRadius.card),
              border: Border.all(color: riskColor.withValues(alpha: 0.16)),
            ),
            child: Icon(Icons.route_rounded, color: riskColor, size: 27),
          ),
          const SizedBox(width: RadarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decisionTitle,
                  style: RadarTextStyles.decision.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RadarSpacing.sm),
                Text(
                  decisionMessage,
                  style: RadarTextStyles.secondary.copyWith(
                    color: RadarColors.textPrimary,
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
    const presenter = ClinicalReasoningPresenter();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildReasoningSection(
          title: 'Synthèse clinique',
          icon: Icons.insights_rounded,
          color: RadarColors.primary,
          children: [
            Text(
              reasoning.summary,
              style: RadarTextStyles.secondary.copyWith(
                color: RadarColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: RadarSpacing.sm),
        buildReasoningSection(
          title: 'Sévérité maximale',
          icon: Icons.trending_up_rounded,
          color: radarSeverityColor(severity),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: buildReasoningBadge(
                label: presenter.severityLabel(severity),
                color: radarSeverityColor(severity),
              ),
            ),
          ],
        ),
        if (reasoning.alerts.isNotEmpty) ...[
          const SizedBox(height: RadarSpacing.sm),
          buildReasoningSection(
            title: 'Alertes cliniques',
            icon: Icons.notification_important_outlined,
            color: radarAlertLevelColor(reasoning.alerts.first.level),
            children: reasoning.alerts
                .map(
                  (alert) => buildReasoningDisplayItem(
                    presenter.alert(alert),
                    color: radarAlertLevelColor(alert.level),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        if (reasoning.recommendations.isNotEmpty) ...[
          const SizedBox(height: RadarSpacing.sm),
          buildReasoningSection(
            title: 'Recommandations',
            icon: Icons.fact_check_outlined,
            color: RadarColors.primary,
            children: reasoning.recommendations
                .map(
                  (recommendation) => buildReasoningDisplayItem(
                    presenter.recommendation(recommendation),
                    color: radarRecommendationPriorityColor(
                      recommendation.priority,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        if (reasoning.findings.isNotEmpty) ...[
          const SizedBox(height: RadarSpacing.sm),
          buildReasoningSection(
            title: 'Éléments retenus',
            icon: Icons.checklist_rounded,
            color: RadarColors.textSecondary,
            children: reasoning.findings
                .map(
                  (finding) => buildReasoningDisplayItem(
                    presenter.finding(finding),
                    color: radarSeverityColor(finding.severity),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

  Widget buildReasoningSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.small),
                ),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: RadarSpacing.sm),
              Expanded(child: Text(title, style: RadarTextStyles.question)),
            ],
          ),
          const SizedBox(height: RadarSpacing.md),
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              const Divider(height: RadarSpacing.xl, color: RadarColors.border),
            children[index],
          ],
        ],
      ),
    );
  }

  Widget buildReasoningDisplayItem(
    ClinicalDisplayData data, {
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                data.title,
                style: RadarTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: RadarSpacing.sm),
            buildReasoningBadge(label: data.badgeLabel, color: color),
          ],
        ),
        const SizedBox(height: RadarSpacing.xs),
        Text(data.body, style: RadarTextStyles.secondary),
      ],
    );
  }

  Widget buildReasoningBadge({required String label, required Color color}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadarRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadarSpacing.sm,
          vertical: RadarSpacing.xs,
        ),
        child: Text(label, style: RadarTextStyles.badge.copyWith(color: color)),
      ),
    );
  }

  Color radarAlertLevelColor(ClinicalAlertLevel level) {
    switch (level) {
      case ClinicalAlertLevel.info:
        return RadarColors.primary;
      case ClinicalAlertLevel.warning:
        return RadarColors.clinicalWarning;
      case ClinicalAlertLevel.urgent:
      case ClinicalAlertLevel.critical:
        return RadarColors.clinicalDanger;
    }
  }

  Color radarRecommendationPriorityColor(
    ClinicalRecommendationPriority priority,
  ) {
    switch (priority) {
      case ClinicalRecommendationPriority.low:
        return RadarColors.textSecondary;
      case ClinicalRecommendationPriority.medium:
        return RadarColors.primary;
      case ClinicalRecommendationPriority.high:
        return RadarColors.clinicalWarning;
      case ClinicalRecommendationPriority.urgent:
        return RadarColors.clinicalDanger;
    }
  }

  Color radarSeverityColor(ClinicalSeverity severity) {
    switch (severity) {
      case ClinicalSeverity.low:
        return RadarColors.clinicalSuccess;
      case ClinicalSeverity.moderate:
        return RadarColors.clinicalWarning;
      case ClinicalSeverity.high:
      case ClinicalSeverity.critical:
        return RadarColors.clinicalDanger;
      case ClinicalSeverity.unknown:
        return RadarColors.textSecondary;
    }
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
          const SizedBox(height: RadarSpacing.md),
          buildTimelineItem(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Évaluation réalisée',
            value: '${formatDate(evaluation['date'])} · $motif',
            color: RadarColors.primary,
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
                ? RadarColors.textSecondary
                : riskColor,
          ),
          buildTimelineItem(
            icon: Icons.fact_check_outlined,
            title: 'Recommandations',
            value: reasoning.recommendations.isEmpty
                ? 'Aucune recommandation sauvegardée'
                : '${reasoning.recommendations.length} recommandation(s)',
            color: RadarColors.primary,
          ),
          buildTimelineItem(
            icon: Icons.route_rounded,
            title: 'Orientation proposée',
            value: decisionTitle,
            color: RadarColors.indigo,
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
                Container(width: 2, height: 8, color: RadarColors.border),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.pill),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              if (!isLast)
                Container(width: 2, height: 20, color: RadarColors.border),
            ],
          ),
        ),
        const SizedBox(width: RadarSpacing.sm),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 3 : 11, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RadarTextStyles.body.copyWith(
                    color: RadarColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: RadarTextStyles.caption.copyWith(
                    color: RadarColors.textSecondary,
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
          const SizedBox(height: RadarSpacing.md),
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
              color: RadarColors.successSoft,
              borderRadius: BorderRadius.circular(RadarRadius.card),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: RadarColors.clinicalSuccess,
              size: 26,
            ),
          ),
          const SizedBox(width: RadarSpacing.sm),
          Expanded(
            child: Text(
              'Aucun drapeau rouge coché dans ce bilan.',
              style: RadarTextStyles.body,
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
      margin: const EdgeInsets.only(bottom: RadarSpacing.sm),
      padding: const EdgeInsets.all(RadarSpacing.md),
      decoration: BoxDecoration(
        color: RadarColors.background,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        border: Border.all(color: RadarColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
              border: Border.all(color: riskColor.withValues(alpha: 0.14)),
            ),
            child: Icon(Icons.flag_rounded, color: riskColor, size: 24),
          ),
          const SizedBox(width: RadarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null) ...[
                  Text(
                    category,
                    style: RadarTextStyles.caption.copyWith(
                      color: RadarColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: RadarTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RadarSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(RadarRadius.pill),
                      border: Border.all(
                        color: riskColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      severity,
                      style: RadarTextStyles.badge.copyWith(color: riskColor),
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
              backgroundColor: RadarColors.primary,
              foregroundColor: RadarColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: RadarTextStyles.badge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadarRadius.card),
              ),
            ),
          ),
        ),
        const SizedBox(height: RadarSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Supprimer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RadarColors.clinicalDanger,
              side: BorderSide(
                color: RadarColors.clinicalDanger.withValues(alpha: 0.35),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: RadarTextStyles.badge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadarRadius.card),
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
            color: RadarColors.surfaceMuted,
            borderRadius: BorderRadius.circular(RadarRadius.small),
          ),
          child: Icon(icon, color: RadarColors.primary, size: 20),
        ),
        const SizedBox(width: RadarSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RadarTextStyles.sectionTitle.copyWith(
                  color: RadarColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: RadarTextStyles.caption.copyWith(
                  color: RadarColors.textSecondary,
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
