import 'package:flutter/material.dart';

import '../services/history_service.dart';

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
      history = loadedHistory;
    });
  }

  Future<void> clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer l’historique'),
          content: const Text(
            'Voulez-vous vraiment supprimer tout l’historique local ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
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
    if (risk.contains('critique')) {
      return const Color(0xFFB91C1C);
    }

    if (risk.contains('élevé')) {
      return const Color(0xFFEF4444);
    }

    if (risk.contains('modéré')) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune évaluation enregistrée',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];

                          final risk =
                              item['risk'] ?? 'Risque inconnu';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    riskColor(risk).withOpacity(0.18),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 12,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: riskColor(risk),
                                    borderRadius:
                                        BorderRadius.circular(99),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        risk,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight:
                                              FontWeight.w900,
                                          color: riskColor(risk),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      _buildInfoRow(
                                        Icons.badge_outlined,
                                        'Patient',
                                        item['patientCode'] ??
                                            'Non renseigné',
                                      ),

                                      _buildInfoRow(
                                        Icons.category_outlined,
                                        'Motif',
                                        item['motif'] ?? '',
                                      ),

                                      _buildInfoRow(
                                        Icons.analytics_outlined,
                                        'Score',
                                        '${item['score']}',
                                      ),

                                      _buildInfoRow(
                                        Icons.warning_amber_rounded,
                                        'Drapeaux',
                                        '${item['checkedCount']}',
                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        item['date']
                                            .toString()
                                            .replaceAll('T', ' ')
                                            .substring(0, 16),
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historique',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Évaluations locales enregistrées',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          FilledButton.icon(
  style: FilledButton.styleFrom(
    backgroundColor: const Color(0xFFFFE8E8),
    foregroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  onPressed: clearHistory,
  icon: const Icon(Icons.delete_outline_rounded),
  label: const Text("Supprimer l’historique"),
),
          
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Text(
            '$label : ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}