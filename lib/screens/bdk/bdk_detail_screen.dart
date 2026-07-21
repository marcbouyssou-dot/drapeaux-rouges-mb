import 'package:flutter/material.dart';

import '../../models/patient_local.dart';
import '../../models/practitioner_profile.dart';
import '../../services/bdk_pdf_service.dart';
import '../../services/bdk_session_service.dart';
import '../../services/practitioner_profile_service.dart';
import '../../services/rgpd_local_service.dart';
import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
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
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: RadarSpacing.md),
      decoration: BoxDecoration(
        color: RadarColors.successSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: RadarColors.clinicalSuccess.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: RadarColors.clinicalSuccess,
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
                  style: RadarTextStyles.contextTitle.copyWith(
                    color: RadarColors.clinicalSuccess,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Risque : ${BDKSessionService.riskLevel} · '
                  'score ${BDKSessionService.riskScore}\n'
                  '${BDKSessionService.redFlags.length} drapeau(x) transféré(s).',
                  style: RadarTextStyles.contextSecondary.copyWith(
                    color: RadarColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: RadarSpacing.md),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: RadarColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: RadarColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Text(
              'Aucune évaluation importée pour le moment. Vous pouvez compléter le BDK manuellement et générer la synthèse clinique.',
              style: RadarTextStyles.contextSecondary.copyWith(
                fontWeight: FontWeight.w600,
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
      margin: EdgeInsets.all(compact ? RadarSpacing.sm : RadarSpacing.lg),
      padding: EdgeInsets.all(compact ? RadarSpacing.md : RadarSpacing.lg),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.signature),
        boxShadow: RadarShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(RadarRadius.small),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: RadarColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: RadarColors.primary,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: RadarSpacing.md),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: RadarColors.indigo.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: RadarColors.indigo,
                  ),
                ),
              ],
              const SizedBox(width: RadarSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RadarTextStyles.screenTitle.copyWith(
                        color: RadarColors.textPrimary,
                        fontSize: compact ? 20 : 25,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        'Bilan clinique structuré · export PDF',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.contextSecondary.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: RadarSpacing.md),
            Wrap(
              spacing: RadarSpacing.sm,
              runSpacing: RadarSpacing.sm,
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
        color: RadarColors.surfaceMuted,
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RadarColors.primary, size: 14),
          const SizedBox(width: RadarSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RadarTextStyles.caption.copyWith(
                color: RadarColors.primary,
                fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: RadarSpacing.md),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: patient == null
                  ? RadarColors.warningSoft
                  : RadarColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(
              patient == null
                  ? Icons.no_accounts_outlined
                  : Icons.badge_outlined,
              color: patient == null
                  ? RadarColors.clinicalWarning
                  : RadarColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient du BDK',
                  style: RadarTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: RadarSpacing.xs),
                Text(
                  patientDisplayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.question,
                ),
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
    try {
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le PDF n’a pas pu être généré. Veuillez réessayer.'),
        ),
      );
    }
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
      backgroundColor: RadarColors.background,
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
                  padding: const EdgeInsets.fromLTRB(
                    RadarSpacing.lg,
                    0,
                    RadarSpacing.lg,
                    RadarSpacing.xxxl + RadarSpacing.xxl + RadarSpacing.lg,
                  ),
                  children: [
                    buildPatientSummaryCard(),
                    buildImportedEvaluationBanner(),
                    ExpandableClinicalSection(
                      title: 'Motif et contexte',
                      subtitle: 'Données patient et raison de consultation',
                      icon: Icons.edit_note_rounded,
                      color: RadarColors.primary,
                      initiallyExpanded: true,
                      children: [
                        ClinicalTextField(
                          label: 'Motif de consultation',
                          hint:
                              'Ex : douleur lombaire aiguë, gêne fonctionnelle...',
                          maxLines: 3,
                          controller: motifController,
                        ),
                        const SizedBox(height: RadarSpacing.md),
                        ClinicalTextField(
                          label: 'Contexte',
                          hint:
                              'Contexte d’apparition, évolution, facteurs aggravants...',
                          maxLines: 3,
                          controller: contexteController,
                        ),
                        const SizedBox(height: RadarSpacing.md),
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
                      color: RadarColors.clinicalSuccess,
                      children: [
                        ClinicalTextField(
                          label: 'Données issues de l’évaluation',
                          hint: 'Auto-remplissage depuis l’onglet Évaluation.',
                          maxLines: 4,
                          controller: evaluationController,
                        ),
                        const SizedBox(height: RadarSpacing.md),
                        ClinicalTextField(
                          label: 'Tests cliniques',
                          hint:
                              'Ex : mobilité, force, douleur, tests spécifiques...',
                          maxLines: 4,
                          controller: testsController,
                        ),
                        const SizedBox(height: RadarSpacing.md),
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
                      color: RadarColors.clinicalWarning,
                      children: [
                        ClinicalAutoSummaryCard(
                          title: 'Synthèse clinique automatique',
                          text: BDKSessionService.syntheseClinique,
                          emptyText:
                              'La synthèse automatique apparaîtra ici après génération.',
                        ),
                        const SizedBox(height: RadarSpacing.md),
                        ClinicalPrimaryButton(
                          label: 'Générer la synthèse clinique',
                          icon: Icons.auto_awesome,
                          onPressed: _generateClinicalSummary,
                        ),
                        const SizedBox(height: RadarSpacing.md),
                        ClinicalTextField(
                          label: 'Diagnostic kinésithérapique',
                          hint:
                              'Synthèse clinique, hypothèses principales, facteurs contributifs...',
                          maxLines: 5,
                          controller: diagnosticController,
                        ),
                        const SizedBox(height: RadarSpacing.md),
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
                      color: RadarColors.indigo,
                      children: [
                        ClinicalTextField(
                          label: 'Objectifs thérapeutiques',
                          hint: 'Objectifs à court, moyen et long terme...',
                          maxLines: 4,
                          controller: objectifsController,
                        ),
                        const SizedBox(height: RadarSpacing.md),
                        ClinicalTextField(
                          label: 'Plan de traitement',
                          hint:
                              'Fréquence, techniques, exercices, progression...',
                          maxLines: 4,
                          controller: planTraitementController,
                        ),
                        const SizedBox(height: RadarSpacing.md),
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
