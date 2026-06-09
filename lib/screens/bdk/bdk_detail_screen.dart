import 'package:flutter/material.dart';

import '../../models/patient_local.dart';
import '../../models/practitioner_profile.dart';
import '../../services/bdk_pdf_service.dart';
import '../../services/bdk_session_service.dart';
import '../../services/practitioner_profile_service.dart';
import '../../services/rgpd_local_service.dart';
import '../../theme/app_design_system.dart';
import '../../widgets/design_system/clinical_auto_summary_card.dart';
import '../../widgets/design_system/clinical_bottom_action_bar.dart';
import '../../widgets/design_system/clinical_primary_button.dart';
import '../../widgets/design_system/clinical_text_field.dart';
import '../../widgets/design_system/expandable_clinical_section.dart';

class BDKDetailScreen extends StatefulWidget {
  const BDKDetailScreen({super.key, required this.title, this.customContext});

  final String title;
  final String? customContext;

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
  PatientLocal? currentPatient;
  PractitionerProfile practitioner = PractitionerProfile.empty();

  @override
  void initState() {
    super.initState();

    motifController = TextEditingController(text: BDKSessionService.motif);
    contexteController = TextEditingController(
      text: BDKSessionService.contexte.isEmpty
          ? widget.customContext ?? ''
          : BDKSessionService.contexte,
    );
    antecedentsController = TextEditingController(
      text: BDKSessionService.antecedents,
    );

    evaluationController = TextEditingController(
      text: BDKSessionService.evaluation,
    );
    testsController = TextEditingController(text: BDKSessionService.tests);
    limitationsController = TextEditingController(
      text: BDKSessionService.limitations,
    );

    diagnosticController = TextEditingController(
      text: BDKSessionService.diagnostic,
    );
    vigilanceController = TextEditingController(
      text: BDKSessionService.vigilance,
    );

    objectifsController = TextEditingController(
      text: BDKSessionService.objectifs,
    );
    planTraitementController = TextEditingController(
      text: BDKSessionService.planTraitement,
    );
    criteresReevaluationController = TextEditingController(
      text: BDKSessionService.criteresReevaluation,
    );

    _addListeners();
    _loadCurrentPatient();
  }

  Future<void> _loadCurrentPatient() async {
    final patient = await RgpdLocalService.getCurrentPatient();
    final loadedPractitioner = await PractitionerProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      currentPatient = patient;
      practitioner = loadedPractitioner;
    });
  }

  String get patientDisplayName =>
      RgpdLocalService.patientDisplayName(currentPatient);

  bool get hasImportedEvaluation {
    return BDKSessionService.riskLevel.isNotEmpty ||
        BDKSessionService.redFlags.isNotEmpty;
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
    if (!hasImportedEvaluation) {
      return buildNoImportedEvaluationBanner();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.22),
        ),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.successGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préremplissage depuis l’évaluation',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Risque : ${BDKSessionService.riskLevel} · '
                  'score ${BDKSessionService.riskScore}\n'
                  '${BDKSessionService.redFlags.length} drapeau(x) transféré(s).',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoImportedEvaluationBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aucune évaluation importée pour le moment. Vous pouvez compléter le BDK manuellement et générer la synthèse clinique.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBdkHeader(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      margin: EdgeInsets.all(compact ? 10 : AppSpacing.screenPadding),
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.successGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.screenTitle.copyWith(
                        color: Colors.white,
                        fontSize: compact ? 20 : 25,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Bilan clinique structuré · export PDF',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                buildHeaderChip(
                  Icons.person_outline_rounded,
                  patientDisplayName,
                ),
                buildHeaderChip(
                  hasImportedEvaluation
                      ? Icons.auto_awesome
                      : Icons.edit_note_rounded,
                  hasImportedEvaluation ? 'Prérempli' : 'Saisie manuelle',
                ),
                buildHeaderChip(Icons.picture_as_pdf_outlined, 'PDF'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildHeaderChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPatientSummaryCard() {
    final patient = currentPatient;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: patient == null
                  ? AppColors.softOrange
                  : AppColors.softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              patient == null
                  ? Icons.no_accounts_outlined
                  : Icons.badge_outlined,
              color: patient == null
                  ? AppColors.warningOrange
                  : AppColors.primaryBlue,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient du BDK',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patientDisplayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                ),
                if (patient != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${patient.anonymousId} · Né(e) le ${patient.dateNaissance}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateClinicalSummary() {
    setState(() {
      BDKSessionService.syntheseClinique =
          '''
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

  Future<void> _exportPdf() async {
    await BdkPdfService.exportBdkPdf(
      title: widget.title,
      patient: currentPatient,
      motif: motifController.text,
      contexte: contexteController.text,
      antecedents: antecedentsController.text,
      evaluation: evaluationController.text,
      tests: testsController.text,
      limitations: limitationsController.text,
      diagnostic: diagnosticController.text,
      vigilance: vigilanceController.text,
      objectifs: objectifsController.text,
      planTraitement: planTraitementController.text,
      criteresReevaluation: criteresReevaluationController.text,
      syntheseClinique: BDKSessionService.syntheseClinique,
      practitioner: practitioner,
    );
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
        onPrimaryPressed: _exportPdf,
      ),
      body: Column(
        children: [
          buildBdkHeader(context),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    96,
                  ),
                  children: [
                    buildPatientSummaryCard(),
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
                          hint: 'Auto-remplissage depuis l’onglet Évaluation.',
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
                          emptyText:
                              'La synthèse automatique apparaîtra ici après génération.',
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
            ),
          ),
        ],
      ),
    );
  }
}
