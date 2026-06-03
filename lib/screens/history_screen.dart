import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/history_service.dart';
import 'evaluation/evaluation_detail_screen.dart';

enum HistoryFilter { all, critical, high, moderate, low, anonymous }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> history = [];
  String searchQuery = '';
  HistoryFilter selectedFilter = HistoryFilter.all;

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

    if (!mounted) return;

    setState(() {
      history = loadedHistory;
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadHistory,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
            children: [
              buildCompactHeader(),
              const SizedBox(height: 10),
              buildStatsRow(),
              const SizedBox(height: 10),
              buildSearchBar(),
              const SizedBox(height: 10),
              buildFilterChips(),
              const SizedBox(height: 10),
              if (history.isNotEmpty) buildDeleteHistoryButton(),
              if (history.isNotEmpty) const SizedBox(height: 12),
              if (history.isEmpty) buildEmptyState(),
              if (history.isNotEmpty && results.isEmpty) buildNoResultState(),
              if (results.isNotEmpty) ...results.map(buildHistoryCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCompactHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
              ),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Évaluations sauvegardées',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: buildStatCard(
            label: 'Bilans',
            value: '$totalEvaluations',
            icon: Icons.assignment_turned_in_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: buildStatCard(
            label: 'Élevés',
            value: '$highRiskCount',
            icon: Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: buildStatCard(
            label: 'Drapeaux',
            value: '$totalFlags',
            icon: Icons.flag_rounded,
          ),
        ),
      ],
    );
  }

  Widget buildStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 19),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
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
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  Widget buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildFilterChip('Tous', HistoryFilter.all),
          buildFilterChip('Critique', HistoryFilter.critical),
          buildFilterChip('Élevé', HistoryFilter.high),
          buildFilterChip('Modéré', HistoryFilter.moderate),
          buildFilterChip('Faible', HistoryFilter.low),
          buildFilterChip('Anonyme', HistoryFilter.anonymous),
        ],
      ),
    );
  }

  Widget buildFilterChip(String label, HistoryFilter filter) {
    final selected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
        selectedColor: const Color(0xFFEFF6FF),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
    );
  }

  Widget buildDeleteHistoryButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: clearHistory,
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: const Text('Supprimer'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return buildInfoState(
      icon: Icons.history_rounded,
      title: 'Aucun bilan enregistré',
      text: 'Les évaluations sauvegardées apparaîtront ici.',
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
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: riskColor(risk).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(motifIcon(motif), color: riskColor(risk), size: 27),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientDisplayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    motif,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatDate(item['date']),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      buildRiskBadge(risk),
                      buildSmallBadge('$checkedCountValue drapeau(x)'),
                      if (isAnonymous) buildAnonymousBadge(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                const Text(
                  'Score',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  scoreValue,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRiskBadge(String risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: riskColor(risk).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
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

  Widget buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget buildAnonymousBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Text(
        'Anonyme',
        style: TextStyle(
          color: Color(0xFFC2410C),
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}
