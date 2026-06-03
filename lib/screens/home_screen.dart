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
                buildUrpsHeader(),
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
                              buildPatientClinicalCard(),
                              const SizedBox(height: 18),
                              buildModernEvaluationCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              buildDesktopActionButtons(),
                              const SizedBox(height: 18),
                              buildRiskLegendCard(),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEFF6FF), Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2563EB,
                                      ).withValues(alpha: 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      color: Color(0xFF2563EB),
                                      size: 28,
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        'Outil d’aide au raisonnement clinique. Les données de santé doivent rester protégées. Cette application ne remplace pas une évaluation médicale professionnelle.',
                                        style: TextStyle(
                                          color: Color(0xFF1E3A8A),
                                          fontSize: 13.5,
                                          height: 1.45,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
              buildUrpsHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 150),
                  child: Column(
                    children: [
                      buildPatientClinicalCard(),
                      const SizedBox(height: 14),
                      buildModernEvaluationCard(),
                      const SizedBox(height: 14),
                      buildEvaluationShortcutRow(),
                      const SizedBox(height: 12),
                      buildRiskLegendCard(),
                      const SizedBox(height: 70),
                      buildPremiumFooterNote(),
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

  Widget buildUrpsHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 42, 22, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004A8F), Color(0xFF0A5FB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'URPS MK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nouvelle-Aquitaine',
                  style: TextStyle(
                    color: Color(0xFFBFD7FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Color(0xFF22C55E), size: 7),
                SizedBox(width: 7),
                Text(
                  'Accès Direct MK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
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

  Widget buildPatientClinicalCard() {
    final hasPatient = currentPatient != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
          bottom: Radius.circular(2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004A8F).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BILAN DE DÉPISTAGE CLINIQUE',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasPatient ? patientDisplayName : 'Patient non renseigné',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF004A8F),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasPatient
                      ? 'Évaluation clinique en cours'
                      : 'Aucun patient sélectionné',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFAF4),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0xFFCBEED8)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Color(0xFF16A34A), size: 7),
                SizedBox(width: 7),
                Text(
                  'SÉCURISÉ',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEvaluationShortcutRow() {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E6F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004A8F).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: buildToolbarItem(
              icon: Icons.person_outline_rounded,
              title: 'Patient',
              subtitle: 'Dossier',
              onTap: openPatientScreen,
            ),
          ),
          buildToolbarDivider(),
          Expanded(
            child: buildToolbarItem(
              icon: Icons.description_outlined,
              title: 'BDK',
              subtitle: 'Bilan',
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => const BDKTypeScreen()),
                );
              },
            ),
          ),
          buildToolbarDivider(),
          Expanded(
            child: buildToolbarItem(
              icon: Icons.medication_liquid_outlined,
              title: 'Prescription',
              subtitle: 'Ordonnance',
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const PrescriptionTypeScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDesktopActionButtons() {
    return Column(
      children: [
        buildDesktopActionButton(
          icon: Icons.person_outline_rounded,
          title: 'Patient',
          subtitle: 'Dossier patient et consentement',
          color: const Color(0xFF2563EB),
          onTap: openPatientScreen,
        ),
        const SizedBox(height: 12),
        buildDesktopActionButton(
          icon: Icons.description_outlined,
          title: 'BDK',
          subtitle: 'Bilan diagnostic kinésithérapique',
          color: const Color(0xFF0F766E),
          onTap: () {
            Navigator.of(
              context,
            ).push(CupertinoPageRoute(builder: (_) => const BDKTypeScreen()));
          },
        ),
        const SizedBox(height: 12),
        buildDesktopActionButton(
          icon: Icons.medication_liquid_outlined,
          title: 'Prescription',
          subtitle: 'Ordonnance et recommandations',
          color: const Color(0xFFE0005B),
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const PrescriptionTypeScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildDesktopActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.11), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: color.withValues(alpha: 0.20)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: color.withValues(alpha: 0.24)),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13.5,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: color.withValues(alpha: 0.12)),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.70),
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToolbarItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2FF),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFC9DDF4)),
            ),
            child: Icon(icon, color: const Color(0xFF004A8F), size: 16),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF004A8F),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildToolbarDivider() {
    return Container(width: 1, color: const Color(0xFFD8E6F5));
  }

  Widget buildRiskLegendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NIVEAUX DE RISQUE',
            style: TextStyle(
              color: Color(0xFFB7C5D8),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              buildPremiumRiskChip('Faible', const Color(0xFF16A34A), false),
              buildPremiumRiskChip('Modéré', const Color(0xFFF97316), false),
              buildPremiumRiskChip('Élevé', const Color(0xFFEF4444), false),
              buildPremiumRiskChip('Critique', const Color(0xFF7F0000), true),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPremiumRiskChip(String label, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color : Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: active ? 1 : 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFF6B6B) : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFFF6B6B) : const Color(0xFF475569),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPremiumFooterNote() {
    return const Text(
      'Outil d’aide clinique · Ne remplace pas le diagnostic médical',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF334155),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget buildModernEvaluationCard() {
    final riskPercent = (score * 10).clamp(0, 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openCategoryPicker,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 370),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.topRight,
              radius: 1.25,
              colors: [Color(0xFF16254A), Color(0xFF081A34), Color(0xFF030B18)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                blurRadius: 60,
                spreadRadius: 8,
                offset: const Offset(0, 22),
              ),
              BoxShadow(
                color: const Color(0xFFE91E63).withValues(alpha: 0.14),
                blurRadius: 50,
                spreadRadius: 2,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFF020617).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'DRAPEAUX ROUGES DÉTECTÉS',
                      style: TextStyle(
                        color: Color(0xFF7D8AA0),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.38),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$riskPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RISQUE',
                          style: TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    checkedCount == 0 ? '0' : '$checkedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checkedCount <= 1
                          ? 'signal critique'
                          : 'signaux critiques',
                      style: const TextStyle(
                        color: Color(0xFFDDE7F3),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                currentPatient == null
                    ? 'Patient non renseigné · Prêt à évaluer'
                    : '$patientDisplayName · Évaluation en cours',
                style: TextStyle(
                  color: Color(0xFFB8C5D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: buildDecisionIndicator(
                      dotColor: const Color(0xFFEF4444),
                      value: checkedCount == 0 ? 'À évaluer' : 'Critique',
                      label: 'NIVEAU DE RISQUE',
                    ),
                  ),
                  buildMetricDivider(),
                  Expanded(
                    child: buildDecisionIndicator(
                      dotColor: const Color(0xFFF59E0B),
                      value: 'Réf. requise',
                      label: 'STATUT CLINIQUE',
                    ),
                  ),
                  buildMetricDivider(),
                  Expanded(
                    child: buildDecisionIndicator(
                      dotColor: const Color(0xFF38BDF8),
                      value: 'Médecin',
                      label: 'ORIENTATION',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'Commencer le dépistage clinique',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDecisionIndicator({
    required Color dotColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
      ],
    );
  }

  Widget buildMetricDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.17),
    );
  }
}
