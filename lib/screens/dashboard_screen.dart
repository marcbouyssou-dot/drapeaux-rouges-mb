import 'package:flutter/material.dart';

import '../services/history_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final data = await HistoryService.loadHistory();

    setState(() {
      history = data;
    });
  }

  int get totalEvaluations => history.length;

  int get criticalCount {
    return history.where((item) {
      final risk = item['risk'].toString().toLowerCase();
      return risk.contains('critique') || risk.contains('eleve');
    }).length;
  }

  int get moderateCount {
    return history.where((item) {
      final risk = item['risk'].toString().toLowerCase();
      return risk.contains('modere');
    }).length;
  }

  double get averageScore {
    if (history.isEmpty) return 0;

    final total = history.fold<int>(0, (sum, item) {
      return sum + (item['score'] as int);
    });

    return total / history.length;
  }

  Color get mainColor {
    if (criticalCount > 0) return Colors.red;
    if (moderateCount > 0) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildHeader(),
            const SizedBox(height: 18),
            buildStatsGrid(),
            const SizedBox(height: 18),
            buildRiskSummary(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mainColor,
            mainColor.withOpacity(0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 44,
          ),
          const SizedBox(height: 18),
          const Text(
            'Vue analytique',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$totalEvaluations evaluations',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.35,
      children: [
        statCard(
          title: 'Total',
          value: '$totalEvaluations',
          icon: Icons.assignment_rounded,
          color: Colors.blue,
        ),
        statCard(
          title: 'Score moyen',
          value: averageScore.toStringAsFixed(1),
          icon: Icons.speed_rounded,
          color: Colors.purple,
        ),
        statCard(
          title: 'Risques eleves',
          value: '$criticalCount',
          icon: Icons.warning_rounded,
          color: Colors.red,
        ),
        statCard(
          title: 'Risques moderes',
          value: '$moderateCount',
          icon: Icons.info_rounded,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRiskSummary() {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'Aucune donnee disponible. Enregistre une evaluation pour alimenter le dashboard.',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synthese',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text('Evaluations totales : $totalEvaluations'),
          Text('Risques eleves ou critiques : $criticalCount'),
          Text('Risques moderes : $moderateCount'),
          Text('Score moyen : ${averageScore.toStringAsFixed(1)}'),
        ],
      ),
    );
  }
}