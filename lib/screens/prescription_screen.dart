import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/prescription_templates_data.dart';
import '../models/patient_local.dart';
import '../models/practitioner_profile.dart';
import '../models/prescription_model.dart';
import '../services/practitioner_profile_service.dart';
import '../services/prescription_pdf_service.dart';
import '../services/prescription_service.dart';
import '../services/rgpd_local_service.dart';
import '../features/radar/presentation/theme/radar_colors.dart';
import '../features/radar/presentation/theme/radar_radius.dart';
import '../features/radar/presentation/theme/radar_shadows.dart';
import '../features/radar/presentation/theme/radar_spacing.dart';
import '../features/radar/presentation/theme/radar_text_styles.dart';
import '../features/radar/presentation/theme/radar_theme.dart';
import '../features/radar/presentation/widgets/radar_bottom_action_bar.dart';
import '../features/radar/presentation/widgets/radar_destructive_confirmation_dialog.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({
    super.key,
    this.initialPrescriptionType = 'Rééducation',
  });

  final String initialPrescriptionType;

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  late String selectedPrescriptionType;

  final pathologieController = TextEditingController();
  final materielController = TextEditingController();
  final examensController = TextEditingController();
  final conseilsController = TextEditingController();
  final attestationsController = TextEditingController();
  final autresController = TextEditingController();

  final reeducationObjectifsController = TextEditingController();
  final reeducationFrequenceController = TextEditingController();

  final materielJustificationController = TextEditingController();
  final examensMotifController = TextEditingController();
  final conseilsSurveillanceController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  File? justificatifImage;

  PatientLocal? currentPatient;
  PractitionerProfile practitioner = PractitionerProfile.empty();

  @override
  void initState() {
    super.initState();
    selectedPrescriptionType = widget.initialPrescriptionType;
    loadInitialData();
  }

  @override
  void dispose() {
    pathologieController.dispose();
    materielController.dispose();
    examensController.dispose();
    conseilsController.dispose();
    attestationsController.dispose();
    autresController.dispose();

    reeducationObjectifsController.dispose();
    reeducationFrequenceController.dispose();

    materielJustificationController.dispose();
    examensMotifController.dispose();
    conseilsSurveillanceController.dispose();

    super.dispose();
  }

  Future<void> pickJustificatif() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (image == null) return;

    setState(() {
      justificatifImage = File(image.path);
    });

    showMessage('Justificatif ajouté');
  }

  Future<void> loadInitialData() async {
    final patient = await RgpdLocalService.getCurrentPatient();
    final loadedPractitioner = await PractitionerProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      currentPatient = patient;
      practitioner = loadedPractitioner;
    });
  }

  Future<void> resetForm() async {
    final confirm = await showRadarDestructiveConfirmationDialog(
      context,
      title: 'Réinitialiser la prescription ?',
      message:
          'Cette action effacera les champs de prescription et le justificatif en cours.',
      confirmLabel: 'Réinitialiser',
    );

    if (!confirm || !mounted) return;

    pathologieController.clear();
    materielController.clear();
    examensController.clear();
    conseilsController.clear();
    attestationsController.clear();
    autresController.clear();

    reeducationObjectifsController.clear();
    reeducationFrequenceController.clear();

    materielJustificationController.clear();
    examensMotifController.clear();
    conseilsSurveillanceController.clear();

    setState(() {
      selectedPrescriptionType = widget.initialPrescriptionType;
      justificatifImage = null;
    });

    showMessage('Prescription réinitialisée');
  }

  TextEditingController get activeController {
    switch (selectedPrescriptionType) {
      case 'Matériel':
        return materielController;
      case 'Examens':
        return examensController;
      case 'Conseils':
        return conseilsController;
      case 'Attestations':
        return attestationsController;
      case 'Autres':
        return autresController;
      case 'Rééducation':
      default:
        return pathologieController;
    }
  }

  String get activeTitle {
    switch (selectedPrescriptionType) {
      case 'Matériel':
        return 'Matériel demandé';
      case 'Examens':
        return 'Examen ou avis demandé';
      case 'Conseils':
        return 'Conseils au patient';
      case 'Attestations':
        return 'Attestation';
      case 'Autres':
        return 'Document libre';
      case 'Rééducation':
      default:
        return 'Pathologie / motif';
    }
  }

  String get activeHint {
    switch (selectedPrescriptionType) {
      case 'Matériel':
        return 'Exemple : attelle de cheville, cannes anglaises, bas de contention...';
      case 'Examens':
        return 'Exemple : avis médical, imagerie à envisager, doppler si suspicion TVP...';
      case 'Conseils':
        return 'Exemple : glaçage, compression, auto-exercices, surveillance...';
      case 'Attestations':
        return 'Exemple : attestation de présence, suivi kinésithérapique, situation clinique...';
      case 'Autres':
        return 'Exemple : autre recommandation ou document personnalisé...';
      case 'Rééducation':
      default:
        return 'Exemple : lombalgie aiguë, entorse de cheville, rééducation respiratoire...';
    }
  }

  String get prescriptionContentForPdf {
    switch (selectedPrescriptionType) {
      case 'Rééducation':
        return [
          if (pathologieController.text.trim().isNotEmpty)
            'Pathologie / motif : ${pathologieController.text.trim()}',
          if (reeducationObjectifsController.text.trim().isNotEmpty)
            'Objectifs : ${reeducationObjectifsController.text.trim()}',
          if (reeducationFrequenceController.text.trim().isNotEmpty)
            'Fréquence / durée : ${reeducationFrequenceController.text.trim()}',
        ].join('\n\n');

      case 'Matériel':
        return [
          if (materielController.text.trim().isNotEmpty)
            'Matériel demandé : ${materielController.text.trim()}',
          if (materielJustificationController.text.trim().isNotEmpty)
            'Justification clinique : ${materielJustificationController.text.trim()}',
        ].join('\n\n');

      case 'Examens':
        return [
          if (examensController.text.trim().isNotEmpty)
            'Examen / avis demandé : ${examensController.text.trim()}',
          if (examensMotifController.text.trim().isNotEmpty)
            'Motif clinique : ${examensMotifController.text.trim()}',
        ].join('\n\n');

      case 'Conseils':
        return [
          if (conseilsController.text.trim().isNotEmpty)
            'Conseils : ${conseilsController.text.trim()}',
          if (conseilsSurveillanceController.text.trim().isNotEmpty)
            'Points de surveillance : ${conseilsSurveillanceController.text.trim()}',
        ].join('\n\n');

      case 'Attestations':
        return attestationsController.text.trim();

      case 'Autres':
      default:
        return autresController.text.trim();
    }
  }

  Future<void> exportPdf() async {
    if (currentPatient == null) {
      showMessage('Aucun patient actif. Sélectionnez un patient avant export.');
      return;
    }

    if (!practitioner.isComplete) {
      showMessage('Merci de renseigner vos informations professionnelles.');
      await showPractitionerDialog();
      return;
    }

    final content = prescriptionContentForPdf.trim();

    if (content.isEmpty) {
      showMessage('Merci de renseigner le contenu de la prescription.');
      return;
    }

    await PrescriptionPdfService.exportPrescriptionPdf(
      patient: currentPatient!,
      practitioner: practitioner,
      prescriptionType: selectedPrescriptionType,
      prescriptionContent: content,
      justificatifImage: justificatifImage,
    );

    await PrescriptionService.savePrescription(
      PrescriptionModel.fromGenerated(
        patient: currentPatient!,
        practitioner: practitioner,
        prescriptionType: selectedPrescriptionType,
        prescriptionContent: content,
        justificatifImageBase64: justificatifImage == null
            ? null
            : base64Encode(await justificatifImage!.readAsBytes()),
      ),
    );

    showMessage('Prescription enregistrée dans l’historique.');
  }

  Future<void> showPractitionerDialog() async {
    final nomController = TextEditingController(text: practitioner.nom);
    final prenomController = TextEditingController(text: practitioner.prenom);
    final adresseController = TextEditingController(text: practitioner.adresse);
    final adeliController = TextEditingController(text: practitioner.adeli);
    final rppsController = TextEditingController(text: practitioner.rpps);
    final professionController = TextEditingController(
      text: practitioner.profession,
    );
    final emailController = TextEditingController(text: practitioner.email);
    final telephoneController = TextEditingController(
      text: practitioner.telephone,
    );
    final structureController = TextEditingController(
      text: practitioner.nomStructure,
    );
    var exerciceCoordonne = practitioner.exerciceCoordonne;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Informations professionnelles'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    buildDialogField(controller: nomController, label: 'Nom'),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: prenomController,
                      label: 'Prénom',
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: professionController,
                      label: 'Profession',
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: adresseController,
                      label: 'Adresse professionnelle',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: emailController,
                      label: 'Email professionnel',
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: telephoneController,
                      label: 'Téléphone professionnel',
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: adeliController,
                      label: 'ADELI',
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(controller: rppsController, label: 'RPPS'),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: exerciceCoordonne,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Structure d’exercice coordonné'),
                      subtitle: const Text('MSP, CPTS, centre de santé...'),
                      onChanged: (value) {
                        setDialogState(() {
                          exerciceCoordonne = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: structureController,
                      label: 'Nom de structure',
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final profile = PractitionerProfile(
                  nom: nomController.text.trim(),
                  prenom: prenomController.text.trim(),
                  adresse: adresseController.text.trim(),
                  adeli: adeliController.text.trim(),
                  rpps: rppsController.text.trim(),
                  profession: professionController.text.trim(),
                  email: emailController.text.trim(),
                  telephone: telephoneController.text.trim(),
                  exerciceCoordonne: exerciceCoordonne,
                  nomStructure: structureController.text.trim(),
                  signatureBase64: practitioner.signatureBase64,
                );

                await PractitionerProfileService.saveProfile(profile);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    nomController.dispose();
    prenomController.dispose();
    adresseController.dispose();
    adeliController.dispose();
    rppsController.dispose();
    professionController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    structureController.dispose();

    if (saved == true) {
      await loadInitialData();

      if (!mounted) return;

      showMessage('Informations professionnelles enregistrées.');
    }
  }

  Widget buildDialogField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: RadarColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadarRadius.card),
        ),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get patientName {
    return RgpdLocalService.patientDisplayName(currentPatient);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        bottomNavigationBar: _DocumentBottomActionBar(
          secondaryLabel: 'Réinitialiser',
          secondaryIcon: Icons.refresh_rounded,
          onSecondaryPressed: resetForm,
          primaryLabel: 'Exporter PDF',
          primaryIcon: Icons.picture_as_pdf_outlined,
          onPrimaryPressed: exportPdf,
        ),
        body: Column(
          children: [
            buildPrescriptionHeader(context),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      RadarSpacing.xl,
                      0,
                      RadarSpacing.xl,
                      112,
                    ),
                    children: [
                      buildReadinessSummary(),
                      const SizedBox(height: RadarSpacing.lg),
                      buildPatientCard(),
                      const SizedBox(height: RadarSpacing.lg),
                      buildPractitionerCard(),
                      const SizedBox(height: RadarSpacing.lg),
                      buildAccessDirectPrescriptionCard(),
                      const SizedBox(height: RadarSpacing.lg),
                      buildPrescriptionCard(),
                      const SizedBox(height: RadarSpacing.lg),
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            'Notes réglementaires',
                            style: RadarTextStyles.contextTitle,
                          ),
                          children: const [
                            _DocumentInfoBanner(
                              text:
                                  'Les prescriptions et recommandations doivent rester conformes aux compétences, droits de prescription et conditions réglementaires du masseur-kinésithérapeute.',
                              icon: Icons.gavel_rounded,
                              color: RadarColors.clinicalWarning,
                              backgroundColor: RadarColors.warningSoft,
                            ),
                            SizedBox(height: RadarSpacing.md),
                            _DocumentInfoBanner(
                              text:
                                  'PDF sobre, lisible et économique à imprimer.',
                              icon: Icons.print_outlined,
                              color: RadarColors.textSecondary,
                              backgroundColor: RadarColors.surface,
                            ),
                          ],
                        ),
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

  Widget buildPrescriptionHeader(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      margin: EdgeInsets.fromLTRB(
        compact ? RadarSpacing.md : RadarSpacing.xl,
        compact ? RadarSpacing.md : RadarSpacing.xl,
        compact ? RadarSpacing.md : RadarSpacing.xl,
        RadarSpacing.lg,
      ),
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
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
                    color: RadarColors.background,
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
                    color: RadarColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadarRadius.small),
                  ),
                  child: const Icon(
                    Icons.edit_document,
                    color: RadarColors.primary,
                  ),
                ),
              ],
              const SizedBox(width: RadarSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedPrescriptionType,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RadarTextStyles.screenTitle.copyWith(
                        fontSize: compact ? 20 : 25,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: RadarSpacing.sm),
                      const Text(
                        'Prescription clinique · document thérapeutique · PDF',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.secondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: RadarSpacing.lg),
            Wrap(
              spacing: RadarSpacing.sm,
              runSpacing: RadarSpacing.sm,
              children: [
                buildHeaderChip(Icons.person_outline_rounded, patientName),
                buildHeaderChip(
                  practitioner.isComplete
                      ? Icons.verified_user_outlined
                      : Icons.edit_note_rounded,
                  practitioner.isComplete
                      ? 'Profil prêt'
                      : 'Profil à compléter',
                ),
                buildHeaderChip(Icons.picture_as_pdf_outlined, 'Export PDF'),
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
        color: RadarColors.background,
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
                color: RadarColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReadinessSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final items = [
          _ReadinessItem(
            icon: currentPatient == null
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            label: 'Patient',
            value: currentPatient == null ? 'À sélectionner' : 'Actif',
            color: currentPatient == null
                ? RadarColors.clinicalWarning
                : RadarColors.clinicalSuccess,
          ),
          _ReadinessItem(
            icon: practitioner.isComplete
                ? Icons.check_circle_outline_rounded
                : Icons.edit_note_rounded,
            label: 'Professionnel',
            value: practitioner.isComplete ? 'Prêt' : 'À compléter',
            color: practitioner.isComplete
                ? RadarColors.clinicalSuccess
                : RadarColors.clinicalWarning,
          ),
          _ReadinessItem(
            icon: Icons.library_books_outlined,
            label: 'Type',
            value: selectedPrescriptionType,
            color: RadarColors.primary,
          ),
        ];

        if (constraints.maxWidth >= 620) {
          return Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: item == items.last ? 0 : 10,
                      ),
                      child: item,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(
                    bottom: item == items.last ? 0 : RadarSpacing.sm,
                  ),
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget buildPatientCard() {
    final hasPatient = currentPatient != null;

    return Container(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: hasPatient ? RadarColors.surface : RadarColors.warningSoft,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: hasPatient
                  ? RadarColors.primary.withValues(alpha: 0.10)
                  : RadarColors.clinicalWarning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(
              hasPatient ? Icons.person_rounded : Icons.warning_amber_rounded,
              color: hasPatient
                  ? RadarColors.primary
                  : RadarColors.clinicalWarning,
              size: 24,
            ),
          ),
          const SizedBox(width: RadarSpacing.lg),
          Expanded(
            child: hasPatient
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Patient', style: RadarTextStyles.caption),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        patientName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.contextTitle,
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        '${currentPatient!.anonymousId} · Né(e) le ${currentPatient!.dateNaissance}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.secondary,
                      ),
                    ],
                  )
                : Text(
                    'Aucun patient actif. Sélectionnez ou créez un patient dans l’onglet Patient.',
                    style: RadarTextStyles.secondary.copyWith(
                      color: RadarColors.clinicalWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          IconButton(
            onPressed: loadInitialData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            color: RadarColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget buildPractitionerCard() {
    final complete = practitioner.isComplete;

    return Container(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: complete ? RadarColors.surface : RadarColors.warningSoft,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: complete
                  ? RadarColors.primary.withValues(alpha: 0.10)
                  : RadarColors.clinicalWarning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(
              complete ? Icons.badge_rounded : Icons.edit_note_rounded,
              color: complete
                  ? RadarColors.primary
                  : RadarColors.clinicalWarning,
              size: 24,
            ),
          ),
          const SizedBox(width: RadarSpacing.lg),
          Expanded(
            child: complete
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Professionnel',
                        style: RadarTextStyles.caption,
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        practitioner.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.contextTitle,
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(
                        [
                          if (practitioner.adeli.trim().isNotEmpty)
                            'ADELI ${practitioner.adeli.trim()}',
                          if (practitioner.rpps.trim().isNotEmpty)
                            'RPPS ${practitioner.rpps.trim()}',
                        ].join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RadarTextStyles.secondary,
                      ),
                    ],
                  )
                : Text(
                    'Renseignez une seule fois vos informations professionnelles pour les PDF.',
                    style: RadarTextStyles.secondary.copyWith(
                      color: RadarColors.clinicalWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          IconButton(
            onPressed: showPractitionerDialog,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Modifier',
            color: RadarColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget buildAccessDirectPrescriptionCard() {
    final hasImage = justificatifImage != null;

    return Container(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: RadarSpacing.xl,
            vertical: RadarSpacing.sm,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            RadarSpacing.xl,
            0,
            RadarSpacing.xl,
            RadarSpacing.xl,
          ),
          leading: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: RadarColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: RadarColors.primary,
            ),
          ),
          title: Text(
            'Accès direct & cadre réglementaire',
            style: RadarTextStyles.contextTitle,
          ),
          subtitle: Text(
            'Conditions d’exercice, diagnostic préalable, justificatif.',
            style: RadarTextStyles.secondary,
          ),
          children: [
            const _MiniRegulatoryLine(
              icon: Icons.groups_rounded,
              title: 'Exercice coordonné',
              subtitle:
                  'MSP, CPTS ou structure coordonnée selon le cadre applicable.',
            ),
            const SizedBox(height: RadarSpacing.sm),
            const _MiniRegulatoryLine(
              icon: Icons.medical_information_outlined,
              title: 'Diagnostic médical préalable',
              subtitle: 'Si diagnostic déjà posé : justificatif recommandé.',
            ),
            const SizedBox(height: RadarSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: pickJustificatif,
                icon: Icon(
                  hasImage
                      ? Icons.check_circle_rounded
                      : Icons.camera_alt_rounded,
                ),
                label: Text(
                  hasImage ? 'Justificatif ajouté' : 'Ajouter un justificatif',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: hasImage
                      ? RadarColors.clinicalSuccess
                      : RadarColors.primary,
                  backgroundColor: hasImage
                      ? RadarColors.successSoft
                      : RadarColors.surfaceMuted,
                  padding: const EdgeInsets.symmetric(
                    vertical: RadarSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadarRadius.card),
                  ),
                ),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(height: RadarSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(RadarRadius.card),
                child: Image.file(
                  justificatifImage!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildPrescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: RadarColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.small),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: RadarColors.primary,
                ),
              ),
              const SizedBox(width: RadarSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RadarTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: RadarSpacing.xs),
                    const Text(
                      'Complétez les champs utiles au PDF de prescription.',
                      style: RadarTextStyles.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RadarSpacing.lg),
          ...buildPrescriptionFields(),
          buildTemplatesSection(),
        ],
      ),
    );
  }

  List<Widget> buildPrescriptionFields() {
    switch (selectedPrescriptionType) {
      case 'Rééducation':
        return [
          _DocumentTextField(
            label: 'Pathologie / motif',
            hint:
                'Exemple : lombalgie aiguë, entorse de cheville, rééducation respiratoire...',
            maxLines: 3,
            controller: pathologieController,
          ),
          const SizedBox(height: 12),
          _DocumentTextField(
            label: 'Objectifs de rééducation',
            hint:
                'Exemple : diminution de la douleur, récupération fonctionnelle...',
            maxLines: 3,
            controller: reeducationObjectifsController,
          ),
          const SizedBox(height: 12),
          _DocumentTextField(
            label: 'Fréquence / durée',
            hint: 'Exemple : 2 séances par semaine pendant 6 semaines...',
            maxLines: 2,
            controller: reeducationFrequenceController,
          ),
        ];

      case 'Matériel':
        return [
          _DocumentTextField(
            label: 'Matériel demandé',
            hint:
                'Exemple : attelle de cheville, cannes anglaises, bas de contention...',
            maxLines: 3,
            controller: materielController,
          ),
          const SizedBox(height: 12),
          _DocumentTextField(
            label: 'Justification clinique',
            hint: 'Exemple : instabilité, douleur, limitation d’appui...',
            maxLines: 3,
            controller: materielJustificationController,
          ),
        ];

      case 'Examens':
        return [
          _DocumentTextField(
            label: 'Examen / avis demandé',
            hint:
                'Exemple : avis médical, imagerie à envisager, doppler si suspicion TVP...',
            maxLines: 3,
            controller: examensController,
          ),
          const SizedBox(height: 12),
          _DocumentTextField(
            label: 'Motif clinique',
            hint: 'Exemple : douleur persistante, suspicion de complication...',
            maxLines: 3,
            controller: examensMotifController,
          ),
        ];

      case 'Conseils':
        return [
          _DocumentTextField(
            label: 'Conseils au patient',
            hint: 'Exemple : glaçage, compression, auto-exercices...',
            maxLines: 3,
            controller: conseilsController,
          ),
          const SizedBox(height: 12),
          _DocumentTextField(
            label: 'Points de surveillance',
            hint:
                'Exemple : aggravation douleur, fièvre, déficit neurologique...',
            maxLines: 3,
            controller: conseilsSurveillanceController,
          ),
        ];

      case 'Attestations':
        return [
          _DocumentTextField(
            label: 'Contenu de l’attestation',
            hint:
                'Exemple : attestation de présence, suivi kinésithérapique, situation clinique...',
            maxLines: 4,
            controller: attestationsController,
          ),
        ];

      case 'Autres':
      default:
        return [
          _DocumentTextField(
            label: 'Document libre',
            hint: 'Exemple : autre recommandation ou document personnalisé...',
            maxLines: 4,
            controller: autresController,
          ),
        ];
    }
  }

  Widget buildTemplatesSection() {
    final templates = prescriptionTemplates[selectedPrescriptionType] ?? [];

    if (templates.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: RadarSpacing.lg),
        padding: const EdgeInsets.all(RadarSpacing.lg),
        decoration: BoxDecoration(
          color: RadarColors.background,
          borderRadius: BorderRadius.circular(RadarRadius.card),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: RadarColors.textSecondary),
            SizedBox(width: RadarSpacing.md),
            Expanded(
              child: Text(
                'Aucun modèle rapide pour ce type. Renseignez librement le contenu.',
                style: RadarTextStyles.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: RadarSpacing.lg),
        Container(
          padding: const EdgeInsets.all(RadarSpacing.lg),
          decoration: BoxDecoration(
            color: RadarColors.background,
            borderRadius: BorderRadius.circular(RadarRadius.card),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: RadarColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.small),
                ),
                child: const Icon(
                  Icons.library_books_outlined,
                  color: RadarColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: RadarSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Modèles rapides',
                      style: RadarTextStyles.contextTitle,
                    ),
                    const SizedBox(height: RadarSpacing.xs),
                    const Text(
                      'Ajoutent du texte dans le champ principal.',
                      style: RadarTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RadarSpacing.md),
        Wrap(
          spacing: RadarSpacing.sm,
          runSpacing: RadarSpacing.sm,
          children: templates.map((template) {
            return ActionChip(
              label: Text(template),
              backgroundColor: RadarColors.background,
              side: const BorderSide(color: RadarColors.border),
              labelStyle: RadarTextStyles.badge.copyWith(
                color: RadarColors.textPrimary,
              ),
              onPressed: () {
                final currentText = activeController.text.trim();

                activeController.text = currentText.isEmpty
                    ? template
                    : '$currentText\n• $template';

                activeController.selection = TextSelection.fromPosition(
                  TextPosition(offset: activeController.text.length),
                );

                setState(() {});
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MiniRegulatoryLine extends StatelessWidget {
  const _MiniRegulatoryLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: RadarColors.primary, size: 22),
        const SizedBox(width: RadarSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RadarTextStyles.contextTitle),
              const SizedBox(height: RadarSpacing.xs),
              Text(subtitle, style: RadarTextStyles.secondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadinessItem extends StatelessWidget {
  const _ReadinessItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadarSpacing.lg),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.caption.copyWith(
                    color: RadarColors.textSecondary,
                  ),
                ),
                const SizedBox(height: RadarSpacing.xs),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.contextTitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTextField extends StatelessWidget {
  const _DocumentTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
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

class _DocumentInfoBanner extends StatelessWidget {
  const _DocumentInfoBanner({
    required this.text,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadarSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(RadarRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: RadarSpacing.md),
          Expanded(child: Text(text, style: RadarTextStyles.secondary)),
        ],
      ),
    );
  }
}

class _DocumentBottomActionBar extends StatelessWidget {
  const _DocumentBottomActionBar({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondaryPressed,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimaryPressed;
  final String secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback onSecondaryPressed;

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
