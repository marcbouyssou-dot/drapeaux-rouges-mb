import 'package:flutter/material.dart';

import '../data/clinical_flags_data.dart';
import '../services/clinical_ai_service.dart';
import '../services/csv_service.dart';
import '../services/decision_engine_service.dart';
import '../services/history_service.dart';
import '../services/pdf_service.dart';

import '../widgets/category_card.dart';
import '../widgets/decision_card.dart';
import '../widgets/header_card.dart';
import '../widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController patientCodeController =
      TextEditingController();

  bool rgpdConsent = false;

  String selectedCategory = clinicalCategories.keys.first;

  List<Map<String, dynamic>> history = [];

  final Map<String, List<Map<String, dynamic>>> categories =
      clinicalCategories.map(
    (key, value) => MapEntry(
      key,
      value.map((item) => Map<String, dynamic>.from(item)).toList(),
    ),
  );

  final Map<String, IconData> categoryIcons = {
    'Lombalgie': Icons.accessibility_new_rounded,
    'Entorse de cheville': Icons.directions_walk_rounded,
    'Respiratoire adulte': Icons.air_rounded,
    'Orthopédie générale': Icons.healing_rounded,
    'Cervicalgie': Icons.psychology_alt_rounded,
    'Cardiaque': Icons.favorite_rounded,
    'TVP / Vasculaire': Icons.monitor_heart_rounded,
    'Post-opératoire': Icons.local_hospital_rounded,
  };

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
    return selectedItems
        .where((item) => item['checked'] == true)
        .length;
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
    if (score >= 4) return 'Risque eleve';
    if (score >= 2) return 'Risque modere';
    return 'Risque faible';
  }

  Color get riskColor {
    if (score >= 6) return const Color(0xFF7F1D1D);
    if (score >= 4) return Colors.red;
    if (score >= 2) return Colors.orange;
    return Colors.green;
  }

  String get patientCode {
    final value = patientCodeController.text.trim();
    return value.isEmpty ? 'Non renseigne' : value;
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
        content: Text('Evaluation enregistree'),
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

  void requireRgpd(VoidCallback action) {
    if (!rgpdConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez valider l information RGPD'),
        ),
      );
      return;
    }

    action();
  }

  void resetSession() {
    setState(() {
      patientCodeController.clear();

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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 1200 : 700,
            ),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const HeaderCard(),

                const SizedBox(height: 24),

                buildClinicalSelector(),

                const SizedBox(height: 22),

                buildQuickInfos(),

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

                buildAiSummaryCard(),

                const SizedBox(height: 22),

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
        const Text(
          'Motif principal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.keys.map((category) {
              final selected = category == selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 165,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF0A84FF),
                              Color(0xFF2563EB),
                            ],
                          )
                        : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? const Color(0xFF0A84FF).withOpacity(0.22)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        categoryIcons[category],
                        size: 38,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildQuickInfos() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          TextField(
            controller: patientCodeController,
            decoration: const InputDecoration(
              labelText: 'Code patient pseudonymise',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),

          const SizedBox(height: 16),

          CheckboxListTile(
            value: rgpdConsent,
            onChanged: (value) {
              setState(() {
                rgpdConsent = value ?? false;
              });
            },
            title: const Text(
              'Information RGPD comprise',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Ne jamais saisir de donnees nominatives.',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => requireRgpd(saveEvaluation),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),

        FilledButton.icon(
          onPressed: () => requireRgpd(exportPdf),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('PDF'),
        ),

        OutlinedButton.icon(
          onPressed: () => requireRgpd(exportCsv),
          icon: const Icon(Icons.table_chart_outlined),
          label: const Text('CSV'),
        ),

        OutlinedButton.icon(
          onPressed: resetSession,
          icon: const Icon(Icons.refresh),
          label: const Text('Réinitialiser'),
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
                'Synthese clinique',
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