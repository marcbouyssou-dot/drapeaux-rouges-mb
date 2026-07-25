import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/attestation/attestation_history_item.dart';
import '../models/attestation/attestation_template.dart';
import '../models/medical_letter/medical_letter_history_item.dart';
import '../models/medical_letter/medical_letter_template.dart';
import '../models/prescription_model.dart';
import '../services/attestation_history_service.dart';
import '../services/history_service.dart';
import '../services/medical_letter_history_service.dart';
import '../services/offline_sync_service.dart';
import '../services/prescription_service.dart';
import '../features/radar/presentation/theme/radar_colors.dart';
import '../features/radar/presentation/theme/radar_layout.dart';
import '../features/radar/presentation/theme/radar_radius.dart';
import '../features/radar/presentation/theme/radar_shadows.dart';
import '../features/radar/presentation/theme/radar_spacing.dart';
import '../features/radar/presentation/theme/radar_text_styles.dart';
import '../features/radar/presentation/theme/radar_theme.dart';
import '../features/radar/presentation/widgets/radar_destructive_confirmation_dialog.dart';
import '../features/radar/presentation/widgets/radar_page_header.dart';
import 'evaluation/evaluation_detail_screen.dart';
import 'attestation/attestation_history_detail_screen.dart';
import 'medical_letter/medical_letter_history_detail_screen.dart';
import 'prescription/prescription_history_detail_screen.dart';

enum HistoryFilter { all, critical, high, moderate, low, anonymous }

enum HistoryView { evaluations, prescriptions, attestations, medicalLetters }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> history = [];
  List<PrescriptionModel> prescriptions = [];
  List<AttestationHistoryItem> attestations = [];
  List<MedicalLetterHistoryItem> medicalLetters = [];
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
    final loadedAttestations =
        await AttestationHistoryService.getAttestations();
    final loadedMedicalLetters = await MedicalLetterHistoryService.getLetters();

    if (!mounted) return;

    setState(() {
      history = loadedHistory;
      prescriptions = loadedPrescriptions;
      attestations = loadedAttestations;
      medicalLetters = loadedMedicalLetters;
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

  List<AttestationHistoryItem> get filteredAttestations {
    final query = searchQuery.trim().toLowerCase();

    final filtered = attestations.where((item) {
      if (query.isEmpty) return true;

      return [
        item.title,
        item.pdfTitle,
        item.displayPatient,
        item.lieu,
        item.signatureStatus,
        formatDate(item.generatedAt.toIso8601String()),
      ].join(' ').toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return filtered;
  }

  List<MedicalLetterHistoryItem> get filteredMedicalLetters {
    final query = searchQuery.trim().toLowerCase();

    final filtered = medicalLetters.where((item) {
      if (query.isEmpty) return true;

      return [
        item.title,
        item.pdfTitle,
        item.displayPatient,
        item.patientMedecinNom,
        item.subject,
        item.lieu,
        item.practitionerSignatureStatus,
        formatDate(item.generatedAt.toIso8601String()),
      ].join(' ').toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
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
    final confirm = await showRadarDestructiveConfirmationDialog(
      context,
      title: 'Supprimer tout l’historique ?',
      message:
          'Cette action supprimera toutes les évaluations enregistrées localement.',
      confirmLabel: 'Supprimer',
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

    if (riskLower.contains('critique')) return RadarColors.clinicalDanger;
    if (riskLower.contains('élevé') || riskLower.contains('eleve')) {
      return RadarColors.clinicalWarning;
    }
    if (riskLower.contains('modéré') || riskLower.contains('modere')) {
      return RadarColors.clinicalWarning;
    }

    return RadarColors.clinicalSuccess;
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

  int get totalAttestations => attestations.length;

  int get totalMedicalLetters => medicalLetters.length;

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
    final attestationResults = filteredAttestations;
    final medicalLetterResults = filteredMedicalLetters;
    final showEvaluations = selectedView == HistoryView.evaluations;
    final showPrescriptions = selectedView == HistoryView.prescriptions;
    final showAttestations = selectedView == HistoryView.attestations;
    final showMedicalLetters = selectedView == HistoryView.medicalLetters;

    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadHistory,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: RadarLayout.historyWidth,
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    RadarSpacing.xl,
                    RadarSpacing.xl,
                    RadarSpacing.xl,
                    112,
                  ),
                  children: [
                    const RadarPageHeader(
                      title: 'Historique',
                      subtitle:
                          'Retrouver les évaluations et documents générés.',
                    ),
                    const SizedBox(height: RadarSpacing.xxl),
                    buildStatsRow(),
                    const SizedBox(height: RadarSpacing.lg),
                    buildSearchBar(),
                    const SizedBox(height: RadarSpacing.lg),
                    buildHistoryViewSwitch(),
                    if (showEvaluations) ...[
                      const SizedBox(height: RadarSpacing.lg),
                      buildFilterChips(),
                      if (history.isNotEmpty) ...[
                        const SizedBox(height: RadarSpacing.lg),
                        buildDeleteHistoryButton(),
                      ],
                    ],
                    const SizedBox(height: RadarSpacing.lg),
                    if (showEvaluations) ...[
                      if (history.isEmpty) buildEmptyState(),
                      if (history.isNotEmpty && results.isEmpty)
                        buildNoResultState(),
                      if (results.isNotEmpty) ...results.map(buildHistoryCard),
                    ] else if (showPrescriptions) ...[
                      if (prescriptions.isEmpty) buildPrescriptionEmptyState(),
                      if (prescriptions.isNotEmpty &&
                          prescriptionResults.isEmpty)
                        buildNoResultState(),
                      if (prescriptionResults.isNotEmpty)
                        ...prescriptionResults.map(buildPrescriptionCard),
                    ] else if (showAttestations) ...[
                      if (attestations.isEmpty) buildAttestationEmptyState(),
                      if (attestations.isNotEmpty && attestationResults.isEmpty)
                        buildNoResultState(),
                      if (attestationResults.isNotEmpty)
                        ...attestationResults.map(buildAttestationCard),
                    ] else if (showMedicalLetters) ...[
                      if (medicalLetters.isEmpty)
                        buildMedicalLetterEmptyState(),
                      if (medicalLetters.isNotEmpty &&
                          medicalLetterResults.isEmpty)
                        buildNoResultState(),
                      if (medicalLetterResults.isNotEmpty)
                        ...medicalLetterResults.map(buildMedicalLetterCard),
                    ],
                  ],
                ),
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
            color: RadarColors.primary,
          ),
          buildStatCard(
            label: 'Risques élevés',
            value: '$highRiskCount',
            icon: Icons.warning_amber_rounded,
            color: RadarColors.clinicalWarning,
          ),
          buildStatCard(
            label: 'Drapeaux',
            value: '$totalFlags',
            icon: Icons.flag_rounded,
            color: RadarColors.clinicalDanger,
          ),
          buildStatCard(
            label: 'Prescriptions',
            value: '$totalPrescriptions',
            icon: Icons.description_outlined,
            color: RadarColors.clinicalAction,
          ),
          buildStatCard(
            label: 'Attestations',
            value: '$totalAttestations',
            icon: Icons.history_edu_outlined,
            color: RadarColors.indigo,
          ),
          buildStatCard(
            label: 'Courriers',
            value: '$totalMedicalLetters',
            icon: Icons.mark_email_read_outlined,
            color: RadarColors.slate,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: card == cards.last ? 0 : RadarSpacing.sm,
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
                      right: card == cards.last ? 0 : RadarSpacing.sm,
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
      padding: const EdgeInsets.fromLTRB(
        RadarSpacing.sm,
        RadarSpacing.md,
        RadarSpacing.sm,
        RadarSpacing.md,
      ),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: RadarSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RadarTextStyles.contextTitle.copyWith(fontSize: 18),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RadarTextStyles.caption.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(RadarSpacing.sm),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
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
          fillColor: RadarColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: RadarSpacing.lg,
            vertical: RadarSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
            borderSide: const BorderSide(color: RadarColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
            borderSide: const BorderSide(color: RadarColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
            borderSide: const BorderSide(
              color: RadarColors.primary,
              width: 1.6,
            ),
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
      padding: const EdgeInsets.all(RadarSpacing.xs),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.pill),
        boxShadow: RadarShadows.card,
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
          buildHistoryViewButton(
            label: 'Attestations',
            icon: Icons.history_edu_outlined,
            view: HistoryView.attestations,
          ),
          buildHistoryViewButton(
            label: 'Courriers',
            icon: Icons.mark_email_read_outlined,
            view: HistoryView.medicalLetters,
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
        borderRadius: BorderRadius.circular(RadarRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? RadarColors.surfaceMuted : Colors.transparent,
            borderRadius: BorderRadius.circular(RadarRadius.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? RadarColors.primary
                    : RadarColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? RadarColors.primary
                        : RadarColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
          color: selected ? RadarColors.primary : RadarColors.textSecondary,
        ),
        label: Text(label),
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
        labelStyle: TextStyle(
          color: selected ? RadarColors.primary : RadarColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        selectedColor: RadarColors.surfaceMuted,
        backgroundColor: RadarColors.surface,
        side: const BorderSide(color: RadarColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadarRadius.pill),
        ),
      ),
    );
  }

  Widget buildDeleteHistoryButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(RadarSpacing.sm),
        decoration: BoxDecoration(
          color: RadarColors.clinicalDanger.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(RadarRadius.card),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: clearHistory,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Supprimer l’historique'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RadarColors.clinicalDanger,
              side: BorderSide(
                color: RadarColors.clinicalDanger.withValues(alpha: 0.35),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadarRadius.small),
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

  Widget buildAttestationEmptyState() {
    return buildInfoState(
      icon: Icons.history_edu_outlined,
      title: 'Aucune attestation générée',
      text:
          'Les attestations patient générées apparaîtront ici avec leur patient, leur date et leur signature.',
    );
  }

  Widget buildMedicalLetterEmptyState() {
    return buildInfoState(
      icon: Icons.mark_email_read_outlined,
      title: 'Aucun courrier médical généré',
      text:
          'Les courriers médicaux générés apparaîtront ici avec leur patient, leur type et leur date.',
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
      margin: const EdgeInsets.only(top: RadarSpacing.xs),
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: RadarColors.surfaceMuted,
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(icon, size: 31, color: RadarColors.primary),
          ),
          const SizedBox(height: RadarSpacing.lg),
          Text(
            title,
            style: RadarTextStyles.contextTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: RadarSpacing.sm),
          Text(
            text,
            textAlign: TextAlign.center,
            style: RadarTextStyles.secondary,
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
        margin: const EdgeInsets.only(bottom: RadarSpacing.lg),
        padding: const EdgeInsets.all(RadarSpacing.lg),
        decoration: BoxDecoration(
          color: RadarColors.surface,
          borderRadius: BorderRadius.circular(RadarRadius.card),
          boxShadow: RadarShadows.card,
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
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: Icon(
                    motifIcon(motif),
                    color: riskColor(risk),
                    size: 25,
                  ),
                ),
                const SizedBox(width: RadarSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientDisplayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.contextTitle.copyWith(
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        motif,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.secondary.copyWith(
                          color: RadarColors.textPrimary,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: RadarSpacing.sm),
                buildScorePill(scoreValue),
              ],
            ),
            const SizedBox(height: RadarSpacing.md),
            Wrap(
              spacing: RadarSpacing.sm,
              runSpacing: RadarSpacing.sm,
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
                buildSyncBadge(item),
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
      onTap: () async {
        final deleted = await Navigator.push<bool>(
          context,
          CupertinoPageRoute(
            builder: (_) => PrescriptionHistoryDetailScreen(prescription: item),
          ),
        );

        if (deleted == true) {
          await loadHistory();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: RadarSpacing.lg),
        padding: const EdgeInsets.all(RadarSpacing.lg),
        decoration: BoxDecoration(
          color: RadarColors.surface,
          borderRadius: BorderRadius.circular(RadarRadius.card),
          boxShadow: RadarShadows.card,
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
                    color: RadarColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: RadarColors.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: RadarSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayPatient,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.contextTitle.copyWith(
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        item.displayType,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.secondary.copyWith(
                          color: RadarColors.textPrimary,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RadarColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: RadarSpacing.md),
            Wrap(
              spacing: RadarSpacing.sm,
              runSpacing: RadarSpacing.sm,
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

  Widget buildAttestationCard(AttestationHistoryItem item) {
    final template = attestationTemplateByTypeId(item.typeId);

    return GestureDetector(
      onTap: () async {
        final deleted = await Navigator.push<bool>(
          context,
          CupertinoPageRoute(
            builder: (_) => AttestationHistoryDetailScreen(attestation: item),
          ),
        );

        if (deleted == true) {
          await loadHistory();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: RadarSpacing.lg),
        padding: const EdgeInsets.all(RadarSpacing.lg),
        decoration: BoxDecoration(
          color: RadarColors.surface,
          borderRadius: BorderRadius.circular(RadarRadius.card),
          boxShadow: RadarShadows.card,
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
                    color: template.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: Icon(template.icon, color: template.color, size: 25),
                ),
                const SizedBox(width: RadarSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.contextTitle.copyWith(
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        item.displayPatient,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.secondary.copyWith(
                          color: RadarColors.textPrimary,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RadarColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: RadarSpacing.md),
            Wrap(
              spacing: RadarSpacing.sm,
              runSpacing: RadarSpacing.sm,
              children: [
                buildSmallBadge(
                  icon: Icons.event_outlined,
                  text: formatDate(item.generatedAt.toIso8601String()),
                ),
                buildSmallBadge(
                  icon: item.hasSignature
                      ? Icons.draw_outlined
                      : Icons.edit_off_outlined,
                  text: item.signatureStatus,
                ),
                buildSmallBadge(
                  icon: template.isActive
                      ? Icons.check_circle_outline_rounded
                      : Icons.pending_actions_outlined,
                  text: template.statusLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicalLetterCard(MedicalLetterHistoryItem item) {
    final template = medicalLetterTemplateByTypeId(item.typeId);

    return GestureDetector(
      onTap: () async {
        final deleted = await Navigator.push<bool>(
          context,
          CupertinoPageRoute(
            builder: (_) => MedicalLetterHistoryDetailScreen(letter: item),
          ),
        );

        if (deleted == true) {
          await loadHistory();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: RadarSpacing.lg),
        padding: const EdgeInsets.all(RadarSpacing.lg),
        decoration: BoxDecoration(
          color: RadarColors.surface,
          borderRadius: BorderRadius.circular(RadarRadius.card),
          boxShadow: RadarShadows.card,
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
                    color: template.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: Icon(template.icon, color: template.color, size: 25),
                ),
                const SizedBox(width: RadarSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.contextTitle.copyWith(
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        item.displayPatient,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.secondary.copyWith(
                          color: RadarColors.textPrimary,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RadarColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: RadarSpacing.md),
            Wrap(
              spacing: RadarSpacing.sm,
              runSpacing: RadarSpacing.sm,
              children: [
                buildSmallBadge(
                  icon: Icons.event_outlined,
                  text: formatDate(item.generatedAt.toIso8601String()),
                ),
                buildSmallBadge(
                  icon: Icons.local_hospital_outlined,
                  text: item.patientMedecinNom.trim().isEmpty
                      ? 'Médecin non renseigné'
                      : item.patientMedecinNom.trim(),
                ),
                buildSmallBadge(
                  icon: item.hasPractitionerSignature
                      ? Icons.draw_outlined
                      : Icons.edit_off_outlined,
                  text: item.practitionerSignatureStatus,
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
        color: RadarColors.background,
        borderRadius: BorderRadius.circular(RadarRadius.small),
      ),
      child: Column(
        children: [
          Text('Score', style: RadarTextStyles.caption.copyWith(fontSize: 10)),
          Text(
            scoreValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RadarTextStyles.contextTitle.copyWith(fontSize: 24),
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
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Text(
        risk,
        style: TextStyle(
          color: riskColor(risk),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget buildSyncBadge(Map<String, dynamic> item) {
    final status = SyncStatus.fromValue(item['syncStatus']);

    final Color color;
    final IconData icon;
    final String text;

    switch (status) {
      case SyncStatus.synced:
        color = RadarColors.clinicalSuccess;
        icon = Icons.cloud_done_outlined;
        text = 'Synchronisé';
      case SyncStatus.pendingSync:
      case SyncStatus.syncing:
        color = RadarColors.clinicalWarning;
        icon = Icons.cloud_upload_outlined;
        text = 'En attente';
      case SyncStatus.syncFailed:
        color = RadarColors.clinicalDanger;
        icon = Icons.cloud_off_outlined;
        text = 'Échec sync';
      case SyncStatus.localOnly:
        color = RadarColors.textSecondary;
        icon = Icons.phone_iphone_rounded;
        text = 'Local';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: RadarSpacing.xs),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSmallBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: RadarColors.background,
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RadarColors.textSecondary, size: 13),
          const SizedBox(width: RadarSpacing.xs),
          Text(
            text,
            style: RadarTextStyles.caption.copyWith(
              color: RadarColors.textSecondary,
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
        color: RadarColors.clinicalWarning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.no_accounts_outlined,
            color: RadarColors.clinicalWarning,
            size: 13,
          ),
          SizedBox(width: RadarSpacing.xs),
          Text(
            'Anonyme',
            style: TextStyle(
              color: RadarColors.clinicalWarning,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
