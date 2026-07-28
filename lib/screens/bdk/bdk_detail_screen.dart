import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/bdk_history_item.dart';
import '../../models/patient_local.dart';
import '../../models/practitioner_profile.dart';
import '../../services/bdk_draft_service.dart';
import '../../services/bdk_history_service.dart';
import '../../services/bdk_pdf_service.dart';
import '../../services/bdk_session_service.dart';
import '../../services/practitioner_profile_service.dart';
import '../../services/rgpd_local_service.dart';
import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../features/radar/presentation/widgets/radar_bottom_action_bar.dart';
import '../../features/radar/presentation/widgets/radar_destructive_confirmation_dialog.dart';
import '../../features/radar/presentation/widgets/radar_patient_context.dart';

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
    final patient = await _loadSessionPatient();
    final loadedPractitioner = await PractitionerProfileService.getProfile();

    if (!mounted) return;

    BDKSessionService.associatePatient(
      localId: patient?.localId,
      anonymousId: patient?.anonymousId,
      displayName: RgpdLocalService.patientDisplayName(patient),
    );
    _persistDraft();

    setState(() {
      currentPatient = patient;
      practitioner = loadedPractitioner;
    });
  }

  Future<PatientLocal?> _loadSessionPatient() async {
    final associatedLocalId = BDKSessionService.patientLocalId;
    if (associatedLocalId != null && associatedLocalId.trim().isNotEmpty) {
      final associatedPatient = await RgpdLocalService.getPatientByLocalId(
        associatedLocalId,
      );
      if (associatedPatient != null) return associatedPatient;
    }

    if (BDKSessionService.hasPatientAssociation) {
      return null;
    }

    return RgpdLocalService.getCurrentPatient();
  }

  String get patientDisplayName {
    if (currentPatient != null) {
      return RgpdLocalService.patientDisplayName(currentPatient);
    }

    final associatedDisplayName = BDKSessionService.patientDisplayName.trim();
    if (associatedDisplayName.isNotEmpty) return associatedDisplayName;

    return RgpdLocalService.patientDisplayName(null);
  }

  bool get hasImportedEvaluation {
    return BDKSessionService.riskLevel.isNotEmpty ||
        BDKSessionService.redFlags.isNotEmpty;
  }

  void _addListeners() {
    motifController.addListener(() {
      BDKSessionService.motif = motifController.text;
      _persistDraft();
    });

    contexteController.addListener(() {
      BDKSessionService.contexte = contexteController.text;
      _persistDraft();
    });

    antecedentsController.addListener(() {
      BDKSessionService.antecedents = antecedentsController.text;
      _persistDraft();
    });

    evaluationController.addListener(() {
      BDKSessionService.evaluation = evaluationController.text;
      _persistDraft();
    });

    testsController.addListener(() {
      BDKSessionService.tests = testsController.text;
      _persistDraft();
    });

    limitationsController.addListener(() {
      BDKSessionService.limitations = limitationsController.text;
      _persistDraft();
    });

    diagnosticController.addListener(() {
      BDKSessionService.diagnostic = diagnosticController.text;
      _persistDraft();
    });

    vigilanceController.addListener(() {
      BDKSessionService.vigilance = vigilanceController.text;
      _persistDraft();
    });

    objectifsController.addListener(() {
      BDKSessionService.objectifs = objectifsController.text;
      _persistDraft();
    });

    planTraitementController.addListener(() {
      BDKSessionService.planTraitement = planTraitementController.text;
      _persistDraft();
    });

    criteresReevaluationController.addListener(() {
      BDKSessionService.criteresReevaluation =
          criteresReevaluationController.text;
      _persistDraft();
    });
  }

  void _persistDraft() {
    unawaited(
      BdkDraftService.saveActiveDraft(
        title: widget.title,
        customContext: widget.customContext,
      ),
    );
  }

  Widget buildImportedEvaluationBanner() {
    if (!hasImportedEvaluation) {
      return buildNoImportedEvaluationBanner();
    }

    return Container(
      padding: const EdgeInsets.all(RadarSpacing.lg),
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
      padding: const EdgeInsets.all(RadarSpacing.lg),
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
      padding: const EdgeInsets.all(RadarSpacing.lg),
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
    _persistDraft();
  }

  Future<void> _resetBDK() async {
    final confirm = await showRadarDestructiveConfirmationDialog(
      context,
      title: 'Réinitialiser le BDK ?',
      message:
          'Cette action effacera les champs du bilan et la synthèse clinique en cours.',
      confirmLabel: 'Réinitialiser',
    );

    if (!confirm || !mounted) return;

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
    await BdkDraftService.clearActiveDraft();
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
      final completedAt = DateTime.now();
      final patient = currentPatient;
      await BdkHistoryService.save(
        BdkHistoryItem(
          id: completedAt.microsecondsSinceEpoch.toString(),
          title: widget.title,
          customContext: widget.customContext,
          generatedAt: completedAt,
          updatedAt: completedAt,
          patientLocalId:
              patient?.localId ?? BDKSessionService.patientLocalId ?? '',
          patientAnonymousId:
              patient?.anonymousId ??
              BDKSessionService.patientAnonymousId ??
              '',
          patientDisplayName: patient == null
              ? BDKSessionService.patientDisplayName
              : RgpdLocalService.patientDisplayName(patient),
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
          patientSnapshot: patient?.toJson(),
          practitionerSnapshot: practitioner.toJson(),
        ),
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
    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        bottomNavigationBar: _BdkBottomActionBar(
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
                  constraints: const BoxConstraints(
                    maxWidth: RadarLayout.formWidth,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      RadarSpacing.xl,
                      0,
                      RadarSpacing.xl,
                      RadarSpacing.xxxl + RadarSpacing.xxl + RadarSpacing.lg,
                    ),
                    children: [
                      const RadarPatientContextBar(confirmPatientChange: true),
                      const SizedBox(height: RadarSpacing.lg),
                      buildPatientSummaryCard(),
                      buildImportedEvaluationBanner(),
                      _BdkExpandableSection(
                        title: 'Motif et contexte',
                        subtitle: 'Données patient et raison de consultation',
                        icon: Icons.edit_note_rounded,
                        color: RadarColors.primary,
                        initiallyExpanded: true,
                        children: [
                          _BdkTextField(
                            label: 'Motif de consultation',
                            hint:
                                'Ex : douleur lombaire aiguë, gêne fonctionnelle...',
                            maxLines: 3,
                            controller: motifController,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
                            label: 'Contexte',
                            hint:
                                'Contexte d’apparition, évolution, facteurs aggravants...',
                            maxLines: 3,
                            controller: contexteController,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
                            label: 'Antécédents utiles',
                            hint:
                                'Antécédents médicaux, chirurgicaux, traitements...',
                            maxLines: 3,
                            controller: antecedentsController,
                          ),
                        ],
                      ),
                      _BdkExpandableSection(
                        title: 'Évaluation clinique',
                        subtitle: 'Tests, signes fonctionnels et drapeaux',
                        icon: Icons.monitor_heart_outlined,
                        color: RadarColors.clinicalSuccess,
                        children: [
                          _BdkTextField(
                            label: 'Données issues de l’évaluation',
                            hint:
                                'Auto-remplissage depuis l’onglet Évaluation.',
                            maxLines: 4,
                            controller: evaluationController,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
                            label: 'Tests cliniques',
                            hint:
                                'Ex : mobilité, force, douleur, tests spécifiques...',
                            maxLines: 4,
                            controller: testsController,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
                            label: 'Limitations fonctionnelles',
                            hint:
                                'Marche, transferts, activités quotidiennes, travail...',
                            maxLines: 3,
                            controller: limitationsController,
                          ),
                        ],
                      ),
                      _BdkExpandableSection(
                        title: 'Diagnostic MK',
                        subtitle: 'Synthèse clinique et hypothèses',
                        icon: Icons.psychology_alt_outlined,
                        color: RadarColors.clinicalWarning,
                        children: [
                          _BdkAutoSummaryCard(
                            title: 'Synthèse clinique automatique',
                            text: BDKSessionService.syntheseClinique,
                            emptyText:
                                'La synthèse automatique apparaîtra ici après génération.',
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkPrimaryButton(
                            label: 'Générer la synthèse clinique',
                            icon: Icons.auto_awesome,
                            onPressed: _generateClinicalSummary,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
                            label: 'Diagnostic kinésithérapique',
                            hint:
                                'Synthèse clinique, hypothèses principales, facteurs contributifs...',
                            maxLines: 5,
                            controller: diagnosticController,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
                            label: 'Points de vigilance',
                            hint:
                                'Drapeaux rouges, limites de prise en charge, orientation médicale...',
                            maxLines: 3,
                            controller: vigilanceController,
                          ),
                        ],
                      ),
                      _BdkExpandableSection(
                        title: 'Objectifs et plan de soin',
                        subtitle: 'Objectifs, fréquence, progression',
                        icon: Icons.route_outlined,
                        color: RadarColors.indigo,
                        children: [
                          _BdkTextField(
                            label: 'Objectifs thérapeutiques',
                            hint: 'Objectifs à court, moyen et long terme...',
                            maxLines: 4,
                            controller: objectifsController,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
                            label: 'Plan de traitement',
                            hint:
                                'Fréquence, techniques, exercices, progression...',
                            maxLines: 4,
                            controller: planTraitementController,
                          ),
                          const SizedBox(height: RadarSpacing.md),
                          _BdkTextField(
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
      ),
    );
  }
}

class _BdkExpandableSection extends StatelessWidget {
  const _BdkExpandableSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      margin: const EdgeInsets.only(bottom: RadarSpacing.lg),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(
            horizontal: compact ? RadarSpacing.lg : RadarSpacing.xl,
            vertical: RadarSpacing.sm,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            compact ? RadarSpacing.lg : RadarSpacing.xl,
            0,
            compact ? RadarSpacing.lg : RadarSpacing.xl,
            compact ? RadarSpacing.lg : RadarSpacing.xl,
          ),
          leading: Container(
            width: compact ? 40 : 44,
            height: compact ? 40 : 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(icon, color: color, size: compact ? 22 : 24),
          ),
          title: Text(title, style: RadarTextStyles.contextTitle),
          subtitle: compact
              ? null
              : Text(subtitle, style: RadarTextStyles.caption),
          children: children,
        ),
      ),
    );
  }
}

class _BdkTextField extends StatelessWidget {
  const _BdkTextField({
    required this.label,
    this.hint,
    this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: RadarTextStyles.badge),
        const SizedBox(height: RadarSpacing.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: RadarTextStyles.body.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: RadarTextStyles.secondary.copyWith(
              color: RadarColors.textMuted,
            ),
            filled: true,
            fillColor: RadarColors.background,
            contentPadding: const EdgeInsets.all(RadarSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadarRadius.card),
              borderSide: const BorderSide(color: RadarColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadarRadius.card),
              borderSide: const BorderSide(color: RadarColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadarRadius.card),
              borderSide: const BorderSide(
                color: RadarColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BdkPrimaryButton extends StatelessWidget {
  const _BdkPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: RadarColors.primary,
          foregroundColor: RadarColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadarRadius.card),
          ),
          textStyle: RadarTextStyles.badge,
        ),
      ),
    );
  }
}

class _BdkAutoSummaryCard extends StatelessWidget {
  const _BdkAutoSummaryCard({
    required this.title,
    required this.text,
    required this.emptyText,
  });

  final String title;
  final String text;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.trim().isEmpty;

    return Container(
      padding: const EdgeInsets.all(RadarSpacing.lg),
      decoration: BoxDecoration(
        color: RadarColors.surfaceMuted,
        borderRadius: BorderRadius.circular(RadarRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: RadarColors.primary),
              const SizedBox(width: RadarSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: RadarTextStyles.contextTitle.copyWith(
                    color: RadarColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RadarSpacing.md),
          Text(isEmpty ? emptyText : text, style: RadarTextStyles.body),
        ],
      ),
    );
  }
}

class _BdkBottomActionBar extends StatelessWidget {
  const _BdkBottomActionBar({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.secondaryIcon,
    this.onSecondaryPressed,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return RadarBottomActionBar(
      primaryLabel: primaryLabel,
      primaryIcon: primaryIcon,
      onPrimaryPressed: onPrimaryPressed,
      secondaryLabel: secondaryLabel,
      secondaryIcon: secondaryIcon,
      onSecondaryPressed: onSecondaryPressed,
    );
  }
}
