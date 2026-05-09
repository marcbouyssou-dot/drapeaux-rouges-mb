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
    await HistoryService.clearHistory();

    setState(() {
      history.clear();
    });
  }

  Color riskColor(String risk) {
    if (risk.contains('critique')) return const Color(0xFF7F1D1D);
    if (risk.contains('eleve')) return Colors.red;
    if (risk.contains('modere')) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text('Historique'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: history.isEmpty ? null : clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text('Aucune evaluation enregistree'),
            )
          : RefreshIndicator(
              onRefresh: loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final risk = item['risk'] ?? 'Risque inconnu';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: riskColor(risk).withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 70,
                          decoration: BoxDecoration(
                            color: riskColor(risk),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                risk,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: riskColor(risk),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Patient : ${item['patientCode'] ?? 'Non renseigne'}'),
                              Text('Score : ${item['score']}'),
                              Text('Drapeaux : ${item['checkedCount']}'),
                              const SizedBox(height: 6),
                              Text(
                                item['date'].toString().replaceAll('T', ' ').substring(0, 16),
                                style: const TextStyle(color: Colors.grey),
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
    );
  }
}