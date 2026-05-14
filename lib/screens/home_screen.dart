import 'package:flutter/material.dart';

import '../data/clinical_flags_data.dart';
import '../services/clinical_ai_service.dart';
import '../services/csv_service.dart';
import '../services/decision_engine_service.dart';
import '../services/history_service.dart';
import '../services/patient_session_service.dart';
import '../services/pdf_service.dart';

import '../widgets/category_card.dart';
import '../widgets/decision_card.dart';
import '../widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = clinicalCategories.keys.first;

  List<Map<String, dynamic>> history = [];

  final Map<String, List<Map<String, dynamic>>> categories =
      clinicalCategories.map(
    (key, value) => MapEntry(
      key,
      value.map((item) => Map<String, dynamic>.from(item)).toList(),
    ),
  );

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  List<Map<String, dynamic>> get selectedItems {
    return categories[selectedCategory] ?? [];
  }

  Map<String, List<Map<String, dynamic>>> get selectedCategoryMap {
    return {
      selectedCategory: selectedItems,
    };
  }

  int get checkedCount {
    return selectedItems.where((item) => item['checked'] == true).length;
  }

  int get score {
    int total = 0;

    for (final item in selectedItems) {
      if (item['checked'] == true) {
        final severity = item['severity'].toString();

        if (severity == 'Critique') {
          total += 3;
        } else if (severity == 'Élevé') {
          total += 2;
        } else {
          total += 1;
        }
      }
    }

    return total;
  }

  String get riskLevel {
    if (score >= 6) return 'Risque critique';
    if (score >= 4) return 'Risque élevé';
    if (score >= 2) return 'Risque modéré';
    return 'Risque faible';
  }

  Color get riskColor {
    if (score >= 6) return const Color(0xFF7F1D1D);
    if (score >= 4) return Colors.red;
    if (score >= 2) return Colors.orange;
    return Colors.green;
  }

  String get patientCode {
    return PatientSessionService.patientCode;
  }

  String get aiSummary {
    return ClinicalAiService.generateClinicalSummary(
      categories: selectedCategoryMap,
      score: score,
      checkedCount: checkedCount,
    );
  }

  Future<void> loadHistory() async {
    final loadedHistory = await HistoryService.loadHistory();

    setState(() {
      history = loadedHistory;
    });
  }

  Future<void> saveEvaluation() async {
    final evaluation = {
      'date': DateTime.now().toIso8601String(),
      'patientCode': patientCode,
      'motif': selectedCategory,
      'score': score,
      'risk': riskLevel,
      'checkedCount': checkedCount,
    };

    await HistoryService.saveEvaluation(
      history: history,
      evaluation: evaluation,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Évaluation enregistrée'),
      ),
    );
  }

  void exportPdf() {
    PdfService.exportPdf(
      categories: selectedCategoryMap,
      score: score,
      checkedCount: checkedCount,
      riskLevel: riskLevel,
      patientCode: patientCode,
      motif: selectedCategory,
      decisionTitle: DecisionEngineService.decisionTitle(
        score: score,
        selectedCategory: selectedCategory,
        categories: categories,
      ),
      decisionMessage: DecisionEngineService.decisionMessage(
        score: score,
        selectedCategory: selectedCategory,
        categories: categories,
      ),
      aiSummary: aiSummary,
    );
  }

  void exportCsv() {
    CsvService.exportCsv(
      categories: selectedCategoryMap,
      score: score,
      riskLevel: riskLevel,
      patientCode: patientCode,
    );
  }

  void resetSession() {
    setState(() {
      for (final category in categories.values) {
        for (final item in category) {
          item['checked'] = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 860 : 520,
            ),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                buildClinicalSelector(),
                const SizedBox(height: 22),
                ResultCard(
                  riskLevel: riskLevel,
                  riskColor: riskColor,
                  score: score,
                  checkedCount: checkedCount,
                ),
                const SizedBox(height: 18),
                DecisionCard(
                  title: DecisionEngineService.decisionTitle(
                    score: score,
                    selectedCategory: selectedCategory,
                    categories: categories,
                  ),
                  message: DecisionEngineService.decisionMessage(
                    score: score,
                    selectedCategory: selectedCategory,
                    categories: categories,
                  ),
                  color: riskColor,
                ),
                const SizedBox(height: 18),


                CategoryCard(
                  category: selectedCategory,
                  items: selectedItems,
                  onChanged: (item, value) {
                    setState(() {
                      item['checked'] = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                buildBottomButtons(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildClinicalSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Évaluation',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF071936),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choisissez le motif principal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFAF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD5F3E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 6,
                  backgroundColor: Color(0xFF12B76A),
                ),
                const SizedBox(width: 8),
                Text(
                  patientCode == 'Non renseigné'
                      ? 'Aucun patient'
                      : 'Patient actif\n$patientCode',
                  style: const TextStyle(
                    color: Color(0xFF071936),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      buildCategoryGrid(),
    ],
  );
}

  Widget buildCategoryGrid() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double totalWidth = constraints.maxWidth;

      final double itemWidth =
          (totalWidth - 10) / 2;

      return Wrap(
        spacing: 10,
        runSpacing: 10,

        children: categories.keys.map((category) {
          final selected =
              category == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },

            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),

              width: itemWidth,
              height: 54,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF007AFF)
                    : Colors.white,

                borderRadius:
                    BorderRadius.circular(18),

                border: Border.all(
                  color: selected
                      ? const Color(0xFF007AFF)
                      : const Color(0xFFE5E7EB),
                ),

                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? const Color(0xFF007AFF)
                            .withOpacity(0.12)
                        : Colors.black
                            .withOpacity(0.03),

                    blurRadius:
                        selected ? 12 : 6,

                    offset:
                        const Offset(0, 3),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Icon(
                    Icons
                        .health_and_safety_outlined,

                    size: 18,

                    color: selected
                        ? Colors.white
                        : const Color(0xFF007AFF),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      category,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(
                                0xFF071936),

                        fontWeight:
                            FontWeight.w800,

                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}

  Widget buildBottomButtons() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: saveEvaluation,

              icon: const Icon(
                Icons.save_outlined,
              ),

              label: const Text(
                'Enregistrer',
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: FilledButton.icon(
              onPressed: exportPdf,

              icon: const Icon(
                Icons.picture_as_pdf_outlined,
              ),

              label: const Text(
                'PDF',
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: exportCsv,

              icon: const Icon(
                Icons.table_chart_outlined,
              ),

              label: const Text(
                'CSV',
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: OutlinedButton.icon(
              onPressed: resetSession,

              icon: const Icon(
                Icons.refresh,
              ),

              label: const Text(
                'Réinitialiser',
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget buildAiSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Color(0xFF0A84FF),
              ),
              SizedBox(width: 10),
              Text(
                'Synthèse clinique',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            aiSummary,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}