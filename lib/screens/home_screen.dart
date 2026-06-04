import 'package:flutter/cupertino.dart';
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
import '../widgets/home/home_hero_section.dart';
import '../widgets/home/home_quick_actions.dart';
import '../widgets/home/home_risk_legend.dart';
import '../widgets/home/home_score_card.dart';

import 'evaluation/red_flags_category_screen.dart';
import 'evaluation/evaluation_result_screen.dart';
import 'patient_consent_screen.dart';
import 'bdk/bdk_type_screen.dart';
import 'prescription/prescription_type_screen.dart';
import '../widgets/design_system/clinical_responsive_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.openPickerOnStart = false});

  final bool openPickerOnStart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = clinicalCategories.keys.first;
  List<Map<String, dynamic>> history = [];
  PatientLocal? currentPatient;
  AccessDirectModel accessDirect = AccessDirectModel.empty;

  final Map<String, List<Map<String, dynamic>>> categories = clinicalCategories
      .map(
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
          decisionMessage: decisionMessage,
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

  Future<void> openPatientScreen() async {
    await Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const PatientConsentScreen()));

    if (!mounted) return;

    await loadInitialData();
  }

  void openBdkTypeScreen() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const BDKTypeScreen()));
  }

  void openPrescriptionTypeScreen() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const PrescriptionTypeScreen()));
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

  String get patientExportCode =>
      currentPatient?.anonymousId ?? 'Patient non renseigné';

  String get decisionTitle => DecisionEngineService.decisionTitle(
    score: score,
    selectedCategory: selectedCategory,
    categories: categories,
  );

  String get decisionMessage => DecisionEngineService.decisionMessage(
    score: score,
    selectedCategory: selectedCategory,
    categories: categories,
  );

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
            child: FadeTransition(opacity: curvedAnimation, child: child),
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
        await Future.delayed(const Duration(milliseconds: 180));

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
    if (!mounted) return;

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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Évaluation enregistrée')));
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
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> exportPdf({required bool printable}) async {
    final canContinue = await confirmAnonymousMode(action: 'exporter un PDF');

    if (!canContinue) return;
    if (!mounted) return;

    await PdfService.exportPdf(
      categories: categories,
      score: score,
      checkedCount: checkedCount,
      riskLevel: riskLevel,
      patientCode: patientExportCode,
      motif: selectedCategory,
      decisionTitle: decisionTitle,
      decisionMessage: decisionMessage,
      aiSummary: aiSummary,
      printable: printable,
    );
  }

  Future<void> exportCsv() async {
    final canContinue = await confirmAnonymousMode(action: 'exporter un CSV');

    if (!canContinue) return;
    if (!mounted) return;

    await CsvService.exportCsv(
      categories: categories,
      score: score,
      riskLevel: riskLevel,
      patientCode: patientExportCode,
    );
  }

  void resetSession() async {
    await RgpdLocalService.clearCurrentPatient();

    if (!mounted) return;

    setState(() {
      currentPatient = null;
      for (final category in categories.values) {
        for (final item in category) {
          item['checked'] = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClinicalResponsivePage(
      backgroundColor: const Color(0xFFF4F8FD),
      mobileMaxWidth: 430,
      desktopMaxWidth: 1040,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          if (isWide) {
            return Column(
              children: [
                const HomeHeroSection(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 150),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              HomePatientClinicalCard(
                                hasPatient: currentPatient != null,
                                patientDisplayName: patientDisplayName,
                              ),
                              const SizedBox(height: 18),
                              HomeScoreCard(
                                score: score,
                                checkedCount: checkedCount,
                                hasPatient: currentPatient != null,
                                patientDisplayName: patientDisplayName,
                                onTap: openCategoryPicker,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              HomeDesktopQuickActions(
                                onPatientTap: openPatientScreen,
                                onBdkTap: openBdkTypeScreen,
                                onPrescriptionTap: openPrescriptionTypeScreen,
                              ),
                              const SizedBox(height: 18),
                              const HomeRiskLegendCard(),
                              const SizedBox(height: 18),
                              const HomeDesktopInfoNote(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              const HomeHeroSection(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 150),
                  child: Column(
                    children: [
                      HomePatientClinicalCard(
                        hasPatient: currentPatient != null,
                        patientDisplayName: patientDisplayName,
                      ),
                      const SizedBox(height: 14),
                      HomeScoreCard(
                        score: score,
                        checkedCount: checkedCount,
                        hasPatient: currentPatient != null,
                        patientDisplayName: patientDisplayName,
                        onTap: openCategoryPicker,
                      ),
                      const SizedBox(height: 14),
                      HomeEvaluationShortcutRow(
                        onPatientTap: openPatientScreen,
                        onBdkTap: openBdkTypeScreen,
                        onPrescriptionTap: openPrescriptionTypeScreen,
                      ),
                      const SizedBox(height: 12),
                      const HomeRiskLegendCard(),
                      const SizedBox(height: 70),
                      const HomeFooterNote(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
