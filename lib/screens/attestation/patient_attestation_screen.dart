import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../models/attestation/attestation_template.dart';
import '../../models/attestation/attestation_history_item.dart';
import '../../models/attestation/attestation_type.dart';
import '../../models/attestation/patient_attestation.dart';
import '../../models/patient_local.dart';
import '../../models/practitioner_profile.dart';
import '../../services/attestation_history_service.dart';
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
  final patientNomController = TextEditingController();
  final patientPrenomController = TextEditingController();
  final patientBirthDateController = TextEditingController();
  final patientAddressController = TextEditingController();
  final patientPostalCodeController = TextEditingController();
  final patientCityController = TextEditingController();
  final practitionerNomController = TextEditingController();
  final practitionerPrenomController = TextEditingController();
  final practitionerIdentifierController = TextEditingController();
  final practitionerAddressController = TextEditingController();
  final distanceController = TextEditingController();
  final prescriberController = TextEditingController();
  final prescriptionDateController = TextEditingController();
  final cabinetNameControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final cabinetCityControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final cabinetDateControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final cabinetOtherControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  PatientLocal? patient;
  PractitionerProfile practitioner = PractitionerProfile.empty();
  DateTime date = DateTime.now();
  bool loading = true;
  bool exporting = false;
  bool consentConfirmed = false;
  bool transmissionAuthorized = false;
  bool isSigning = false;
  String? patientSignatureBase64;
  final List<ContactedCabinetReason?> cabinetReasons = List.filled(3, null);

  bool get isProximityAttestation {
    return widget.template.type == AttestationType.nearestAvailableMk;
  }

  @override
  void initState() {
    super.initState();
    for (final controller in _proximityControllers) {
      controller.addListener(_refreshPreview);
    }
    loadInitialData();
  }

  List<TextEditingController> get _proximityControllers {
    return [
      patientNomController,
      patientPrenomController,
      patientBirthDateController,
      patientAddressController,
      patientPostalCodeController,
      patientCityController,
      practitionerNomController,
      practitionerPrenomController,
      practitionerIdentifierController,
      practitionerAddressController,
      distanceController,
      prescriberController,
      prescriptionDateController,
      ...cabinetNameControllers,
      ...cabinetCityControllers,
      ...cabinetDateControllers,
      ...cabinetOtherControllers,
    ];
  }

  void _refreshPreview() {
    if (!mounted || loading) return;
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _proximityControllers) {
      controller.removeListener(_refreshPreview);
    }
    lieuController.dispose();
    patientNomController.dispose();
    patientPrenomController.dispose();
    patientBirthDateController.dispose();
    patientAddressController.dispose();
    patientPostalCodeController.dispose();
    patientCityController.dispose();
    practitionerNomController.dispose();
    practitionerPrenomController.dispose();
    practitionerIdentifierController.dispose();
    practitionerAddressController.dispose();
    distanceController.dispose();
    prescriberController.dispose();
    prescriptionDateController.dispose();
    for (final controller in [
      ...cabinetNameControllers,
      ...cabinetCityControllers,
      ...cabinetDateControllers,
      ...cabinetOtherControllers,
    ]) {
      controller.dispose();
    }
    signatureController.dispose();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    final loadedPatient = await RgpdLocalService.getCurrentPatient();
    final loadedPractitioner = await PractitionerProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      patient = loadedPatient;
      practitioner = loadedPractitioner;
      patientNomController.text = loadedPatient?.nom.trim() ?? '';
      patientPrenomController.text = loadedPatient?.prenom.trim() ?? '';
      patientBirthDateController.text =
          loadedPatient?.dateNaissance.trim() ?? '';
      patientAddressController.text = loadedPatient?.adresse.trim() ?? '';
      patientPostalCodeController.text = loadedPatient?.codePostal.trim() ?? '';
      patientCityController.text = loadedPatient?.ville.trim() ?? '';
      practitionerNomController.text = loadedPractitioner.nom.trim();
      practitionerPrenomController.text = loadedPractitioner.prenom.trim();
      practitionerIdentifierController.text = _identifierFromProfile(
        loadedPractitioner,
      );
      practitionerAddressController.text = loadedPractitioner.adresse.trim();
      prescriberController.text = loadedPatient?.medecinNom.trim() ?? '';
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
      consentConfirmed: consentConfirmed,
      transmissionAuthorized: transmissionAuthorized,
      patientSignatureBase64: patientSignatureBase64,
      patientNom: patientNomController.text.trim(),
      patientPrenom: patientPrenomController.text.trim(),
      patientDateNaissance: patientBirthDateController.text.trim(),
      patientAdresse: patientAddressController.text.trim(),
      patientCodePostal: patientPostalCodeController.text.trim(),
      patientVille: patientCityController.text.trim(),
      practitionerNom: practitionerNomController.text.trim(),
      practitionerPrenom: practitionerPrenomController.text.trim(),
      practitionerIdentifierOverride: practitionerIdentifierController.text
          .trim(),
      practitionerAddressOverride: practitionerAddressController.text.trim(),
      distanceHomeOffice: distanceController.text.trim(),
      prescriberName: prescriberController.text.trim(),
      prescriptionDate: prescriptionDateController.text.trim(),
      contactedCabinets: List.generate(
        3,
        (index) => ContactedCabinet(
          name: cabinetNameControllers[index].text.trim(),
          city: cabinetCityControllers[index].text.trim(),
          contactDate: cabinetDateControllers[index].text.trim(),
          reason: cabinetReasons[index],
          otherReason: cabinetOtherControllers[index].text.trim(),
        ),
      ),
    );
  }

  Future<void> exportPdf() async {
    if (isProximityAttestation && !_validateProximityForm()) {
      return;
    }

    if (!consentConfirmed) {
      showMessage(
        'Merci de confirmer l’information et l’accord du patient avant génération.',
      );
      return;
    }

    if (signatureController.isEmpty) {
      showMessage('Merci de faire signer le patient avant génération.');
      return;
    }

    setState(() {
      exporting = true;
    });

    try {
      final Uint8List? signatureBytes = await signatureController.toPngBytes();
      if (signatureBytes == null) {
        showMessage('Erreur lors de la préparation de la signature patient.');
        return;
      }

      patientSignatureBase64 = base64Encode(signatureBytes);
      final attestation = buildAttestation();
      await PatientAttestationPdfService.exportPdf(attestation);
      await AttestationHistoryService.saveAttestation(
        AttestationHistoryItem.fromAttestation(attestation),
      );
      showMessage('Attestation PDF générée et enregistrée.');
    } finally {
      if (mounted) {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  bool _validateProximityForm() {
    if (patientNomController.text.trim().isEmpty ||
        patientPrenomController.text.trim().isEmpty ||
        patientBirthDateController.text.trim().isEmpty) {
      showMessage('Merci de renseigner l’identité du patient.');
      return false;
    }

    if (practitionerNomController.text.trim().isEmpty ||
        practitionerPrenomController.text.trim().isEmpty) {
      showMessage('Merci de renseigner l’identité du MK.');
      return false;
    }

    if (lieuController.text.trim().isEmpty) {
      showMessage('Merci de renseigner le lieu de signature.');
      return false;
    }

    return true;
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
        secondaryIcon: Icons.arrow_back_ios_new_rounded,
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
                    physics: isSigning
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      compact ? 12 : AppSpacing.md,
                      AppSpacing.sm,
                      compact ? 12 : AppSpacing.md,
                      112,
                    ),
                    children: [
                      _HeaderCard(template: widget.template),
                      const SizedBox(height: AppSpacing.sm),
                      if (isProximityAttestation)
                        _ProximityForm(
                          patientNomController: patientNomController,
                          patientPrenomController: patientPrenomController,
                          patientBirthDateController:
                              patientBirthDateController,
                          patientAddressController: patientAddressController,
                          patientPostalCodeController:
                              patientPostalCodeController,
                          patientCityController: patientCityController,
                          practitionerNomController: practitionerNomController,
                          practitionerPrenomController:
                              practitionerPrenomController,
                          practitionerIdentifierController:
                              practitionerIdentifierController,
                          practitionerAddressController:
                              practitionerAddressController,
                          distanceController: distanceController,
                          prescriberController: prescriberController,
                          prescriptionDateController:
                              prescriptionDateController,
                          cabinetNameControllers: cabinetNameControllers,
                          cabinetCityControllers: cabinetCityControllers,
                          cabinetDateControllers: cabinetDateControllers,
                          cabinetOtherControllers: cabinetOtherControllers,
                          cabinetReasons: cabinetReasons,
                          onChanged: () => setState(() {}),
                        )
                      else ...[
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
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      _DatePlaceCard(
                        date: _formattedDate,
                        controller: lieuController,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ConsentSignatureCard(
                        consentConfirmed: consentConfirmed,
                        transmissionAuthorized: transmissionAuthorized,
                        showTransmissionConsent: isProximityAttestation,
                        signatureController: signatureController,
                        onConsentChanged: (value) {
                          setState(() {
                            consentConfirmed = value;
                          });
                        },
                        onTransmissionChanged: (value) {
                          setState(() {
                            transmissionAuthorized = value;
                          });
                        },
                        onClearSignature: () {
                          signatureController.clear();
                          setState(() {
                            patientSignatureBase64 = null;
                          });
                        },
                        onSigningChanged: (value) {
                          setState(() {
                            isSigning = value;
                          });
                        },
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

  String _identifierFromProfile(PractitionerProfile profile) {
    final rpps = profile.rpps.trim();
    final adeli = profile.adeli.trim();

    if (rpps.isNotEmpty && adeli.isNotEmpty) {
      return 'RPPS : $rpps · ADELI : $adeli';
    }
    if (rpps.isNotEmpty) return 'RPPS : $rpps';
    if (adeli.isNotEmpty) return 'ADELI : $adeli';

    return '';
  }

  String get _signatureStatus {
    final hasSignature =
        patientSignatureBase64?.trim().isNotEmpty == true ||
        signatureController.isNotEmpty ||
        patient?.signatureBase64?.trim().isNotEmpty == true;
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
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

class _ProximityForm extends StatelessWidget {
  const _ProximityForm({
    required this.patientNomController,
    required this.patientPrenomController,
    required this.patientBirthDateController,
    required this.patientAddressController,
    required this.patientPostalCodeController,
    required this.patientCityController,
    required this.practitionerNomController,
    required this.practitionerPrenomController,
    required this.practitionerIdentifierController,
    required this.practitionerAddressController,
    required this.distanceController,
    required this.prescriberController,
    required this.prescriptionDateController,
    required this.cabinetNameControllers,
    required this.cabinetCityControllers,
    required this.cabinetDateControllers,
    required this.cabinetOtherControllers,
    required this.cabinetReasons,
    required this.onChanged,
  });

  final TextEditingController patientNomController;
  final TextEditingController patientPrenomController;
  final TextEditingController patientBirthDateController;
  final TextEditingController patientAddressController;
  final TextEditingController patientPostalCodeController;
  final TextEditingController patientCityController;
  final TextEditingController practitionerNomController;
  final TextEditingController practitionerPrenomController;
  final TextEditingController practitionerIdentifierController;
  final TextEditingController practitionerAddressController;
  final TextEditingController distanceController;
  final TextEditingController prescriberController;
  final TextEditingController prescriptionDateController;
  final List<TextEditingController> cabinetNameControllers;
  final List<TextEditingController> cabinetCityControllers;
  final List<TextEditingController> cabinetDateControllers;
  final List<TextEditingController> cabinetOtherControllers;
  final List<ContactedCabinetReason?> cabinetReasons;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FormSectionCard(
          title: 'Patient',
          children: [
            _FormField(controller: patientNomController, label: 'Nom'),
            _FormField(controller: patientPrenomController, label: 'Prénom'),
            _FormField(
              controller: patientBirthDateController,
              label: 'Date de naissance',
            ),
            _FormField(controller: patientAddressController, label: 'Adresse'),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    controller: patientPostalCodeController,
                    label: 'Code postal',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _FormField(
                    controller: patientCityController,
                    label: 'Ville',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _FormSectionCard(
          title: 'Masseur-kinésithérapeute',
          children: [
            _FormField(controller: practitionerNomController, label: 'Nom'),
            _FormField(
              controller: practitionerPrenomController,
              label: 'Prénom',
            ),
            _FormField(
              controller: practitionerIdentifierController,
              label: 'RPPS ou ADELI',
            ),
            _FormField(
              controller: practitionerAddressController,
              label: 'Adresse cabinet',
            ),
            _FormField(
              controller: distanceController,
              label: 'Distance domicile / cabinet',
              hint: 'Ex : 3,5 km',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _FormSectionCard(
          title: 'Prescription',
          children: [
            _FormField(
              controller: prescriberController,
              label: 'Médecin prescripteur',
            ),
            _FormField(
              controller: prescriptionDateController,
              label: 'Date ordonnance',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _FormSectionCard(
          title: 'Cabinets contactés',
          children: List.generate(
            3,
            (index) => _CabinetFields(
              index: index,
              nameController: cabinetNameControllers[index],
              cityController: cabinetCityControllers[index],
              dateController: cabinetDateControllers[index],
              otherController: cabinetOtherControllers[index],
              reason: cabinetReasons[index],
              onReasonChanged: (reason) {
                cabinetReasons[index] = reason;
                onChanged();
              },
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
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
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        onChanged: (_) => onChanged?.call(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

class _CabinetFields extends StatelessWidget {
  const _CabinetFields({
    required this.index,
    required this.nameController,
    required this.cityController,
    required this.dateController,
    required this.otherController,
    required this.reason,
    required this.onReasonChanged,
    required this.onChanged,
  });

  final int index;
  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController dateController;
  final TextEditingController otherController;
  final ContactedCabinetReason? reason;
  final ValueChanged<ContactedCabinetReason?> onReasonChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: index == 2 ? 0 : AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cabinet ${index + 1}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FormField(
            controller: nameController,
            label: 'Nom du cabinet',
            onChanged: onChanged,
          ),
          _FormField(
            controller: cityController,
            label: 'Ville',
            onChanged: onChanged,
          ),
          _FormField(
            controller: dateController,
            label: 'Date contact',
            onChanged: onChanged,
          ),
          DropdownButtonFormField<ContactedCabinetReason>(
            initialValue: reason,
            items: ContactedCabinetReason.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.label)),
                )
                .toList(),
            onChanged: onReasonChanged,
            decoration: InputDecoration(
              labelText: 'Motif',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          if (reason == ContactedCabinetReason.other) ...[
            const SizedBox(height: AppSpacing.sm),
            _FormField(
              controller: otherController,
              label: 'Précision autre motif',
              onChanged: onChanged,
            ),
          ],
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

class _ConsentSignatureCard extends StatelessWidget {
  const _ConsentSignatureCard({
    required this.consentConfirmed,
    required this.transmissionAuthorized,
    required this.showTransmissionConsent,
    required this.signatureController,
    required this.onConsentChanged,
    required this.onTransmissionChanged,
    required this.onClearSignature,
    required this.onSigningChanged,
  });

  final bool consentConfirmed;
  final bool transmissionAuthorized;
  final bool showTransmissionConsent;
  final SignatureController signatureController;
  final ValueChanged<bool> onConsentChanged;
  final ValueChanged<bool> onTransmissionChanged;
  final VoidCallback onClearSignature;
  final ValueChanged<bool> onSigningChanged;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consentement et signature',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: consentConfirmed
                  ? AppColors.surfaceSuccess
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: consentConfirmed ? AppColors.success : AppColors.border,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: consentConfirmed,
                onChanged: (value) => onConsentChanged(value ?? false),
                activeColor: AppColors.success,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                title: const Text(
                  'Le patient confirme avoir reçu l’information, l’avoir comprise et accepte de signer cette attestation.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          if (showTransmissionConsent) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: transmissionAuthorized
                    ? AppColors.surfaceBlue
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: transmissionAuthorized
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.border,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  value: transmissionAuthorized,
                  onChanged: (value) => onTransmissionChanged(value ?? false),
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  title: const Text(
                    'J’autorise la transmission au service médical.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Listener(
            onPointerDown: (_) => onSigningChanged(true),
            onPointerUp: (_) => onSigningChanged(false),
            onPointerCancel: (_) => onSigningChanged(false),
            child: Container(
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Stack(
                  children: [
                    Signature(
                      controller: signatureController,
                      backgroundColor: Colors.white,
                    ),
                    const Center(
                      child: IgnorePointer(
                        child: Text(
                          'Signature patient',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              onPressed: onClearSignature,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: const Text('Effacer', textAlign: TextAlign.center),
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
