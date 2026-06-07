import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/prescription_templates_data.dart';
import '../models/patient_local.dart';
import '../models/practitioner_profile.dart';
import '../services/practitioner_profile_service.dart';
import '../services/prescription_pdf_service.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_design_system.dart';
import '../widgets/design_system/clinical_bottom_action_bar.dart';
import '../widgets/design_system/clinical_info_banner.dart';
import '../widgets/design_system/clinical_text_field.dart';

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

  void resetForm() {
    pathologieController.clear();
    materielController.clear();
    examensController.clear();
    conseilsController.clear();
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
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: ClinicalBottomActionBar(
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
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    120,
                  ),
                  children: [
                    buildReadinessSummary(),
                    const SizedBox(height: 14),
                    buildPatientCard(),
                    const SizedBox(height: 14),
                    buildPractitionerCard(),
                    const SizedBox(height: 14),
                    buildAccessDirectPrescriptionCard(),
                    const SizedBox(height: 14),
                    buildPrescriptionCard(),
                    const SizedBox(height: 14),
                    ClinicalInfoBanner(
                      text:
                          'Les prescriptions et recommandations doivent rester conformes aux compétences, droits de prescription et conditions réglementaires du masseur-kinésithérapeute.',
                      icon: Icons.gavel_rounded,
                      color: AppColors.warningOrange,
                      backgroundColor: AppColors.softOrange,
                    ),
                    const SizedBox(height: 14),
                    ClinicalInfoBanner(
                      text: 'PDF sobre, lisible et économique à imprimer.',
                      icon: Icons.print_outlined,
                      color: AppColors.textSecondary,
                      backgroundColor: AppColors.card,
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

  Widget buildPrescriptionHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.warningOrange,
            AppColors.primaryBlue,
          ],
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
                child: const Icon(Icons.edit_document, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedPrescriptionType,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.screenTitle.copyWith(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Prescription clinique · document thérapeutique · PDF',
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildHeaderChip(Icons.person_outline_rounded, patientName),
              buildHeaderChip(
                practitioner.isComplete
                    ? Icons.verified_user_outlined
                    : Icons.edit_note_rounded,
                practitioner.isComplete ? 'Profil prêt' : 'Profil à compléter',
              ),
              buildHeaderChip(Icons.picture_as_pdf_outlined, 'Export PDF'),
            ],
          ),
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
                ? AppColors.warningOrange
                : AppColors.successGreen,
          ),
          _ReadinessItem(
            icon: practitioner.isComplete
                ? Icons.check_circle_outline_rounded
                : Icons.edit_note_rounded,
            label: 'Professionnel',
            value: practitioner.isComplete ? 'Prêt' : 'À compléter',
            color: practitioner.isComplete
                ? AppColors.successGreen
                : AppColors.warningOrange,
          ),
          _ReadinessItem(
            icon: Icons.library_books_outlined,
            label: 'Type',
            value: selectedPrescriptionType,
            color: AppColors.primaryBlue,
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
                  padding: EdgeInsets.only(bottom: item == items.last ? 0 : 10),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasPatient ? AppColors.card : AppColors.softOrange,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasPatient ? AppColors.border : const Color(0xFFFED7AA),
        ),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: hasPatient ? AppColors.softBlue : AppColors.softOrange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              hasPatient ? Icons.person_rounded : Icons.warning_amber_rounded,
              color: hasPatient
                  ? AppColors.primaryBlue
                  : AppColors.warningOrange,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: hasPatient
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient', style: AppTextStyles.cardSubtitle),
                      const SizedBox(height: 4),
                      Text(
                        patientName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currentPatient!.anonymousId} · Né(e) le ${currentPatient!.dateNaissance}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardSubtitle,
                      ),
                    ],
                  )
                : Text(
                    'Aucun patient actif. Sélectionnez ou créez un patient dans l’onglet Patient.',
                    style: TextStyle(
                      color: AppColors.warningOrange,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
          ),
          IconButton(
            onPressed: loadInitialData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget buildPractitionerCard() {
    final complete = practitioner.isComplete;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: complete ? AppColors.card : AppColors.softOrange,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: complete ? AppColors.border : const Color(0xFFFED7AA),
        ),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: complete ? AppColors.softBlue : AppColors.softOrange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              complete ? Icons.badge_rounded : Icons.edit_note_rounded,
              color: complete ? AppColors.primaryBlue : AppColors.warningOrange,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: complete
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Professionnel', style: AppTextStyles.cardSubtitle),
                      const SizedBox(height: 4),
                      Text(
                        practitioner.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (practitioner.adeli.trim().isNotEmpty)
                            'ADELI ${practitioner.adeli.trim()}',
                          if (practitioner.rpps.trim().isNotEmpty)
                            'RPPS ${practitioner.rpps.trim()}',
                        ].join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardSubtitle,
                      ),
                    ],
                  )
                : Text(
                    'Renseignez une seule fois vos informations professionnelles pour les PDF.',
                    style: TextStyle(
                      color: AppColors.warningOrange,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
          ),
          IconButton(
            onPressed: showPractitionerDialog,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Modifier',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget buildAccessDirectPrescriptionCard() {
    final hasImage = justificatifImage != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.softShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryBlue,
            ),
          ),
          title: Text(
            'Accès direct & cadre réglementaire',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
          ),
          subtitle: Text(
            'Conditions d’exercice, diagnostic préalable, justificatif.',
            style: AppTextStyles.cardSubtitle,
          ),
          children: [
            const _MiniRegulatoryLine(
              icon: Icons.groups_rounded,
              title: 'Exercice coordonné',
              subtitle:
                  'MSP, CPTS ou structure coordonnée selon le cadre applicable.',
            ),
            const SizedBox(height: 10),
            const _MiniRegulatoryLine(
              icon: Icons.medical_information_outlined,
              title: 'Diagnostic médical préalable',
              subtitle: 'Si diagnostic déjà posé : justificatif recommandé.',
            ),
            const SizedBox(height: 18),
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
                      ? AppColors.successGreen
                      : AppColors.primaryBlue,
                  backgroundColor: hasImage
                      ? AppColors.softGreen
                      : AppColors.softBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  justificatifImage!,
                  height: 180,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complétez les champs utiles au PDF de prescription.',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          ClinicalTextField(
            label: 'Pathologie / motif',
            hint:
                'Exemple : lombalgie aiguë, entorse de cheville, rééducation respiratoire...',
            maxLines: 3,
            controller: pathologieController,
          ),
          const SizedBox(height: 16),
          ClinicalTextField(
            label: 'Objectifs de rééducation',
            hint:
                'Exemple : diminution de la douleur, récupération fonctionnelle...',
            maxLines: 3,
            controller: reeducationObjectifsController,
          ),
          const SizedBox(height: 16),
          ClinicalTextField(
            label: 'Fréquence / durée',
            hint: 'Exemple : 2 séances par semaine pendant 6 semaines...',
            maxLines: 2,
            controller: reeducationFrequenceController,
          ),
        ];

      case 'Matériel':
        return [
          ClinicalTextField(
            label: 'Matériel demandé',
            hint:
                'Exemple : attelle de cheville, cannes anglaises, bas de contention...',
            maxLines: 3,
            controller: materielController,
          ),
          const SizedBox(height: 16),
          ClinicalTextField(
            label: 'Justification clinique',
            hint: 'Exemple : instabilité, douleur, limitation d’appui...',
            maxLines: 3,
            controller: materielJustificationController,
          ),
        ];

      case 'Examens':
        return [
          ClinicalTextField(
            label: 'Examen / avis demandé',
            hint:
                'Exemple : avis médical, imagerie à envisager, doppler si suspicion TVP...',
            maxLines: 3,
            controller: examensController,
          ),
          const SizedBox(height: 16),
          ClinicalTextField(
            label: 'Motif clinique',
            hint: 'Exemple : douleur persistante, suspicion de complication...',
            maxLines: 3,
            controller: examensMotifController,
          ),
        ];

      case 'Conseils':
        return [
          ClinicalTextField(
            label: 'Conseils au patient',
            hint: 'Exemple : glaçage, compression, auto-exercices...',
            maxLines: 3,
            controller: conseilsController,
          ),
          const SizedBox(height: 16),
          ClinicalTextField(
            label: 'Points de surveillance',
            hint:
                'Exemple : aggravation douleur, fièvre, déficit neurologique...',
            maxLines: 3,
            controller: conseilsSurveillanceController,
          ),
        ];

      case 'Autres':
      default:
        return [
          ClinicalTextField(
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
        margin: const EdgeInsets.only(top: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aucun modèle rapide pour ce type. Renseignez librement le contenu.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.library_books_outlined,
                  color: AppColors.primaryBlue,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modèles rapides',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ajoutent du texte dans le champ principal.',
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: templates.map((template) {
            return ActionChip(
              label: Text(template),
              backgroundColor: AppColors.background,
              side: BorderSide(color: AppColors.border),
              labelStyle: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
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
        Icon(icon, color: AppColors.primaryBlue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.cardSubtitle),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
