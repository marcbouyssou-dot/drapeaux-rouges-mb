import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/clinical_flags_data.dart';
import '../models/access_direct_model.dart';
import '../models/evaluation_model.dart';
import '../models/patient_local.dart';
import '../services/access_direct_local_service.dart';
import '../services/clinical_ai_service.dart';
import '../services/csv_service.dart';
import '../services/decision_engine_service.dart';
import '../services/history_service.dart';
import '../services/pdf_service.dart';
import '../services/rgpd_local_service.dart';
import '../services/risk_score_service.dart';

import '../widgets/clinical_category_picker.dart';

import 'evaluation/red_flags_category_screen.dart';
import 'evaluation/evaluation_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.openPickerOnStart = false,
  });

  final bool openPickerOnStart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = clinicalCategories.keys.first;
  List<Map<String, dynamic>> history = [];
  PatientLocal? currentPatient;
  AccessDirectModel accessDirect = AccessDirectModel.empty;

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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (widget.openPickerOnStart) {
      openCategoryPicker();
    }
  });
}
  void openResultScreen() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EvaluationResultScreen(
        score: score,
        checkedCount: checkedCount,
        riskLevel: riskLevel,
        riskColor: riskColor,
        selectedCategory: selectedCategory,
        categories: categories,
        patientDisplayName: patientDisplayName,
        aiSummary: aiSummary,
        checkedFlags: checkedFlags,
        decisionMessage: DecisionEngineService.decisionMessage(
          score: score,
          selectedCategory: selectedCategory,
          categories: categories,
        ),
        onReset: resetSession,
        onSave: saveEvaluation,
        onExportPdf: showPdfExportChoice,
      ),
    ),
  );
}
  Future<void> loadInitialData() async {
    final loadedHistory = await HistoryService.loadHistory();
    final patient = await RgpdLocalService.getCurrentPatient();
    final accessDirectSettings = await AccessDirectLocalService.loadSettings();

    if (!mounted) return;

    setState(() {
      history = loadedHistory;
      currentPatient = patient;
      accessDirect = accessDirectSettings;
    });
  }

  int get checkedCount =>
      RiskScoreService.computeGlobalCheckedCount(categories);

  int get score => RiskScoreService.computeGlobalScore(categories);

  String get riskLevel => RiskScoreService.riskLevelFromScore(score);

  Color get riskColor => RiskScoreService.riskColorFromScore(score);

  List<Map<String, dynamic>> get checkedFlags =>
      RiskScoreService.checkedFlagsFromCategories(categories);

  String get patientDisplayName =>
      RgpdLocalService.patientDisplayName(currentPatient);

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

  void openCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.96,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ClinicalCategoryPicker(
            categories: categories,
            selectedCategory: selectedCategory,
            checkedCount: checkedCountForCategory,
            onSelected: (category) async {
              setState(() {
                selectedCategory = category;
              });

              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 120));

              if (!mounted) return;
              await openCategory(category);
            },
          ),
        );
      },
    );
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

  if (checkedCount > 0) {
    await Future.delayed(
      const Duration(milliseconds: 180),
    );

    if (!mounted) return;

    openResultScreen();
  }
}
  }

  Future<bool> confirmAnonymousMode({required String action}) async {
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

  Future<void> saveEvaluation() async {
    final canContinue = await confirmAnonymousMode(
      action: 'enregistrer une évaluation',
    );

    if (!canContinue) return;


    

    const uuid = Uuid();
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

  void showPdfExportChoice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Exporter le PDF',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                buildPdfChoiceTile(
                  icon: Icons.palette_outlined,
                  title: 'PDF couleur',
                  subtitle: 'Lecture écran, risque plus visible',
                  onTap: () {
                    Navigator.pop(context);
                    exportPdf(printable: false);
                  },
                ),
                const SizedBox(height: 10),
                buildPdfChoiceTile(
                  icon: Icons.print_outlined,
                  title: 'PDF impression',
                  subtitle: 'Noir et blanc, moins d’encre',
                  onTap: () {
                    Navigator.pop(context);
                    exportPdf(printable: true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPdfChoiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> exportPdf({required bool printable}) async {
    final canContinue = await confirmAnonymousMode(action: 'exporter un PDF');

    if (!canContinue) return;

    await PdfService.exportPdf(
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
      printable: printable,
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
  if (widget.openPickerOnStart) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SizedBox.expand(),
    );
  }

  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFF),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: loadInitialData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 150),
          children: [
            buildModernEvaluationCard(),
            const SizedBox(height: 18),
            buildQuickStatusRow(),
            const SizedBox(height: 18),
            buildClinicalSafetyNote(),
          ],
        ),
      ),
    ),
    bottomNavigationBar: buildStickyActionBar(),
  );
}
Widget buildModernEvaluationCard() {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: openCategoryPicker,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 34),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F7),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFFBCFE8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDB2777).withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF472B6),
                    Color(0xFFDB2777),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDB2777).withValues(alpha: 0.24),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 66,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'DRAPEAUX',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFDB2777),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choisir une pathologie et cocher les signes d’alerte',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFBCFE8)),
              ),
              child: const Text(
                'Appuyer pour commencer',
                style: TextStyle(
                  color: Color(0xFFDB2777),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildQuickStatusRow() {
  return Row(
    children: [
      Expanded(
        child: buildSmallStatusCard(
          icon: Icons.person_rounded,
          label: 'Patient',
          value: currentPatient == null ? 'Non renseigné' : patientDisplayName,
          color: currentPatient == null
              ? const Color(0xFFF97316)
              : const Color(0xFF16A34A),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: buildSmallStatusCard(
          icon: Icons.monitor_heart_rounded,
          label: 'Score',
          value: '$score / $checkedCount item(s)',
          color: riskColor,
        ),
      ),
    ],
  );
}

Widget buildSmallStatusCard({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
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
            riskColor.withValues(alpha: 0.84),
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
                  color: Colors.white.withValues(alpha: 0.15),
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
                        color: Colors.white.withValues(alpha: 0.82),
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
                  icon: Icons.flag_rounded,
                  label: 'Total global',
                  value: '$checkedCount drapeau(x)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildSummaryChip(
                  icon: Icons.folder_special_rounded,
                  label: 'Pathologies',
                  value: '${categories.length} motifs',
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
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
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
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
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

  Widget buildRedFlagsAccessCard() {
    final bool hasFlags = checkedCount > 0;

    final Color cardColor =
        hasFlags ? riskColor : const Color(0xFFEC4899);

    final Color cardColorLight = hasFlags
        ? riskColor.withValues(alpha: 0.84)
        : const Color(0xFFF472B6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openCategoryPicker,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 34,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardColor,
                cardColorLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DRAPEAUX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choisir une pathologie et cocher les signes d’alerte',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
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
Widget buildPathologyButton() {
  return FilledButton.icon(
    onPressed: openCategoryPicker,
    icon: const Icon(Icons.flag_outlined),
    label: const Text('Choisir une pathologie'),
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(58),
      backgroundColor: const Color(0xFFDB2777),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
  Widget buildStickyActionBar() {
  return SafeArea(
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: resetSession,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réinitialiser'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: checkedCount == 0
    ? null
    : openResultScreen,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
  checkedCount == 0
      ? 'Aucun item'
      : 'Valider ($checkedCount)',
),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget buildCompactDecisionCard(String decisionTitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: riskColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.route_rounded,
              color: riskColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              decisionTitle,
              style: TextStyle(
                color: riskColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClinicalSafetyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aide au repérage clinique uniquement. Cette application ne remplace pas une évaluation médicale professionnelle.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
                
              ),
              
            ),
          ),
        ],
      ),
    );
  }
}