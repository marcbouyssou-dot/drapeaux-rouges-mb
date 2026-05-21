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
import '../widgets/design_system/clinical_page_header.dart';
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

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Informations professionnelles'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildDialogField(controller: nomController, label: 'Nom'),
                const SizedBox(height: 10),
                buildDialogField(controller: prenomController, label: 'Prénom'),
                const SizedBox(height: 10),
                buildDialogField(
                  controller: adresseController,
                  label: 'Adresse professionnelle',
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                buildDialogField(controller: adeliController, label: 'ADELI'),
                const SizedBox(height: 10),
                buildDialogField(controller: rppsController, label: 'RPPS'),
              ],
            ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          ClinicalPageHeader(
            title: selectedPrescriptionType,
            subtitle: 'Prescription clinique et document thérapeutique.',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                120,
              ),
              children: [
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
        ],
      ),
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
              color:
                  hasPatient ? AppColors.primaryBlue : AppColors.warningOrange,
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
                      Text(patientName, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        'Né(e) le ${currentPatient!.dateNaissance}',
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
              color:
                  complete ? AppColors.primaryBlue : AppColors.warningOrange,
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
                  foregroundColor:
                      hasImage ? AppColors.successGreen : AppColors.primaryBlue,
                  backgroundColor:
                      hasImage ? AppColors.softGreen : AppColors.softBlue,
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
          Text(activeTitle, style: AppTextStyles.sectionTitle),
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
            hint: 'Exemple : diminution de la douleur, récupération fonctionnelle...',
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
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          'Modèles rapides',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
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

                activeController.text =
                    currentText.isEmpty ? template : '$currentText\n• $template';

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
              Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.cardSubtitle),
            ],
          ),
        ),
      ],
    );
  }
}