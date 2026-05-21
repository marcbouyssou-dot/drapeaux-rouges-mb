import 'package:flutter/material.dart';

import '../services/history_service.dart';
import 'evaluation/evaluation_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> history = [];
  String searchQuery = '';

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
      if (query.isEmpty) return true;

      final patient = patientName(item).toLowerCase();
      final motif = item['motif']?.toString().toLowerCase() ?? '';
      final risk = riskLevel(item).toLowerCase();
      final score = item['score']?.toString().toLowerCase() ?? '';
      final checkedCount = item['checkedCount']?.toString().toLowerCase() ?? '';

      return patient.contains(query) ||
          motif.contains(query) ||
          risk.contains(query) ||
          score.contains(query) ||
          checkedCount.contains(query);
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historique supprimé')),
    );
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

  double get averageScore {
    if (history.isEmpty) return 0;

    final total = history.fold<double>(0, (sum, item) {
      final value = item['score'];

      if (value is int) return sum + value;
      if (value is double) return sum + value;

      return sum + (double.tryParse(value.toString()) ?? 0);
    });

    return total / history.length;
  }

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

  String get mostFrequentMotif {
    if (history.isEmpty) return '-';

    final counts = <String, int>{};

    for (final item in history) {
      final motif = item['motif']?.toString() ?? 'Non renseigné';
      counts[motif] = (counts[motif] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
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
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 140),
            children: [
              buildModernHistoryHero(),
              const SizedBox(height: 18),
              buildSearchBar(),
              const SizedBox(height: 14),
              buildDeleteHistoryButton(),
              const SizedBox(height: 18),
              if (history.isEmpty) buildEmptyState(),
              if (history.isNotEmpty && results.isEmpty) buildNoResultState(),
              if (results.isNotEmpty) ...results.map(buildHistoryCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModernHistoryHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF60A5FA),
                  Color(0xFF2563EB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'HISTORIQUE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Consulter les évaluations enregistrées localement',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: buildHeroStat('Bilans', '$totalEvaluations'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildHeroStat('Risques élevés', '$highRiskCount'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildHeroStat('Drapeaux', '$totalFlags'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHeroStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
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
        hintText: 'Recherche patient, motif, risque, score...',
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
          horizontal: 18,
          vertical: 16,
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
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget buildDeleteHistoryButton() {
    if (history.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: clearHistory,
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: const Text('Supprimer l’historique'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      text: 'Essayez un autre patient, motif, risque ou score.',
    );
  }

  Widget buildInfoState({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 46, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
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
          MaterialPageRoute(
            builder: (_) => EvaluationDetailScreen(
              evaluation: item,
            ),
          ),
        );

        if (deleted == true) {
          await loadHistory();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: riskColor(risk).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                motifIcon(motif),
                color: riskColor(risk),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    motif,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(item['date']),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      buildRiskBadge(risk),
                      buildSmallBadge('$checkedCountValue drapeau(x)'),
                      if (isAnonymous) buildAnonymousBadge(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                const Text(
                  'Score',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  scoreValue,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 28,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildAnonymousBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          fontSize: 12,
        ),
      ),
    );
  }
}