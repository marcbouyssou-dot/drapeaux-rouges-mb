import 'package:flutter/material.dart';

import '../data/clinical_flags_data.dart';
import '../services/clinical_ai_service.dart';
import '../services/csv_service.dart';
import '../services/history_service.dart';
import '../services/pdf_service.dart';
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
    return {
      selectedCategory: selectedItems,
    };
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
      rgpdConsent = false;
      searchQuery = '';

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
              buildPathologySelector(),
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

  Widget buildPathologySelector() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Motif / pathologie initiale',
          prefixIcon: Icon(Icons.medical_information_outlined),
        ),
        items: categories.keys.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            selectedCategory = value;
            searchQuery = '';
          });
        },
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