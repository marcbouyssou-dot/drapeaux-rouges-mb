import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/prescription_model.dart';
import '../services/history_service.dart';
import '../services/prescription_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'evaluation/evaluation_detail_screen.dart';
import 'prescription/prescription_history_detail_screen.dart';

enum HistoryFilter { all, critical, high, moderate, low, anonymous }

enum HistoryView { evaluations, prescriptions }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> history = [];
  List<PrescriptionModel> prescriptions = [];
  String searchQuery = '';
  HistoryFilter selectedFilter = HistoryFilter.all;
  HistoryView selectedView = HistoryView.evaluations;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadHistory() async {
    final loadedHistory = await HistoryService.loadHistory();
    final loadedPrescriptions = await PrescriptionService.getPrescriptions();

    if (!mounted) return;

    setState(() {
      history = loadedHistory;
      prescriptions = loadedPrescriptions;
    });
  }

  List<Map<String, dynamic>> get filteredHistory {
    final query = searchQuery.trim().toLowerCase();

    final filtered = history.where((item) {
      final matchesSearch =
          query.isEmpty || searchableText(item).contains(query);
      final matchesFilter = filterMatches(item);

      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1900);
      final dateB =
          DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1900);

      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  List<PrescriptionModel> get filteredPrescriptions {
    final query = searchQuery.trim().toLowerCase();

    final filtered = prescriptions.where((item) {
      if (query.isEmpty) return true;

      return [
        item.displayPatient,
        item.displayType,
        item.prescription,
        item.professional,
        formatDate(item.createdAt.toIso8601String()),
      ].join(' ').toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  String searchableText(Map<String, dynamic> item) {
    final flags = checkedFlagsText(item);

    return [
      patientName(item),
      item['motif']?.toString() ?? '',
      riskLevel(item),
      item['score']?.toString() ?? '',
      item['checkedCount']?.toString() ?? '',
      item['decisionTitle']?.toString() ?? '',
      item['decisionMessage']?.toString() ?? '',
      item['aiSummary']?.toString() ?? '',
      formatDate(item['date']),
      flags,
    ].join(' ').toLowerCase();
  }

  String checkedFlagsText(Map<String, dynamic> item) {
    final raw = item['checkedFlags'];
    if (raw is! List) return '';

    return raw
        .map((flag) {
          if (flag is! Map) return '';
          return [
            flag['title']?.toString() ?? '',
            flag['severity']?.toString() ?? '',
            flag['category']?.toString() ?? '',
          ].join(' ');
        })
        .join(' ');
  }

  bool filterMatches(Map<String, dynamic> item) {
    final risk = riskLevel(item).toLowerCase();
    final anonymous = patientName(item) == 'Patient non renseigné';

    switch (selectedFilter) {
      case HistoryFilter.all:
        return true;
      case HistoryFilter.critical:
        return risk.contains('critique');
      case HistoryFilter.high:
        return risk.contains('élevé') || risk.contains('eleve');
      case HistoryFilter.moderate:
        return risk.contains('modéré') || risk.contains('modere');
      case HistoryFilter.low:
        return risk.contains('faible');
      case HistoryFilter.anonymous:
        return anonymous;
    }
  }

  Future<void> clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer tout l’historique ?'),
          content: const Text(
            'Cette action supprimera toutes les évaluations enregistrées localement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await HistoryService.clearHistory();
    await loadHistory();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Historique supprimé')));
  }

  String patientName(Map<String, dynamic> item) {
    return item['patientDisplayName']?.toString() ??
        item['patientCode']?.toString() ??
        'Patient non renseigné';
  }

  String riskLevel(Map<String, dynamic> item) {
    return item['riskLevel']?.toString() ??
        item['risk']?.toString() ??
        'Risque inconnu';
  }

  Color riskColor(String risk) {
    final riskLower = risk.toLowerCase();

    if (riskLower.contains('critique')) return const Color(0xFFDC2626);
    if (riskLower.contains('élevé') || riskLower.contains('eleve')) {
      return const Color(0xFFF97316);
    }
    if (riskLower.contains('modéré') || riskLower.contains('modere')) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF22C55E);
  }

  IconData motifIcon(String motif) {
    final motifLower = motif.toLowerCase();

    if (motifLower.contains('lomb')) return Icons.accessibility_new_rounded;
    if (motifLower.contains('cerv')) return Icons.psychology_alt_outlined;
    if (motifLower.contains('resp')) return Icons.air_rounded;
    if (motifLower.contains('card')) return Icons.favorite_border_rounded;
    if (motifLower.contains('tvp') || motifLower.contains('vasc')) {
      return Icons.water_drop_outlined;
    }
    if (motifLower.contains('entorse')) return Icons.directions_walk_rounded;
    if (motifLower.contains('ortho')) return Icons.medical_services_outlined;
    if (motifLower.contains('post')) return Icons.healing_rounded;

    return Icons.monitor_heart_outlined;
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

  int get totalEvaluations => history.length;

  int get totalPrescriptions => prescriptions.length;

  int get totalFlags {
    return history.fold<int>(0, (sum, item) {
      final value = item['checkedCount'];

      if (value is int) return sum + value;

      return sum + (int.tryParse(value?.toString() ?? '') ?? 0);
    });
  }

  int get highRiskCount {
    return history.where((item) {
      final risk = riskLevel(item).toLowerCase();
      return risk.contains('critique') ||
          risk.contains('élevé') ||
          risk.contains('eleve');
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredHistory;
    final prescriptionResults = filteredPrescriptions;
    final showEvaluations = selectedView == HistoryView.evaluations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadHistory,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  112,
                ),
                children: [
                  buildStatsRow(),
                  const SizedBox(height: AppSpacing.sm),
                  buildSearchBar(),
                  const SizedBox(height: AppSpacing.sm),
                  buildHistoryViewSwitch(),
                  if (showEvaluations) ...[
                    const SizedBox(height: AppSpacing.sm),
                    buildFilterChips(),
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      buildDeleteHistoryButton(),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  if (showEvaluations) ...[
                    if (history.isEmpty) buildEmptyState(),
                    if (history.isNotEmpty && results.isEmpty)
                      buildNoResultState(),
                    if (results.isNotEmpty) ...results.map(buildHistoryCard),
                  ] else ...[
                    if (prescriptions.isEmpty) buildPrescriptionEmptyState(),
                    if (prescriptions.isNotEmpty && prescriptionResults.isEmpty)
                      buildNoResultState(),
                    if (prescriptionResults.isNotEmpty)
                      ...prescriptionResults.map(buildPrescriptionCard),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        final cards = [
          buildStatCard(
            label: 'Bilans',
            value: '$totalEvaluations',
            icon: Icons.assignment_turned_in_outlined,
            color: AppColors.primary,
          ),
          buildStatCard(
            label: 'Risques élevés',
            value: '$highRiskCount',
            icon: Icons.warning_amber_rounded,
            color: AppColors.warningDark,
          ),
          buildStatCard(
            label: 'Drapeaux',
            value: '$totalFlags',
            icon: Icons.flag_rounded,
            color: AppColors.danger,
          ),
          buildStatCard(
            label: 'Prescriptions',
            value: '$totalPrescriptions',
            icon: Icons.description_outlined,
            color: AppColors.primaryDark,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: card == cards.last ? 0 : AppSpacing.sm,
                      ),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: card == cards.last ? 0 : AppSpacing.sm,
                    ),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 9, 8, 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher patient, motif, décision...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Effacer la recherche',
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildFilterChip('Tous', HistoryFilter.all, Icons.all_inbox_rounded),
          buildFilterChip(
            'Critique',
            HistoryFilter.critical,
            Icons.priority_high_rounded,
          ),
          buildFilterChip(
            'Élevé',
            HistoryFilter.high,
            Icons.warning_amber_rounded,
          ),
          buildFilterChip(
            'Modéré',
            HistoryFilter.moderate,
            Icons.report_gmailerrorred_rounded,
          ),
          buildFilterChip(
            'Faible',
            HistoryFilter.low,
            Icons.check_circle_outline_rounded,
          ),
          buildFilterChip(
            'Anonyme',
            HistoryFilter.anonymous,
            Icons.no_accounts_outlined,
          ),
        ],
      ),
    );
  }

  Widget buildHistoryViewSwitch() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          buildHistoryViewButton(
            label: 'Évaluations',
            icon: Icons.assignment_turned_in_outlined,
            view: HistoryView.evaluations,
          ),
          buildHistoryViewButton(
            label: 'Prescriptions',
            icon: Icons.description_outlined,
            view: HistoryView.prescriptions,
          ),
        ],
      ),
    );
  }

  Widget buildHistoryViewButton({
    required String label,
    required IconData icon,
    required HistoryView view,
  }) {
    final selected = selectedView == view;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedView = view;
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterChip(String label, HistoryFilter filter, IconData icon) {
    final selected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        avatar: Icon(
          icon,
          size: 16,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
        label: Text(label),
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
        selectedColor: AppColors.surfaceAlt,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: selected ? AppColors.borderStrong : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }

  Widget buildDeleteHistoryButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.16)),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: clearHistory,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Supprimer l’historique'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return buildInfoState(
      icon: Icons.history_rounded,
      title: 'Aucun bilan enregistré',
      text:
          'Les évaluations sauvegardées apparaîtront ici avec leur patient, leur date et leur niveau de risque.',
    );
  }

  Widget buildPrescriptionEmptyState() {
    return buildInfoState(
      icon: Icons.description_outlined,
      title: 'Aucune prescription enregistrée',
      text:
          'Les prescriptions générées apparaîtront ici avec leur patient, leur type et leur date.',
    );
  }

  Widget buildNoResultState() {
    return buildInfoState(
      icon: Icons.search_off_rounded,
      title: 'Aucun résultat',
      text: 'Essayez un autre patient, motif, risque ou mot-clé clinique.',
    );
  }

  Widget buildInfoState({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, size: 31, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> item) {
    final risk = riskLevel(item);
    final motif = item['motif']?.toString() ?? 'Motif non renseigné';
    final scoreValue = item['score']?.toString() ?? '-';
    final checkedCountValue = item['checkedCount']?.toString() ?? '0';
    final patientDisplayName = patientName(item);
    final isAnonymous = patientDisplayName == 'Patient non renseigné';

    return GestureDetector(
      onTap: () async {
        final deleted = await Navigator.push<bool>(
          context,
          CupertinoPageRoute(
            builder: (_) => EvaluationDetailScreen(evaluation: item),
          ),
        );

        if (deleted == true) {
          await loadHistory();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: riskColor(risk).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: riskColor(risk).withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(
                    motifIcon(motif),
                    color: riskColor(risk),
                    size: 25,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientDisplayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        motif,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                buildScorePill(scoreValue),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                buildRiskBadge(risk),
                buildSmallBadge(
                  icon: Icons.flag_rounded,
                  text: '$checkedCountValue drapeau(x)',
                ),
                buildSmallBadge(
                  icon: Icons.event_outlined,
                  text: formatDate(item['date']),
                ),
                if (isAnonymous) buildAnonymousBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPrescriptionCard(PrescriptionModel item) {
    final hasJustificatif =
        item.justificatifImageBase64?.trim().isNotEmpty ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => PrescriptionHistoryDetailScreen(prescription: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayPatient,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.displayType,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.25,
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
            const SizedBox(height: 10),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                buildSmallBadge(
                  icon: Icons.event_outlined,
                  text: formatDate(item.createdAt.toIso8601String()),
                ),
                buildSmallBadge(
                  icon: Icons.picture_as_pdf_outlined,
                  text: 'PDF disponible',
                ),
                if (hasJustificatif)
                  buildSmallBadge(
                    icon: Icons.attach_file_rounded,
                    text: 'Justificatif',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScorePill(String scoreValue) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'Score',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            scoreValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRiskBadge(String risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: riskColor(risk).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: riskColor(risk).withValues(alpha: 0.35)),
      ),
      child: Text(
        risk,
        style: TextStyle(
          color: riskColor(risk),
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget buildSmallBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 13),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnonymousBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warningDark.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.warningDark.withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.no_accounts_outlined,
            color: AppColors.warningDark,
            size: 13,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            'Anonyme',
            style: TextStyle(
              color: AppColors.warningDark,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
