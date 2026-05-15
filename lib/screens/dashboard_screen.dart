import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';

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
      final risk =
          item['risk']?.toString().toLowerCase() ?? '';

      return risk.contains('critique') ||
          risk.contains('élevé');
    }).length;
  }

  int get moderateCount {
    return history.where((item) {
      final risk =
          item['risk']?.toString().toLowerCase() ?? '';

      return risk.contains('modéré');
    }).length;
  }

  double get averageScore {
    if (history.isEmpty) return 0;

    final total = history.fold<double>(
      0,
      (sum, item) {
        final value = item['score'];

        if (value is int) return sum + value;
        if (value is double) return sum + value;

        return sum +
            (double.tryParse(value.toString()) ?? 0);
      },
    );

    return total / history.length;
  }

  Color get mainColor {
    if (criticalCount > 0) {
      return const Color(0xFFDC2626);
    }

    if (moderateCount > 0) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF22C55E);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              150,
            ),
            children: [
              const AppHeader(),

              const SizedBox(height: 20),

              buildTitle(),

              const SizedBox(height: 20),

              buildHeroCard(),

              const SizedBox(height: 20),

              buildStatsGrid(),

              const SizedBox(height: 20),

              buildRiskSummary(),

              const SizedBox(height: 18),

              buildClinicalInsightCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: AppTextStyles.pageTitle,
        ),

        SizedBox(height: 4),

        Text(
          'Vue synthétique des évaluations',
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }

  Widget buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mainColor,
            mainColor.withOpacity(0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Vue analytique',
                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(0.82),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$totalEvaluations évaluation(s)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
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
      physics:
          const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.22,
      children: [
        statCard(
          title: 'Total',
          value: '$totalEvaluations',
          icon: Icons.assignment_rounded,
          color: const Color(0xFF2563EB),
        ),

        statCard(
          title: 'Score moyen',
          value:
              averageScore.toStringAsFixed(1),
          icon: Icons.speed_rounded,
          color: const Color(0xFF7C3AED),
        ),

        statCard(
          title: 'Risques élevés',
          value: '$criticalCount',
          icon: Icons.warning_rounded,
          color: const Color(0xFFDC2626),
        ),

        statCard(
          title: 'Risques modérés',
          value: '$moderateCount',
          icon: Icons.info_rounded,
          color: const Color(0xFFF59E0B),
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
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRiskSummary() {
    return Container(
      padding: const EdgeInsets.all(22),
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
      child: history.isEmpty
          ? const Text(
              'Aucune donnée disponible. Enregistrez une évaluation pour alimenter le dashboard.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            )
          : Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFEAF2FF),
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color:
                            Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Text(
                      'Synthèse clinique',
                      style:
                          AppTextStyles.sectionTitle,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                summaryRow(
                  'Évaluations totales',
                  '$totalEvaluations',
                ),

                summaryRow(
                  'Risques élevés ou critiques',
                  '$criticalCount',
                ),

                summaryRow(
                  'Risques modérés',
                  '$moderateCount',
                ),

                summaryRow(
                  'Score moyen',
                  averageScore
                      .toStringAsFixed(1),
                ),
              ],
            ),
    );
  }

  Widget summaryRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClinicalInsightCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Analyse clinique',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Le dashboard permet une visualisation rapide des tendances de risque et facilite le repérage clinique.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                    fontWeight:
                        FontWeight.w500,
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