import 'package:flutter/material.dart';

import '../models/patient_local.dart';
import '../services/prescription_pdf_service.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final diagnosticController = TextEditingController();
  final prescriptionController = TextEditingController();
  final observationsController = TextEditingController();

  PatientLocal? currentPatient;

  @override
  void initState() {
    super.initState();
    loadCurrentPatient();
  }

  @override
  void dispose() {
    diagnosticController.dispose();
    prescriptionController.dispose();
    observationsController.dispose();
    super.dispose();
  }

  Future<void> loadCurrentPatient() async {
    final patient = await RgpdLocalService.getCurrentPatient();

    if (!mounted) return;

    setState(() {
      currentPatient = patient;
    });
  }

  void resetForm() {
    diagnosticController.clear();
    prescriptionController.clear();
    observationsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription réinitialisée'),
      ),
    );
  }

  Future<void> exportPdf() async {
    if (currentPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucun patient actif. Sélectionnez un patient avant export.',
          ),
        ),
      );
      return;
    }

    await PrescriptionPdfService.exportPrescriptionPdf(
      patient: currentPatient!,
      diagnostic: diagnosticController.text,
      prescription: prescriptionController.text,
      observations: observationsController.text,
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
            const AppHeader(compact: true),
            const SizedBox(height: 20),
            buildTitle(),
            const SizedBox(height: 22),
            buildPatientCard(),
            const SizedBox(height: 20),
            buildHeroCard(),
            const SizedBox(height: 20),
            buildSectionCard(
              title: 'Motif / Diagnostic',
              subtitle: 'Motif clinique principal',
              icon: Icons.medical_information_outlined,
              child: buildTextField(
                controller: diagnosticController,
                label: 'Exemple : Lombalgie aiguë',
                maxLines: 3,
              ),
            ),
            buildSectionCard(
              title: 'Prescription',
              subtitle: 'Contenu de la rééducation',
              icon: Icons.description_outlined,
              child: buildTextField(
                controller: prescriptionController,
                label: 'Contenu de la prescription de rééducation',
                maxLines: 7,
              ),
            ),
            buildSectionCard(
              title: 'Observations',
              subtitle: 'Notes complémentaires',
              icon: Icons.edit_note_rounded,
              child: buildTextField(
                controller: observationsController,
                label: 'Observations complémentaires',
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 18),
            buildInfoCard(),
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
          'Prescription de rééducation accès direct',
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
                        'Patient actif',
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
            onPressed: loadCurrentPatient,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser le patient actif',
          ),
        ],
      ),
    );
  }

  Widget buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document clinique',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Prescription de rééducation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
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
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF2FF),
            Color(0xFFF0F9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
            size: 26,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Cette prescription constitue une aide documentaire dans le cadre de l’accès direct en masso-kinésithérapie.',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                height: 1.5,
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