import 'package:flutter/material.dart';

import '../data/prescription_templates_data.dart';
import '../models/patient_local.dart';
import '../models/practitioner_profile.dart';
import '../services/practitioner_profile_service.dart';
import '../services/prescription_pdf_service.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/urps_banner.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  String selectedPrescriptionType = 'Rééducation';

  final pathologieController = TextEditingController();
  final materielController = TextEditingController();
  final examensController = TextEditingController();
  final conseilsController = TextEditingController();
  final autresController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  File? justificatifImage;    

  PatientLocal? currentPatient;
  PractitionerProfile practitioner = PractitionerProfile.empty();

  final List<String> prescriptionTypes = const [
    'Rééducation',
    'Matériel',
    'Examens',
    'Conseils',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void dispose() {
    pathologieController.dispose();
    materielController.dispose();
    examensController.dispose();
    conseilsController.dispose();
    autresController.dispose();
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

    setState(() {
      selectedPrescriptionType = 'Rééducation';
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
        return 'Matériel / dispositifs médicaux';
      case 'Examens':
        return 'Examens à envisager / orientation';
      case 'Conseils':
        return 'Conseils associés';
      case 'Autres':
        return 'Autres prescriptions ou recommandations';
      case 'Rééducation':
      default:
        return 'Rééducation pour';
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
        return 'Exemple : crème, gel froid, pansement, autre recommandation...';
      case 'Rééducation':
      default:
        return 'Exemple : lombalgie aiguë, entorse de cheville, rééducation respiratoire...';
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

    if (activeController.text.trim().isEmpty) {
      showMessage('Merci de renseigner le contenu de la prescription.');
      return;
    }

    await PrescriptionPdfService.exportPrescriptionPdf(
  patient: currentPatient!,
  practitioner: practitioner,
  prescriptionType: selectedPrescriptionType,
  prescriptionContent: activeController.text.trim(),
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
        fillColor: const Color(0xFFF8FAFC),
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
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
          children: [
            const UrpsBanner(isLarge: false),
            buildPatientCard(),
            const SizedBox(height: 14),
            buildPractitionerCard(),
            const SizedBox(height: 14),
            buildAccessDirectPrescriptionCard(),
            const SizedBox(height: 14),
            buildPrescriptionTypeCard(),
            const SizedBox(height: 14),
            buildPrescriptionCard(),
            const SizedBox(height: 14),
            buildRegulatoryInfoCard(),
            const SizedBox(height: 14),
            buildPrintInfoCard(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildPatientCard() {
    final hasPatient = currentPatient != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasPatient ? Colors.white : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasPatient ? const Color(0xFFE2E8F0) : const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: hasPatient
                  ? const Color(0xFFEAF2FF)
                  : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              hasPatient ? Icons.person_rounded : Icons.warning_amber_rounded,
              color: hasPatient
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFC2410C),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: hasPatient
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patientName,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Né(e) le ${currentPatient!.dateNaissance}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Aucun patient actif. Sélectionnez ou créez un patient dans l’onglet Patient.',
                    style: TextStyle(
                      color: Color(0xFFC2410C),
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
        color: complete ? Colors.white : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: complete ? const Color(0xFFE2E8F0) : const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color:
                  complete ? const Color(0xFFEAF2FF) : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              complete ? Icons.badge_rounded : Icons.edit_note_rounded,
              color:
                  complete ? const Color(0xFF2563EB) : const Color(0xFFC2410C),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: complete
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Professionnel',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        practitioner.fullName,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (practitioner.adeli.trim().isNotEmpty)
                            'ADELI ${practitioner.adeli.trim()}',
                          if (practitioner.rpps.trim().isNotEmpty)
                            'RPPS ${practitioner.rpps.trim()}',
                        ].join(' • '),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Renseignez une seule fois vos informations professionnelles pour les PDF.',
                    style: TextStyle(
                      color: Color(0xFFC2410C),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF2563EB),
          ),
        ),
        title: const Text(
          'Accès direct & cadre réglementaire',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: const Text(
          'Conditions d’exercice, diagnostic préalable, justificatif.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
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
                    ? const Color(0xFF15803D)
                    : const Color(0xFF2563EB),
                side: BorderSide(
                  color: hasImage
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFBFDBFE),
                ),
                backgroundColor: hasImage
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFEFF6FF),
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

  Widget buildPrescriptionTypeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type de document',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: prescriptionTypes.map((type) {
              final selected = selectedPrescriptionType == type;

              return ChoiceChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    selectedPrescriptionType = type;
                  });
                },
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF334155),
                  fontWeight: FontWeight.w900,
                ),
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFF8FAFC),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildPrescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF2563EB),
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  activeTitle,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: activeController,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: activeHint,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 2,
                ),
              ),
            ),
          ),
          buildTemplatesSection(),
        ],
      ),
    );
  }

  Widget buildTemplatesSection() {
    final templates = prescriptionTemplates[selectedPrescriptionType] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text(
          'Modèles rapides',
          style: TextStyle(
            color: Color(0xFF64748B),
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
              backgroundColor: const Color(0xFFF8FAFC),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              labelStyle: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
              onPressed: () {
  final currentText = activeController.text.trim();

  if (currentText.isEmpty) {
    activeController.text = template;
  } else {
    activeController.text =
        '$currentText\n• $template';
  }

  activeController.selection =
      TextSelection.fromPosition(
    TextPosition(
      offset: activeController.text.length,
    ),
  );

  setState(() {});
},
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildRegulatoryInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.gavel_rounded,
            color: Color(0xFFD97706),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Les prescriptions et recommandations doivent rester conformes aux compétences, droits de prescription et conditions réglementaires du masseur-kinésithérapeute.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPrintInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.print_outlined,
            color: Color(0xFF64748B),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'PDF sobre, lisible et économique à imprimer.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: resetForm,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réinitialiser'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: exportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Exporter PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRegulatoryLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MiniRegulatoryLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}