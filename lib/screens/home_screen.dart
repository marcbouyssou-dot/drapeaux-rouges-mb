import 'package:flutter/material.dart';

import '../data/clinical_flags_data.dart';
import '../services/csv_service.dart';
import '../services/history_service.dart';
import '../services/pdf_service.dart';
import '../widgets/action_buttons.dart';
import '../widgets/category_card.dart';
import '../widgets/header_card.dart';
import '../widgets/result_card.dart';
import '../services/clinical_ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController patientCodeController = TextEditingController();

  bool rgpdConsent = false;
  String searchQuery = '';
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

  int get checkedCount {
    int total = 0;

    for (final category in categories.values) {
      for (final item in category) {
        if (item['checked'] == true) {
          total++;
        }
      }
    }

    return total;
  }

  int get score {
    int total = 0;

    for (final category in categories.values) {
      for (final item in category) {
        if (item['checked'] == true) {
          total += item['severity'] == 'Critique' ? 3 : 1;
        }
      }
    }

    return total;
  }

  String get riskLevel {
    if (score >= 9) return 'Risque critique';
    if (score >= 6) return 'Risque eleve';
    if (score >= 3) return 'Risque modere';
    return 'Risque faible';
  }

  Color get riskColor {
    if (score >= 9) return const Color(0xFF7F1D1D);
    if (score >= 6) return Colors.red;
    if (score >= 3) return Colors.orange;
    return Colors.green;
  }
String get aiSummary {
  return ClinicalAiService.generateClinicalSummary(
    categories: categories,
    score: score,
    checkedCount: checkedCount,
  );
}
  String get patientCode {
    final value = patientCodeController.text.trim();

    return value.isEmpty ? 'Non renseigne' : value;
  }

  Map<String, List<Map<String, dynamic>>> get filteredCategories {
    if (searchQuery.trim().isEmpty) {
      return categories;
    }

    final query = searchQuery.toLowerCase();

    final Map<String, List<Map<String, dynamic>>> filtered = {};

    for (final entry in categories.entries) {
      final items = entry.value.where((item) {
        final title = item['title'].toString().toLowerCase();
        final severity = item['severity'].toString().toLowerCase();
        final category = entry.key.toLowerCase();

        return title.contains(query) ||
            severity.contains(query) ||
            category.contains(query);
      }).toList();

      if (items.isNotEmpty) {
        filtered[entry.key] = items;
      }
    }

    return filtered;
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
      'score': score,
      'risk': riskLevel,
      'checkedCount': checkedCount,
    };

    await HistoryService.saveEvaluation(
      history: history,
      evaluation: evaluation,
    );

    setState(() {});

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evaluation enregistree'),
      ),
    );
  }

  void exportPdf() {
    PdfService.exportPdf(
      categories: categories,
      score: score,
      checkedCount: checkedCount,
      riskLevel: riskLevel,
      patientCode: patientCode,
    );
  }

  void exportCsv() {
    CsvService.exportCsv(
      categories: categories,
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
      rgpdConsent = false;
      searchQuery = '';

      for (final category in categories.values) {
        for (final item in category) {
          item['checked'] = false;
        }
      }
    });
  }

  void showHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Utilise l onglet Historique en bas de l ecran',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isTablet = screenWidth > 900;

    return Scaffold(
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

              buildTopSection(isTablet),

              const SizedBox(height: 20),

              ResultCard(
                riskLevel: riskLevel,
                riskColor: riskColor,
                score: score,
                checkedCount: checkedCount,
              ),
              const SizedBox(height: 18),

              buildAiSummaryCard(),
              const SizedBox(height: 22),

              buildCategoriesGrid(isTablet),

              const SizedBox(height: 22),

              ActionButtons(
                onSave: () => requireRgpd(saveEvaluation),
                onHistory: showHistory,
                onPdf: () => requireRgpd(exportPdf),
                onCsv: () => requireRgpd(exportCsv),
                onReset: resetSession,
              ),

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
            labelText: 'Recherche',
            hintText: 'douleur, neuro...',
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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

  Widget buildCategoriesGrid(bool isTablet) {
    final entries = filteredCategories.entries.toList();

    if (!isTablet) {
      return Column(
        children: entries.map((entry) {
          return CategoryCard(
            category: entry.key,
            items: entry.value,
            onChanged: (item, value) {
              setState(() {
                item['checked'] = value;
              });
            },
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: entries.map((entry) {
        return SizedBox(
          width: 560,
          child: CategoryCard(
            category: entry.key,
            items: entry.value,
            onChanged: (item, value) {
              setState(() {
                item['checked'] = value;
              });
            },
          ),
        );
      }).toList(),
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