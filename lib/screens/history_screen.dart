import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final loadedHistory = await HistoryService.loadHistory();

    setState(() {
      history = loadedHistory.reversed.toList();
    });
  }

  Future<void> clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer tout l’historique ?'),
          content: const Text(
            'Cette action supprimera toutes les évaluations enregistrées localement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              onPressed: () => Navigator.pop(context, true),
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
      const SnackBar(
        content: Text('Historique supprimé'),
      ),
    );
  }

  Color riskColor(String risk) {
    final riskLower = risk.toLowerCase();

    if (riskLower.contains('critique')) {
      return const Color(0xFFDC2626);
    }

    if (riskLower.contains('élevé')) {
      return const Color(0xFFF97316);
    }

    if (riskLower.contains('modéré')) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF22C55E);
  }

  IconData motifIcon(String motif) {
    final motifLower = motif.toLowerCase();

    if (motifLower.contains('lomb')) {
      return Icons.accessibility_new_rounded;
    }

    if (motifLower.contains('cerv')) {
      return Icons.psychology_alt_outlined;
    }

    if (motifLower.contains('resp')) {
      return Icons.air_rounded;
    }

    if (motifLower.contains('card')) {
      return Icons.favorite_border_rounded;
    }

    if (motifLower.contains('tvp') ||
        motifLower.contains('vasc')) {
      return Icons.water_drop_outlined;
    }

    if (motifLower.contains('entorse')) {
      return Icons.directions_walk_rounded;
    }

    if (motifLower.contains('ortho')) {
      return Icons.medical_services_outlined;
    }

    if (motifLower.contains('post')) {
      return Icons.healing_rounded;
    }

    return Icons.monitor_heart_outlined;
  }

  String formatDate(dynamic value) {
    final raw = value?.toString() ?? '';

    if (raw.isEmpty) {
      return 'Date inconnue';
    }

    try {
      return raw.replaceAll('T', ' ').substring(0, 16);
    } catch (_) {
      return raw;
    }
  }

  int get totalEvaluations => history.length;

  double get averageScore {
    if (history.isEmpty) return 0;

    final total = history.fold<double>(
      0,
      (sum, item) {
        final value = item['score'];

        if (value is int) return sum + value;
        if (value is double) return sum + value;

        return sum + (double.tryParse(value.toString()) ?? 0);
      },
    );

    return total / history.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
          children: [
            const AppHeader(),

            const SizedBox(height: 20),

            buildTitleRow(),

            const SizedBox(height: 18),

            buildStatsOverview(),

            const SizedBox(height: 18),

            buildSearchBar(),

            const SizedBox(height: 18),

            if (history.isEmpty)
              buildEmptyState(),

            if (history.isNotEmpty) ...[
              ...history.map(buildHistoryCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historique',
                style: AppTextStyles.pageTitle,
              ),

              SizedBox(height: 4),

              Text(
                'Toutes vos évaluations enregistrées',
                style: AppTextStyles.pageSubtitle,
              ),
            ],
          ),
        ),

        SizedBox(
          width: 150,
          child: OutlinedButton.icon(
            onPressed: history.isEmpty ? null : clearHistory,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
            ),
            label: const Text(
              'Supprimer',
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(
                color: Color(0xFFFCA5A5),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: buildOverviewItem(
              title: 'Évaluations',
              value: '$totalEvaluations',
            ),
          ),

          Container(
            width: 1,
            height: 54,
            color: Colors.white.withOpacity(0.25),
          ),

          Expanded(
            child: buildOverviewItem(
              title: 'Score moyen',
              value: averageScore.toStringAsFixed(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOverviewItem({
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.82),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Recherche patient, motif, score...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),

          Icon(
            Icons.search_rounded,
            color: Color(0xFF334155),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 46,
            color: Color(0xFF94A3B8),
          ),

          SizedBox(height: 14),

          Text(
            'Aucune évaluation enregistrée',
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> item) {
    final risk =
        item['risk']?.toString() ?? 'Risque inconnu';

    final motif =
        item['motif']?.toString() ?? 'Motif non renseigné';

    final score =
        item['score']?.toString() ?? '-';

    final patientCode =
        item['patientCode']?.toString() ??
            'Non renseigné';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
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
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              motifIcon(motif),
              color: const Color(0xFF2563EB),
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  patientCode,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 17,
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
                  style: AppTextStyles.cardSubtitle,
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        riskColor(risk).withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(99),
                    border: Border.all(
                      color:
                          riskColor(risk).withOpacity(0.35),
                    ),
                  ),
                  child: Text(
                    risk,
                    style: TextStyle(
                      color: riskColor(risk),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
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
                score,
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
    );
  }
}