
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../data/clinical_flags_data.dart';
import '../services/pdf_service.dart';
import '../services/csv_service.dart';
import '../services/history_service.dart';
import '../widgets/header_card.dart';
import '../widgets/result_card.dart';
import '../widgets/category_card.dart';
import '../widgets/action_buttons.dart';

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
        if (item['checked'] == true) total++;
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
    const SnackBar(content: Text('Evaluation enregistree')),
  );
}
Future<void> clearHistory() async {
  await HistoryService.clearHistory();

  setState(() {
    history.clear();
  });
}

  void resetSession() {
    setState(() {
      patientCodeController.clear();
      rgpdConsent = false;
      for (final category in categories.values) {
        for (final item in category) {
          item['checked'] = false;
        }
      }
    });
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

  Future<void> exportPdf() async {
  await PdfService.exportPdf(
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

  void showHistory() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: history.isEmpty
              ? const Center(child: Text('Aucun historique enregistre'))
              : Column(
                  children: [
                    const Text(
                      'Historique des evaluations',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: history.map((item) {
                          return Card(
                            child: ListTile(
                              title: Text(item['risk']),
                              subtitle: Text(
                                'Patient : ${item['patientCode']} | Score : ${item['score']} | Drapeaux : ${item['checkedCount']}',
                              ),
                              trailing: Text(item['date'].toString().substring(0, 10)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        clearHistory();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer historique'),
                    ),
                  ],
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(title: const Text('Drapeaux rouges MB'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HeaderCard(),
          const SizedBox(height: 20),
          buildPatientField(),
          const SizedBox(height: 14),
          buildRgpdBox(),
          const SizedBox(height: 20),
          TextField(
  onChanged: (value) {
    setState(() {
      searchQuery = value;
    });
  },
  decoration: const InputDecoration(
    labelText: 'Rechercher un drapeau rouge',
    hintText: 'Ex : douleur, fievre, neuro...',
    prefixIcon: Icon(Icons.search),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
    ),
  ),
),

const SizedBox(height: 20),
          ResultCard(
  riskLevel: riskLevel,
  riskColor: riskColor,
  score: score,
  checkedCount: checkedCount,
),
          const SizedBox(height: 20),
          ...filteredCategories.entries.map(
  (entry) => CategoryCard(
    category: entry.key,
    items: entry.value,
    onChanged: (item, value) {
      setState(() {
        item['checked'] = value;
      });
    },
  ),
),
          const SizedBox(height: 20),
          ActionButtons(
  onSave: () => requireRgpd(saveEvaluation),
  onHistory: showHistory,
  onPdf: () => requireRgpd(exportPdf),
  onCsv: () => requireRgpd(exportCsv),
  onReset: resetSession,
),
          const SizedBox(height: 24),
          const Text(
            'RGPD : ne jamais saisir de donnees nominatives. Utiliser uniquement un code pseudonymise.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }


  Widget buildPatientField() {
    return TextField(
      controller: patientCodeController,
      decoration: const InputDecoration(
        labelText: 'Code patient pseudonymise',
        hintText: 'Ex : P-042',
        prefixIcon: Icon(Icons.badge_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
    );
  }

  Widget buildRgpdBox() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: CheckboxListTile(
        value: rgpdConsent,
        onChanged: (value) => setState(() => rgpdConsent = value ?? false),
        title: const Text('Information RGPD comprise'),
        subtitle: const Text(
          'Ne pas saisir de nom, prenom, date de naissance ou donnee directement identifiante.',
        ),
      ),
    );
  }
}