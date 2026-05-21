import 'package:flutter/material.dart';

import '../../services/bdk_session_service.dart';
import '../../theme/app_design_system.dart';
import '../../widgets/design_system/clinical_auto_summary_card.dart';
import '../../widgets/design_system/clinical_bottom_action_bar.dart';
import '../../widgets/design_system/clinical_page_header.dart';
import '../../widgets/design_system/clinical_primary_button.dart';
import '../../widgets/design_system/clinical_text_field.dart';
import '../../widgets/design_system/expandable_clinical_section.dart';

class BDKDetailScreen extends StatefulWidget {
  const BDKDetailScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<BDKDetailScreen> createState() => _BDKDetailScreenState();
}

class _BDKDetailScreenState extends State<BDKDetailScreen> {
  late final TextEditingController motifController;
  late final TextEditingController contexteController;
  late final TextEditingController antecedentsController;

  late final TextEditingController evaluationController;
  late final TextEditingController testsController;
  late final TextEditingController limitationsController;

  late final TextEditingController diagnosticController;
  late final TextEditingController vigilanceController;

  late final TextEditingController objectifsController;
  late final TextEditingController planTraitementController;
  late final TextEditingController criteresReevaluationController;

  @override
  void initState() {
    super.initState();

    motifController = TextEditingController(text: BDKSessionService.motif);
    contexteController = TextEditingController(text: BDKSessionService.contexte);
    antecedentsController =
        TextEditingController(text: BDKSessionService.antecedents);

    evaluationController =
        TextEditingController(text: BDKSessionService.evaluation);
    testsController = TextEditingController(text: BDKSessionService.tests);
    limitationsController =
        TextEditingController(text: BDKSessionService.limitations);

    diagnosticController =
        TextEditingController(text: BDKSessionService.diagnostic);
    vigilanceController =
        TextEditingController(text: BDKSessionService.vigilance);

    objectifsController =
        TextEditingController(text: BDKSessionService.objectifs);
    planTraitementController =
        TextEditingController(text: BDKSessionService.planTraitement);
    criteresReevaluationController =
        TextEditingController(text: BDKSessionService.criteresReevaluation);

    _addListeners();
  }

  void _addListeners() {
    motifController.addListener(() {
      BDKSessionService.motif = motifController.text;
    });

    contexteController.addListener(() {
      BDKSessionService.contexte = contexteController.text;
    });

    antecedentsController.addListener(() {
      BDKSessionService.antecedents = antecedentsController.text;
    });

    evaluationController.addListener(() {
      BDKSessionService.evaluation = evaluationController.text;
    });

    testsController.addListener(() {
      BDKSessionService.tests = testsController.text;
    });

    limitationsController.addListener(() {
      BDKSessionService.limitations = limitationsController.text;
    });

    diagnosticController.addListener(() {
      BDKSessionService.diagnostic = diagnosticController.text;
    });

    vigilanceController.addListener(() {
      BDKSessionService.vigilance = vigilanceController.text;
    });

    objectifsController.addListener(() {
      BDKSessionService.objectifs = objectifsController.text;
    });

    planTraitementController.addListener(() {
      BDKSessionService.planTraitement = planTraitementController.text;
    });

    criteresReevaluationController.addListener(() {
      BDKSessionService.criteresReevaluation =
          criteresReevaluationController.text;
    });
  }

  Widget buildImportedEvaluationBanner() {
    final hasImportedEvaluation =
        BDKSessionService.riskLevel.isNotEmpty ||
        BDKSessionService.redFlags.isNotEmpty;

    if (!hasImportedEvaluation) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.primaryBlue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'BDK prérempli depuis l’évaluation.\n'
              'Risque : ${BDKSessionService.riskLevel} — '
              'score ${BDKSessionService.riskScore}\n'
              '${BDKSessionService.redFlags.length} drapeau(x) transféré(s).',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateClinicalSummary() {
    setState(() {
      BDKSessionService.syntheseClinique = '''
Patient présentant ${motifController.text.trim().isEmpty ? 'un motif non renseigné' : motifController.text.trim()}.

Le contexte clinique retrouve :
${contexteController.text.trim().isEmpty ? 'Aucun contexte précisé.' : contexteController.text.trim()}

Les limitations fonctionnelles principales sont :
${limitationsController.text.trim().isEmpty ? 'Non renseignées.' : limitationsController.text.trim()}

Les principaux éléments d’évaluation clinique évoquent :
${evaluationController.text.trim().isEmpty ? 'Évaluation non renseignée.' : evaluationController.text.trim()}

Une prise en charge kinésithérapique adaptée semble indiquée avec surveillance clinique évolutive.
''';
    });
  }

  void _resetBDK() {
    setState(() {
      BDKSessionService.clear();

      motifController.clear();
      contexteController.clear();
      antecedentsController.clear();

      evaluationController.clear();
      testsController.clear();
      limitationsController.clear();

      diagnosticController.clear();
      vigilanceController.clear();

      objectifsController.clear();
      planTraitementController.clear();
      criteresReevaluationController.clear();
    });
  }

  @override
  void dispose() {
    motifController.dispose();
    contexteController.dispose();
    antecedentsController.dispose();

    evaluationController.dispose();
    testsController.dispose();
    limitationsController.dispose();

    diagnosticController.dispose();
    vigilanceController.dispose();

    objectifsController.dispose();
    planTraitementController.dispose();
    criteresReevaluationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: ClinicalBottomActionBar(
        secondaryLabel: 'Réinitialiser',
        secondaryIcon: Icons.restart_alt_rounded,
        onSecondaryPressed: _resetBDK,
        primaryLabel: 'Exporter PDF',
        primaryIcon: Icons.picture_as_pdf_outlined,
        onPrimaryPressed: () {
          // Export PDF BDK à brancher ensuite
        },
      ),
      body: Column(
        children: [
          ClinicalPageHeader(
            title: widget.title,
            subtitle: 'Bilan structuré avec auto-remplissage clinique.',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                buildImportedEvaluationBanner(),

                ExpandableClinicalSection(
                  title: 'Motif et contexte',
                  subtitle: 'Données patient et raison de consultation',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.primaryBlue,
                  initiallyExpanded: true,
                  children: [
                    ClinicalTextField(
                      label: 'Motif de consultation',
                      hint:
                          'Ex : douleur lombaire aiguë, gêne fonctionnelle...',
                      maxLines: 3,
                      controller: motifController,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Contexte',
                      hint:
                          'Contexte d’apparition, évolution, facteurs aggravants...',
                      maxLines: 3,
                      controller: contexteController,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Antécédents utiles',
                      hint:
                          'Antécédents médicaux, chirurgicaux, traitements...',
                      maxLines: 3,
                      controller: antecedentsController,
                    ),
                  ],
                ),

                ExpandableClinicalSection(
                  title: 'Évaluation clinique',
                  subtitle: 'Tests, signes fonctionnels et drapeaux',
                  icon: Icons.monitor_heart_outlined,
                  color: AppColors.successGreen,
                  children: [
                    ClinicalTextField(
                      label: 'Données issues de l’évaluation',
                      hint:
                          'Auto-remplissage depuis l’onglet Évaluation.',
                      maxLines: 4,
                      controller: evaluationController,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Tests cliniques',
                      hint:
                          'Ex : mobilité, force, douleur, tests spécifiques...',
                      maxLines: 4,
                      controller: testsController,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Limitations fonctionnelles',
                      hint:
                          'Marche, transferts, activités quotidiennes, travail...',
                      maxLines: 3,
                      controller: limitationsController,
                    ),
                  ],
                ),

                ExpandableClinicalSection(
                  title: 'Diagnostic MK',
                  subtitle: 'Synthèse clinique et hypothèses',
                  icon: Icons.psychology_alt_outlined,
                  color: AppColors.warningOrange,
                  children: [
                    ClinicalAutoSummaryCard(
                      title: 'Synthèse clinique automatique',
                      text: BDKSessionService.syntheseClinique,
                      emptyText: 'La synthèse automatique apparaîtra ici.',
                    ),
                    const SizedBox(height: 16),
                    ClinicalPrimaryButton(
                      label: 'Générer la synthèse clinique',
                      icon: Icons.auto_awesome,
                      onPressed: _generateClinicalSummary,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Diagnostic kinésithérapique',
                      hint:
                          'Synthèse clinique, hypothèses principales, facteurs contributifs...',
                      maxLines: 5,
                      controller: diagnosticController,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Points de vigilance',
                      hint:
                          'Drapeaux rouges, limites de prise en charge, orientation médicale...',
                      maxLines: 3,
                      controller: vigilanceController,
                    ),
                  ],
                ),

                ExpandableClinicalSection(
                  title: 'Objectifs et plan de soin',
                  subtitle: 'Objectifs, fréquence, progression',
                  icon: Icons.route_outlined,
                  color: Colors.deepPurple,
                  children: [
                    ClinicalTextField(
                      label: 'Objectifs thérapeutiques',
                      hint: 'Objectifs à court, moyen et long terme...',
                      maxLines: 4,
                      controller: objectifsController,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Plan de traitement',
                      hint:
                          'Fréquence, techniques, exercices, progression...',
                      maxLines: 4,
                      controller: planTraitementController,
                    ),
                    const SizedBox(height: 16),
                    ClinicalTextField(
                      label: 'Critères de réévaluation',
                      hint:
                          'Douleur, fonction, autonomie, tests de suivi...',
                      maxLines: 3,
                      controller: criteresReevaluationController,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}