import 'package:flutter/material.dart';

import '../models/patient_local.dart';
import '../models/practitioner_profile.dart';
import '../services/practitioner_profile_service.dart';
import '../services/prescription_pdf_service.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/urps_banner.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final pathologieController = TextEditingController();

  PatientLocal? currentPatient;
  PractitionerProfile practitioner = PractitionerProfile.empty();

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void dispose() {
    pathologieController.dispose();
    super.dispose();
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription réinitialisée'),
      ),
    );
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

    if (pathologieController.text.trim().isEmpty) {
      showMessage('Merci de renseigner la pathologie.');
      return;
    }

    await PrescriptionPdfService.exportPrescriptionPdf(
      patient: currentPatient!,
      practitioner: practitioner,
      pathologie: pathologieController.text.trim(),
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
              buildDialogField(
                controller: nomController,
                label: 'Nom',
              ),
              const SizedBox(height: 10),
              buildDialogField(
                controller: prenomController,
                label: 'Prénom',
              ),
              const SizedBox(height: 10),
              buildDialogField(
                controller: adresseController,
                label: 'Adresse professionnelle',
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              buildDialogField(
                controller: adeliController,
                label: 'ADELI',
              ),
              const SizedBox(height: 10),
              buildDialogField(
                controller: rppsController,
                label: 'RPPS',
              ),
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
            buildTitle(),
            const SizedBox(height: 22),
            buildPatientCard(),
            const SizedBox(height: 18),
            buildPractitionerCard(),
            const SizedBox(height: 18),
            buildPrescriptionCard(),
            const SizedBox(height: 18),
            buildPrintInfoCard(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prescription',
          style: AppTextStyles.pageTitle,
        ),
        SizedBox(height: 4),
        Text(
          'Prescription sobre et imprimable',
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }

  Widget buildPatientCard() {
    final hasPatient = currentPatient != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasPatient ? Colors.white : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: hasPatient ? const Color(0xFFE2E8F0) : const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: complete ? Colors.white : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: complete ? const Color(0xFFE2E8F0) : const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
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

  Widget buildPrescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Rééducation pour',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: pathologieController,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Exemple : lombalgie aiguë',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
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
        ],
      ),
    );
  }

  Widget buildPrintInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
              'Le PDF généré est volontairement sobre pour faciliter l’impression et limiter l’usage d’encre.',
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE5E7EB),
            ),
          ),
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