import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/clinical_flags_data.dart';
import '../models/evaluation_model.dart';
import '../models/patient_local.dart';
import '../services/clinical_ai_service.dart';
import '../services/csv_service.dart';
import '../services/decision_engine_service.dart';
import '../services/history_service.dart';
import '../services/pdf_service.dart';
import '../services/rgpd_local_service.dart';
import '../services/risk_score_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';
import '../widgets/decision_card.dart';
import 'evaluation/red_flags_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = clinicalCategories.keys.first;
  List<Map<String, dynamic>> history = [];
  PatientLocal? currentPatient;

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
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final loadedHistory = await HistoryService.loadHistory();
    final patient = await RgpdLocalService.getCurrentPatient();

    if (!mounted) return;

    setState(() {
      history = loadedHistory;
      currentPatient = patient;
    });
  }

  List<Map<String, dynamic>> get selectedItems {
    return categories[selectedCategory] ?? [];
  }

  int get checkedCount {
    return RiskScoreService.computeGlobalCheckedCount(categories);
  }

  int get score {
    return RiskScoreService.computeGlobalScore(categories);
  }

  String get riskLevel {
    return RiskScoreService.riskLevelFromScore(score);
  }

  Color get riskColor {
    return RiskScoreService.riskColorFromScore(score);
  }

  List<Map<String, dynamic>> get checkedFlags {
    return RiskScoreService.checkedFlagsFromCategories(categories);
  }

  int get selectedCategoryCheckedCount {
    return RiskScoreService.computeCheckedCount(selectedItems);
  }

  int get selectedCategoryScore {
    return RiskScoreService.computeScore(selectedItems);
  }

  String get patientDisplayName {
    return RgpdLocalService.patientDisplayName(currentPatient);
  }

  String get aiSummary {
    return ClinicalAiService.generateClinicalSummary(
      categories: categories,
      score: score,
      checkedCount: checkedCount,
    );
  }

  String itemTitle(Map<String, dynamic> item) {
    return item['title']?.toString() ??
        item['label']?.toString() ??
        item['question']?.toString() ??
        item['text']?.toString() ??
        item['name']?.toString() ??
        'Item sans titre';
  }

  int checkedCountForCategory(String category) {
    final items = categories[category] ?? [];
    return RiskScoreService.computeCheckedCount(items);
  }

  Future<bool> confirmAnonymousMode({
    required String action,
  }) async {
    if (currentPatient != null) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Aucun patient actif'),
          content: Text(
            'Vous êtes sur le point de $action sans patient sélectionné.\n\n'
            'L’évaluation sera associée à “Patient non renseigné”. '
            'Ce mode peut être utile en situation rapide, mais il sera moins facile de retrouver le bilan ensuite.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> openCategory(String category) async {
    setState(() {
      selectedCategory = category;
    });

    final items = categories[category] ?? [];
    final itemLabels = items.map(itemTitle).toList();

    final initiallySelected = items
        .where((item) => item['checked'] == true)
        .map(itemTitle)
        .toSet();

    final result = await Navigator.push<Set<String>>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return RedFlagsCategoryScreen(
            title: category,
            items: itemLabels,
            initiallySelected: initiallySelected,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        for (final item in items) {
          item['checked'] = result.contains(itemTitle(item));
        }
      });
    }
  }

  Future<void> saveEvaluation() async {
    final canContinue = await confirmAnonymousMode(
      action: 'enregistrer une évaluation',
    );

    if (!canContinue) return;

    final decisionTitle = DecisionEngineService.decisionTitle(
      score: score,
      selectedCategory: selectedCategory,
      categories: categories,
    );

    final decisionMessage = DecisionEngineService.decisionMessage(
      score: score,
      selectedCategory: selectedCategory,
      categories: categories,
    );

    const uuid = Uuid();

    final evaluation = EvaluationModel(
      evaluationId: uuid.v4(),
      patientLocalId: currentPatient?.localId,
      patientAnonymousId: currentPatient?.anonymousId,
      patientDisplayName: patientDisplayName,
      date: DateTime.now(),
      motif: selectedCategory,
      score: score,
      riskLevel: riskLevel,
      checkedCount: checkedCount,
      checkedFlags: checkedFlags,
      decisionTitle: decisionTitle,
      decisionMessage: decisionMessage,
      aiSummary: aiSummary,
    );

    await HistoryService.saveEvaluation(
      history: history,
      evaluation: evaluation.toJson(),
    );

    await loadInitialData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Évaluation enregistrée')),
    );
  }

  Future<void> exportPdf() async {
    final canContinue = await confirmAnonymousMode(
      action: 'exporter un PDF',
    );

    if (!canContinue) return;

    PdfService.exportPdf(
      categories: categories,
      score: score,
      checkedCount: checkedCount,
      riskLevel: riskLevel,
      patientCode: patientDisplayName,
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

  Future<void> exportCsv() async {
    await CsvService.exportCsv(
      categories: categories,
      score: score,
      riskLevel: riskLevel,
      patientCode: currentPatient?.anonymousId ?? 'Patient non renseigné',
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
    final decisionTitle = DecisionEngineService.decisionTitle(
      score: score,
      selectedCategory: selectedCategory,
      categories: categories,
    );

    final decisionMessage = DecisionEngineService.decisionMessage(
      score: score,
      selectedCategory: selectedCategory,
      categories: categories,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadInitialData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
            children: [
              const AppHeader(compact: true),
              const SizedBox(height: 14),
              buildTitleBlock(),
              const SizedBox(height: 16),
              buildClinicalSummaryCard(),
              const SizedBox(height: 18),
              DecisionCard(
                title: decisionTitle,
                message: decisionMessage,
                color: riskColor,
              ),
              const SizedBox(height: 20),
              buildSectionHeader(),
              const SizedBox(height: 12),
              buildCategoryGrid(),
              const SizedBox(height: 20),
              buildCurrentCategorySummary(),
              const SizedBox(height: 20),
              buildSecondaryButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildStickyActionBar(),
    );
  }

  Widget buildTitleBlock() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Évaluation', style: AppTextStyles.pageTitle),
              SizedBox(height: 4),
              Text(
                'Repérage rapide des drapeaux rouges',
                style: AppTextStyles.pageSubtitle,
              ),
            ],
          ),
        ),
        buildPatientBadge(),
      ],
    );
  }

  Widget buildPatientBadge() {
    final hasPatient = currentPatient != null;

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: hasPatient ? const Color(0xFFEFFAF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasPatient ? const Color(0xFFD5F3E1) : const Color(0xFFFED7AA),
        ),
      ),
      child: Text(
        hasPatient ? patientDisplayName : 'Aucun patient',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasPatient ? const Color(0xFF166534) : const Color(0xFFC2410C),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildClinicalSummaryCard() {
    final hasPatient = currentPatient != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor,
            riskColor.withOpacity(0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riskLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                        letterSpacing: -0.8,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasPatient
                          ? patientDisplayName
                          : 'Aucun patient actif sélectionné',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              buildMiniStat('Score', '$score'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildSummaryChip(
                  icon: Icons.assignment_rounded,
                  label: 'Motif actif',
                  value: selectedCategory,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildSummaryChip(
                  icon: Icons.flag_rounded,
                  label: 'Total global',
                  value: '$checkedCount drapeau(x)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMiniStat(String label, String value) {
    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Motif principal',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Text(
          'Touchez une carte',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget buildCategoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.keys.map((category) {
            final selected = category == selectedCategory;
            final count = checkedCountForCategory(category);

            return GestureDetector(
              onTap: () => openCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: itemWidth,
                height: 104,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      categoryIcon(category),
                      color: selected ? Colors.white : const Color(0xFF2563EB),
                      size: 25,
                    ),
                    const Spacer(),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count == 0 ? 'Aucun item coché' : '$count item(s)',
                      style: TextStyle(
                        color: selected
                            ? Colors.white.withOpacity(0.85)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  IconData categoryIcon(String category) {
    final lower = category.toLowerCase();

    if (lower.contains('lomb')) return Icons.accessibility_new_rounded;
    if (lower.contains('entorse')) return Icons.directions_walk_rounded;
    if (lower.contains('resp')) return Icons.air_rounded;
    if (lower.contains('ortho')) return Icons.medical_services_outlined;
    if (lower.contains('cerv')) return Icons.psychology_alt_outlined;
    if (lower.contains('card')) return Icons.favorite_border_rounded;
    if (lower.contains('tvp') || lower.contains('vasc')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('post')) return Icons.healing_rounded;

    return Icons.monitor_heart_outlined;
  }

  Widget buildCurrentCategorySummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.checklist_rounded,
            color: Color(0xFF2563EB),
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              selectedCategoryCheckedCount == 0
                  ? 'Touchez le motif sélectionné pour cocher les drapeaux rouges.'
                  : '$selectedCategoryCheckedCount drapeau(x) rouge(s) coché(s) pour ce motif. Score motif : $selectedCategoryScore.',
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSecondaryButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: exportCsv,
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('CSV'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: resetSession,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réinitialiser'),
          ),
        ),
      ],
    );
  }

  Widget buildStickyActionBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: saveEvaluation,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: exportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}