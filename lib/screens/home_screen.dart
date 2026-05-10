import 'package:flutter/material.dart';

import '../data/clinical_flags_data.dart';
import '../services/clinical_ai_service.dart';
import '../services/csv_service.dart';
import '../services/history_service.dart';
import '../services/pdf_service.dart';
import '../widgets/decision_card.dart';
import '../services/decision_engine_service.dart';
import '../widgets/category_card.dart';
import '../widgets/header_card.dart';
import '../widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController patientCodeController = TextEditingController();

  bool rgpdConsent = false;
  String searchQuery = '';
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
    final items = categories[selectedCategory] ?? [];

    if (searchQuery.trim().isEmpty) return items;

    final query = searchQuery.toLowerCase();

    return items.where((item) {
      final title = item['title'].toString().toLowerCase();
      final severity = item['severity'].toString().toLowerCase();
      return title.contains(query) || severity.contains(query);
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get selectedCategoryMap {
    return {selectedCategory: selectedItems};
  }

  int get checkedCount {
    return (categories[selectedCategory] ?? [])
        .where((item) => item['checked'] == true)
        .length;
  }

  int get score {
    int total = 0;

    for (final item in categories[selectedCategory] ?? []) {
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
      const SnackBar(content: Text('Evaluation enregistree')),
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
        const SnackBar(content: Text('Veuillez valider l information RGPD')),
      );
      return;
    }

    action();
  }

  void resetSession() {
    setState(() {
      patientCodeController.clear();
      rgpdConsent = false;
      searchQuery = '';

      for (final category in categories.values) {
        for (final item in category) {
          item['checked'] = false;
        }
      }
    });
  }

  IconData iconForCategory(String category) {
    final value = category.toLowerCase();

    if (value.contains('lombalgie')) return Icons.accessibility_new_rounded;
    if (value.contains('cheville')) return Icons.directions_walk_rounded;
    if (value.contains('respiratoire')) return Icons.air_rounded;
    if (value.contains('orthop')) return Icons.healing_rounded;
    if (value.contains('cervical')) return Icons.self_improvement_rounded;
    if (value.contains('cardiaque')) return Icons.favorite_rounded;
    if (value.contains('tvp') || value.contains('vasculaire')) {
      return Icons.bloodtype_rounded;
    }
    if (value.contains('post')) return Icons.local_hospital_rounded;

    return Icons.medical_information_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 1200 : 700,
          ),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const HeaderCard(),
              const SizedBox(height: 18),
              buildPathologyCards(isTablet),
              const SizedBox(height: 18),
              buildTopSection(isTablet),
              const SizedBox(height: 20),
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
              buildSelectedCategoryCard(),
              const SizedBox(height: 22),
              buildActionButtons(),
              const SizedBox(height: 30),
              const Text(
                'RGPD : ne jamais saisir de donnees nominatives.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPathologyCards(bool isTablet) {
    final entries = categories.keys.toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Motif principal',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choisis la situation clinique pour afficher uniquement les drapeaux rouges utiles.',
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isTablet ? 1.75 : 1.45,
            ),
            itemBuilder: (context, index) {
              final category = entries[index];
              final isSelected = category == selectedCategory;

              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                    searchQuery = '';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                      width: 1.4,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        iconForCategory(category),
                        color: isSelected ? Colors.white : const Color(0xFF2563EB),
                        size: 30,
                      ),
                      const Spacer(),
                      Text(
                        category,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildTopSection(bool isTablet) {
    final content = [
      Expanded(
        child: TextField(
          controller: patientCodeController,
          decoration: const InputDecoration(
            labelText: 'Code patient pseudonymise',
            hintText: 'Ex : P-042',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Recherche dans ce motif',
            hintText: 'douleur, neuro, fracture...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          isTablet
              ? Row(children: content)
              : Column(
                  children: [
                    content[0],
                    const SizedBox(height: 14),
                    content[2],
                  ],
                ),
          const SizedBox(height: 14),
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
              'Ne pas saisir de donnees directement identifiantes.',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectedCategoryCard() {
    return CategoryCard(
      category: selectedCategory,
      items: selectedItems,
      onChanged: (item, value) {
        setState(() {
          item['checked'] = value;
        });
      },
    );
  }

  Widget buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => requireRgpd(saveEvaluation),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
        OutlinedButton.icon(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Text(
                'Synthese locale assistee',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aiSummary,
            style: const TextStyle(
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}