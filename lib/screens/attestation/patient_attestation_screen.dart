import 'package:flutter/material.dart';

import '../../models/attestation/attestation_template.dart';
import '../../models/attestation/patient_attestation.dart';
import '../../models/patient_local.dart';
import '../../models/practitioner_profile.dart';
import '../../services/patient_attestation_pdf_service.dart';
import '../../services/practitioner_profile_service.dart';
import '../../services/rgpd_local_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/design_system/clinical_bottom_action_bar.dart';

class PatientAttestationScreen extends StatefulWidget {
  const PatientAttestationScreen({super.key, required this.template});

  final AttestationTemplate template;

  @override
  State<PatientAttestationScreen> createState() =>
      _PatientAttestationScreenState();
}

class _PatientAttestationScreenState extends State<PatientAttestationScreen> {
  final lieuController = TextEditingController();

  PatientLocal? patient;
  PractitionerProfile practitioner = PractitionerProfile.empty();
  DateTime date = DateTime.now();
  bool loading = true;
  bool exporting = false;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void dispose() {
    lieuController.dispose();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    final loadedPatient = await RgpdLocalService.getCurrentPatient();
    final loadedPractitioner = await PractitionerProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      patient = loadedPatient;
      practitioner = loadedPractitioner;
      loading = false;
    });
  }

  PatientAttestation buildAttestation() {
    return PatientAttestation(
      template: widget.template,
      patient: patient,
      practitioner: practitioner,
      date: date,
      lieu: lieuController.text.trim(),
    );
  }

  Future<void> exportPdf() async {
    setState(() {
      exporting = true;
    });

    try {
      await PatientAttestationPdfService.exportPdf(buildAttestation());
      showMessage('Attestation PDF générée.');
    } finally {
      if (mounted) {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: ClinicalBottomActionBar(
        secondaryLabel: 'Retour',
        secondaryIcon: Icons.arrow_back_rounded,
        onSecondaryPressed: () => Navigator.pop(context),
        primaryLabel: exporting ? 'Génération...' : 'Générer le PDF',
        primaryIcon: Icons.picture_as_pdf_outlined,
        onPrimaryPressed: () {
          if (!exporting) {
            exportPdf();
          }
        },
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 12 : AppSpacing.md,
                      AppSpacing.sm,
                      compact ? 12 : AppSpacing.md,
                      112,
                    ),
                    children: [
                      _HeaderCard(template: widget.template),
                      const SizedBox(height: AppSpacing.sm),
                      _ContextCard(
                        title: 'Patient utilisé',
                        icon: Icons.person_outline_rounded,
                        color: AppColors.primary,
                        lines: [
                          _patientName,
                          'Naissance : ${_patientBirthDate.isEmpty ? 'Non renseignée' : _patientBirthDate}',
                          _signatureStatus,
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ContextCard(
                        title: 'Praticien utilisé',
                        icon: Icons.badge_outlined,
                        color: AppColors.teal,
                        lines: [
                          practitioner.professionLabel,
                          practitioner.fullName.isEmpty
                              ? 'Nom non renseigné'
                              : practitioner.fullName,
                          if (practitioner.adresse.trim().isNotEmpty)
                            practitioner.adresse.trim(),
                          if (_practitionerIdentifier.isNotEmpty)
                            _practitionerIdentifier,
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DatePlaceCard(
                        date: _formattedDate,
                        controller: lieuController,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _PreviewCard(attestation: buildAttestation()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String get _patientName {
    final nom = patient?.nom.trim().toUpperCase() ?? '';
    final prenom = patient?.prenom.trim() ?? '';
    final value = '$nom $prenom'.trim();

    return value.isEmpty ? 'Patient non identifié' : value;
  }

  String get _patientBirthDate => patient?.dateNaissance.trim() ?? '';

  String get _signatureStatus {
    final hasSignature = patient?.signatureBase64?.trim().isNotEmpty == true;
    return hasSignature ? 'Signature patient disponible' : 'Signature absente';
  }

  String get _practitionerIdentifier {
    final rpps = practitioner.rpps.trim();
    final adeli = practitioner.adeli.trim();

    if (rpps.isNotEmpty && adeli.isNotEmpty) {
      return 'RPPS : $rpps · ADELI : $adeli';
    }
    if (rpps.isNotEmpty) return 'RPPS : $rpps';
    if (adeli.isNotEmpty) return 'ADELI : $adeli';

    return '';
  }

  String get _formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.template});

  final AttestationTemplate template;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'Retour',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceBlue,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template.statusLabel,
                  style: TextStyle(
                    color: template.isActive
                        ? AppColors.successDark
                        : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                ...lines
                    .where((line) => line.trim().isNotEmpty)
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          line,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePlaceCard extends StatelessWidget {
  const _DatePlaceCard({required this.date, required this.controller});

  final String date;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lieu et date',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Ville',
              hintText: 'Ex : Bordeaux',
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Date : $date',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.attestation});

  final PatientAttestation attestation;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attestation.template.pdfTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...attestation.bodyParagraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                paragraph,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
