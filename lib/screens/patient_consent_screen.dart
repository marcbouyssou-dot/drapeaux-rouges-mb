import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../models/access_direct_model.dart';
import '../models/patient_local.dart';
import '../services/access_direct_local_service.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PatientConsentScreen extends StatefulWidget {
  const PatientConsentScreen({super.key});

  @override
  State<PatientConsentScreen> createState() => _PatientConsentScreenState();
}

class _PatientConsentScreenState extends State<PatientConsentScreen> {
  final searchController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final dateNaissanceController = TextEditingController();
  final adresseController = TextEditingController();
  final codePostalController = TextEditingController();
  final villeController = TextEditingController();
  final telephoneController = TextEditingController();
  final emailController = TextEditingController();
  final professionController = TextEditingController();
  final personnePrevenirController = TextEditingController();
  final telephoneContactController = TextEditingController();
  final medecinNomController = TextEditingController();
  final medecinRppsController = TextEditingController();
  final medecinAdeliController = TextEditingController();
  final medecinAdresseController = TextEditingController();
  final medecinTelephoneController = TextEditingController();
  final medecinEmailController = TextEditingController();

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  List<PatientLocal> patients = [];
  PatientLocal? currentPatient;

  final ImagePicker documentPicker = ImagePicker();

  String searchQuery = '';
  bool consentementCoche = false;
  bool isSaving = false;
  bool isSigning = false;
  bool hasMedicalDiagnosis = false;
  String? diagnosisDocumentPath;
  String? diagnosisDocumentName;
  String? diagnosisDocumentBase64;
  String? diagnosisDocumentAddedAt;
  bool carteVitalePresentee = false;
  bool identiteVerifiee = false;
  List<PatientMedicalDocument> medicalDocuments = [];
  String? editingPatientLocalId;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  @override
  void dispose() {
    searchController.dispose();
    nomController.dispose();
    prenomController.dispose();
    dateNaissanceController.dispose();
    adresseController.dispose();
    codePostalController.dispose();
    villeController.dispose();
    telephoneController.dispose();
    emailController.dispose();
    professionController.dispose();
    personnePrevenirController.dispose();
    telephoneContactController.dispose();
    medecinNomController.dispose();
    medecinRppsController.dispose();
    medecinAdeliController.dispose();
    medecinAdresseController.dispose();
    medecinTelephoneController.dispose();
    medecinEmailController.dispose();
    signatureController.dispose();
    super.dispose();
  }

  Future<void> loadPatients() async {
    final loadedPatients =
        await RgpdLocalService.getPatientsSortedAlphabetically();
    final activePatient = await RgpdLocalService.getCurrentPatient();
    final accessDirect = await AccessDirectLocalService.loadSettings();

    if (!mounted) return;

    setState(() {
      if (activePatient != null) {
        populateFormFromPatient(activePatient);
      }
      patients = loadedPatients;
      currentPatient = activePatient;
      hasMedicalDiagnosis = accessDirect.hasMedicalDiagnosis;
      diagnosisDocumentPath = accessDirect.diagnosisDocumentPath;
      diagnosisDocumentName = accessDirect.diagnosisDocumentName;
      diagnosisDocumentBase64 = accessDirect.diagnosisDocumentBase64;
      diagnosisDocumentAddedAt = accessDirect.diagnosisDocumentAddedAt;
    });
  }

  Future<void> updateMedicalDiagnosis(bool value) async {
    final existing = await AccessDirectLocalService.loadSettings();

    setState(() {
      hasMedicalDiagnosis = value;
    });

    await AccessDirectLocalService.saveSettings(
      AccessDirectModel(
        isCoordinatedExercise: existing.isCoordinatedExercise,
        isExperimentalDepartment: existing.isExperimentalDepartment,
        hasArsDeclaration: existing.hasArsDeclaration,
        hasMedicalDiagnosis: value,
        diagnosisDocumentPath: diagnosisDocumentPath,
        diagnosisDocumentName: diagnosisDocumentName,
        diagnosisDocumentBase64: diagnosisDocumentBase64,
        diagnosisDocumentAddedAt: diagnosisDocumentAddedAt,
        sessionsDone: existing.sessionsDone,
      ),
    );
  }

  Future<void> chooseDiagnosisDocumentSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Photo'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Galerie'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    await pickDiagnosisDocument(source);
  }

  Future<void> pickDiagnosisDocument(ImageSource source) async {
    final document = await documentPicker.pickImage(
      source: source,
      imageQuality: 82,
    );

    if (document == null) return;

    final bytes = await document.readAsBytes();
    final addedAt = DateTime.now().toIso8601String();
    final existing = await AccessDirectLocalService.loadSettings();

    setState(() {
      hasMedicalDiagnosis = true;
      diagnosisDocumentPath = document.path;
      diagnosisDocumentName = document.name;
      diagnosisDocumentBase64 = base64Encode(bytes);
      diagnosisDocumentAddedAt = addedAt;
    });

    await AccessDirectLocalService.saveSettings(
      AccessDirectModel(
        isCoordinatedExercise: existing.isCoordinatedExercise,
        isExperimentalDepartment: existing.isExperimentalDepartment,
        hasArsDeclaration: existing.hasArsDeclaration,
        hasMedicalDiagnosis: true,
        diagnosisDocumentPath: diagnosisDocumentPath,
        diagnosisDocumentName: diagnosisDocumentName,
        diagnosisDocumentBase64: diagnosisDocumentBase64,
        diagnosisDocumentAddedAt: diagnosisDocumentAddedAt,
        sessionsDone: existing.sessionsDone,
      ),
    );

    if (!mounted) return;

    showMessage('Justificatif médical ajouté.');
  }

  Future<void> removeDiagnosisDocument() async {
    final existing = await AccessDirectLocalService.loadSettings();

    setState(() {
      diagnosisDocumentPath = null;
      diagnosisDocumentName = null;
      diagnosisDocumentBase64 = null;
      diagnosisDocumentAddedAt = null;
    });

    await AccessDirectLocalService.saveSettings(
      AccessDirectModel(
        isCoordinatedExercise: existing.isCoordinatedExercise,
        isExperimentalDepartment: existing.isExperimentalDepartment,
        hasArsDeclaration: existing.hasArsDeclaration,
        hasMedicalDiagnosis: hasMedicalDiagnosis,
        diagnosisDocumentPath: null,
        diagnosisDocumentName: null,
        diagnosisDocumentBase64: null,
        diagnosisDocumentAddedAt: null,
        sessionsDone: existing.sessionsDone,
      ),
    );

    if (!mounted) return;

    showMessage('Justificatif médical supprimé.');
  }

  static const List<String> medicalDocumentTypes = [
    'Prescription médicale',
    'Courrier médical',
    'Compte-rendu spécialiste',
    'Autre justificatif',
  ];

  Future<void> choosePatientMedicalDocumentSource(String type) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Photo'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Galerie'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    await pickPatientMedicalDocument(type: type, source: source);
  }

  Future<void> pickPatientMedicalDocument({
    required String type,
    required ImageSource source,
  }) async {
    final document = await documentPicker.pickImage(
      source: source,
      imageQuality: 82,
    );

    if (document == null) return;

    final bytes = await document.readAsBytes();
    final nextDocuments = List<PatientMedicalDocument>.from(medicalDocuments)
      ..removeWhere((item) => item.type == type)
      ..add(
        PatientMedicalDocument(
          type: type,
          documentPath: document.path,
          documentName: document.name,
          documentBase64: base64Encode(bytes),
          documentAddedAt: DateTime.now().toIso8601String(),
        ),
      );

    setState(() {
      medicalDocuments = nextDocuments;
    });

    showMessage('$type ajouté.');
  }

  void removePatientMedicalDocument(String type) {
    setState(() {
      medicalDocuments = List<PatientMedicalDocument>.from(medicalDocuments)
        ..removeWhere((item) => item.type == type);
    });

    showMessage('$type supprimé.');
  }

  List<PatientLocal> get filteredPatients {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return patients;

    return patients.where((patient) {
      return patient.nom.toLowerCase().contains(query) ||
          patient.prenom.toLowerCase().contains(query) ||
          patient.dateNaissance.toLowerCase().contains(query) ||
          patient.anonymousId.toLowerCase().contains(query);
    }).toList();
  }

  PatientLocal? get existingPatient {
    final nom = nomController.text.trim().toLowerCase();
    final prenom = prenomController.text.trim().toLowerCase();
    final naissance = dateNaissanceController.text.trim().toLowerCase();

    if (nom.isEmpty || prenom.isEmpty || naissance.isEmpty) return null;

    for (final patient in patients) {
      if (patient.nom.trim().toLowerCase() == nom &&
          patient.prenom.trim().toLowerCase() == prenom &&
          patient.dateNaissance.trim().toLowerCase() == naissance) {
        return patient;
      }
    }

    return null;
  }

  bool get hasPatientIdentityDraft {
    return nomController.text.trim().isNotEmpty ||
        prenomController.text.trim().isNotEmpty ||
        dateNaissanceController.text.trim().isNotEmpty;
  }

  Future<void> activateAnonymousMode() async {
    await RgpdLocalService.clearCurrentPatient();
    await loadPatients();

    if (!mounted) return;

    showMessage('Mode patient anonyme activé.');
  }

  Future<void> saveOrActivatePatient() async {
    final nom = nomController.text.trim();
    final prenom = prenomController.text.trim();
    final dateNaissance = dateNaissanceController.text.trim();
    final hasAnyField =
        nom.isNotEmpty || prenom.isNotEmpty || dateNaissance.isNotEmpty;

    if (!hasAnyField) {
      if (currentPatient == null) {
        await activateAnonymousMode();
      } else {
        showMessage('Patient actif conservé.');
      }

      return;
    }

    if (nomController.text.trim().isEmpty ||
        prenomController.text.trim().isEmpty ||
        dateNaissanceController.text.trim().isEmpty) {
      showMessage('Merci de renseigner nom, prénom et date de naissance.');
      return;
    }

    final foundPatient = existingPatient;
    final editedPatient = editingPatient;
    final patientToUpdate = editedPatient ?? foundPatient;

    if (patientToUpdate != null) {
      await saveExistingPatient(patientToUpdate);
      return;
    }

    if (!consentementCoche) {
      showMessage('Merci de cocher le consentement patient.');
      return;
    }

    if (signatureController.isEmpty) {
      showMessage('Merci de faire signer le patient.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    final Uint8List? signatureBytes = await signatureController.toPngBytes();

    if (signatureBytes == null) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage('Erreur lors de la sauvegarde de la signature.');
      return;
    }

    final patient = PatientLocal(
      localId: RgpdLocalService.createLocalId(),
      anonymousId: RgpdLocalService.createAnonymousId(),
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      dateNaissance: dateNaissanceController.text.trim(),
      consentementValide: true,
      dateConsentement: DateTime.now(),
      signatureBase64: base64Encode(signatureBytes),
      adresse: adresseController.text.trim(),
      codePostal: codePostalController.text.trim(),
      ville: villeController.text.trim(),
      telephone: telephoneController.text.trim(),
      email: emailController.text.trim(),
      profession: professionController.text.trim(),
      personnePrevenir: personnePrevenirController.text.trim(),
      telephoneContact: telephoneContactController.text.trim(),
      medecinNom: medecinNomController.text.trim(),
      medecinRpps: medecinRppsController.text.trim(),
      medecinAdeli: medecinAdeliController.text.trim(),
      medecinAdresse: medecinAdresseController.text.trim(),
      medecinTelephone: medecinTelephoneController.text.trim(),
      medecinEmail: medecinEmailController.text.trim(),
      carteVitalePresentee: carteVitalePresentee,
      identiteVerifiee: identiteVerifiee,
      medicalDocuments: medicalDocuments,
    );

    await RgpdLocalService.saveOrUpdatePatient(patient);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    clearForm();
    await loadPatients();

    showMessage('Patient enregistré et activé.');
  }

  PatientLocal? get editingPatient {
    final localId = editingPatientLocalId;
    if (localId == null || localId.isEmpty) return null;

    for (final patient in patients) {
      if (patient.localId == localId) return patient;
    }

    return currentPatient?.localId == localId ? currentPatient : null;
  }

  Future<void> saveExistingPatient(PatientLocal patient) async {
    if (!patient.consentementValide && !consentementCoche) {
      showMessage('Merci de cocher le consentement patient.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    final Uint8List? signatureBytes = signatureController.isEmpty
        ? null
        : await signatureController.toPngBytes();

    final updatedPatient = PatientLocal(
      localId: patient.localId,
      anonymousId: patient.anonymousId,
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      dateNaissance: dateNaissanceController.text.trim(),
      consentementValide: patient.consentementValide || consentementCoche,
      dateConsentement: patient.consentementValide
          ? patient.dateConsentement
          : DateTime.now(),
      signatureBase64: signatureBytes == null
          ? patient.signatureBase64
          : base64Encode(signatureBytes),
      adresse: adresseController.text.trim(),
      codePostal: codePostalController.text.trim(),
      ville: villeController.text.trim(),
      telephone: telephoneController.text.trim(),
      email: emailController.text.trim(),
      profession: professionController.text.trim(),
      personnePrevenir: personnePrevenirController.text.trim(),
      telephoneContact: telephoneContactController.text.trim(),
      medecinNom: medecinNomController.text.trim(),
      medecinRpps: medecinRppsController.text.trim(),
      medecinAdeli: medecinAdeliController.text.trim(),
      medecinAdresse: medecinAdresseController.text.trim(),
      medecinTelephone: medecinTelephoneController.text.trim(),
      medecinEmail: medecinEmailController.text.trim(),
      carteVitalePresentee: carteVitalePresentee,
      identiteVerifiee: identiteVerifiee,
      medicalDocuments: medicalDocuments,
    );

    await RgpdLocalService.saveOrUpdatePatient(updatedPatient);

    if (!mounted) return;

    setState(() {
      isSaving = false;
      editingPatientLocalId = updatedPatient.localId;
    });

    await loadPatients();

    showMessage('Patient mis à jour et activé.');
  }

  void clearForm() {
    nomController.clear();
    prenomController.clear();
    dateNaissanceController.clear();
    adresseController.clear();
    codePostalController.clear();
    villeController.clear();
    telephoneController.clear();
    emailController.clear();
    professionController.clear();
    personnePrevenirController.clear();
    telephoneContactController.clear();
    medecinNomController.clear();
    medecinRppsController.clear();
    medecinAdeliController.clear();
    medecinAdresseController.clear();
    medecinTelephoneController.clear();
    medecinEmailController.clear();
    consentementCoche = false;
    carteVitalePresentee = false;
    identiteVerifiee = false;
    medicalDocuments = [];
    editingPatientLocalId = null;
    signatureController.clear();

    if (mounted) setState(() {});
  }

  Future<void> selectPatient(PatientLocal patient) async {
    await RgpdLocalService.setCurrentPatientId(patient.localId);
    populateFormFromPatient(patient);
    await loadPatients();

    if (!mounted) return;

    showMessage('${patient.nom.toUpperCase()} ${patient.prenom} activé.');
  }

  void populateFormFromPatient(PatientLocal patient) {
    nomController.text = patient.nom;
    prenomController.text = patient.prenom;
    dateNaissanceController.text = patient.dateNaissance;
    adresseController.text = patient.adresse;
    codePostalController.text = patient.codePostal;
    villeController.text = patient.ville;
    telephoneController.text = patient.telephone;
    emailController.text = patient.email;
    professionController.text = patient.profession;
    personnePrevenirController.text = patient.personnePrevenir;
    telephoneContactController.text = patient.telephoneContact;
    medecinNomController.text = patient.medecinNom;
    medecinRppsController.text = patient.medecinRpps;
    medecinAdeliController.text = patient.medecinAdeli;
    medecinAdresseController.text = patient.medecinAdresse;
    medecinTelephoneController.text = patient.medecinTelephone;
    medecinEmailController.text = patient.medecinEmail;
    consentementCoche = patient.consentementValide;
    carteVitalePresentee = patient.carteVitalePresentee;
    identiteVerifiee = patient.identiteVerifiee;
    medicalDocuments = List<PatientMedicalDocument>.from(
      patient.medicalDocuments,
    );
    editingPatientLocalId = patient.localId;
    signatureController.clear();
  }

  Future<void> deletePatient(PatientLocal patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce patient ?'),
          content: Text(
            'Cette action supprimera ${patient.nom.toUpperCase()} ${patient.prenom} de cet appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await RgpdLocalService.deletePatient(patient.localId);
    await loadPatients();

    if (!mounted) return;

    showMessage('Patient supprimé localement.');
  }

  Future<void> confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer tous les patients ?'),
          content: const Text(
            'Cette action supprimera tous les patients enregistrés localement sur cet appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await RgpdLocalService.deleteAllLocalData();
    await loadPatients();

    if (!mounted) return;

    showMessage('Tous les patients locaux ont été supprimés.');
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool isCurrentPatient(PatientLocal patient) {
    return currentPatient?.localId == patient.localId;
  }

  String patientName(PatientLocal patient) {
    return '${patient.nom.toUpperCase()} ${patient.prenom}'.trim();
  }

  Widget buildPageSection({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }

  Widget buildSignatureHeader() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.draw_outlined,
            color: AppColors.primary,
            size: 19,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Signature patient',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFormFieldGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget buildFieldGap() => const SizedBox(height: 8);

  Widget buildPatientIdentityFields() {
    return buildFormFieldGroup(
      title: 'Patient identifié',
      children: [
        buildTextField(
          controller: nomController,
          label: 'Nom',
          textCapitalization: TextCapitalization.characters,
        ),
        buildFieldGap(),
        buildTextField(
          controller: prenomController,
          label: 'Prénom',
          textCapitalization: TextCapitalization.words,
        ),
        buildFieldGap(),
        buildTextField(
          controller: dateNaissanceController,
          label: 'Date de naissance',
          hint: 'JJ/MM/AAAA',
          suffixIcon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.datetime,
        ),
      ],
    );
  }

  Widget buildAdvancedIdentificationBlock() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          initiallyExpanded: false,
          maintainState: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          leading: const Icon(
            Icons.manage_accounts_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            'Identification avancée',
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            'Coordonnées, médecin traitant et documents médicaux',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            buildAdvancedPatientSection(),
            const SizedBox(height: 10),
            buildTreatingDoctorSection(),
            const SizedBox(height: 10),
            buildMedicalDocumentsSection(),
          ],
        ),
      ),
    );
  }

  Widget buildAdvancedPatientSection() {
    return buildFormFieldGroup(
      title: 'Coordonnées patient',
      children: [
        buildTextField(
          controller: adresseController,
          label: 'Adresse',
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        buildFieldGap(),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: buildTextField(
                controller: codePostalController,
                label: 'Code postal',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: buildTextField(
                controller: villeController,
                label: 'Ville',
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        buildFieldGap(),
        buildTextField(
          controller: telephoneController,
          label: 'Téléphone',
          keyboardType: TextInputType.phone,
        ),
        buildFieldGap(),
        buildTextField(
          controller: emailController,
          label: 'E-mail',
          keyboardType: TextInputType.emailAddress,
        ),
        buildFieldGap(),
        buildTextField(
          controller: professionController,
          label: 'Profession',
          textCapitalization: TextCapitalization.words,
        ),
        buildFieldGap(),
        buildTextField(
          controller: personnePrevenirController,
          label: 'Personne à prévenir',
          textCapitalization: TextCapitalization.words,
        ),
        buildFieldGap(),
        buildTextField(
          controller: telephoneContactController,
          label: 'Téléphone du contact',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        buildAdvancedCheckbox(
          value: carteVitalePresentee,
          label: 'Carte Vitale présentée',
          onChanged: (value) {
            setState(() {
              carteVitalePresentee = value ?? false;
            });
          },
        ),
        buildAdvancedCheckbox(
          value: identiteVerifiee,
          label: 'Identité vérifiée',
          onChanged: (value) {
            setState(() {
              identiteVerifiee = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget buildTreatingDoctorSection() {
    return buildFormFieldGroup(
      title: 'Médecin traitant',
      children: [
        buildTextField(
          controller: medecinNomController,
          label: 'Nom',
          textCapitalization: TextCapitalization.words,
        ),
        buildFieldGap(),
        Row(
          children: [
            Expanded(
              child: buildTextField(
                controller: medecinRppsController,
                label: 'RPPS',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildTextField(
                controller: medecinAdeliController,
                label: 'ADELI',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        buildFieldGap(),
        buildTextField(
          controller: medecinAdresseController,
          label: 'Adresse',
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        buildFieldGap(),
        buildTextField(
          controller: medecinTelephoneController,
          label: 'Téléphone',
          keyboardType: TextInputType.phone,
        ),
        buildFieldGap(),
        buildTextField(
          controller: medecinEmailController,
          label: 'E-mail',
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget buildMedicalDocumentsSection() {
    return buildFormFieldGroup(
      title: 'Documents médicaux',
      children: medicalDocumentTypes.map(buildMedicalDocumentRow).toList(),
    );
  }

  Widget buildMedicalDocumentRow(String type) {
    final document = medicalDocuments
        .cast<PatientMedicalDocument?>()
        .firstWhere((item) => item?.type == type, orElse: () => null);
    final hasDocument = document?.hasStoredDocument ?? false;
    final subtitle = hasDocument
        ? (document?.documentName?.trim().isNotEmpty ?? false)
              ? document!.documentName!.trim()
              : 'Document ajouté'
        : 'Aucun document';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasDocument ? AppColors.surfaceSuccess : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasDocument
              ? AppColors.success.withValues(alpha: 0.30)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDocument
                ? Icons.check_circle_rounded
                : Icons.description_outlined,
            color: hasDocument ? AppColors.successDark : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => choosePatientMedicalDocumentSource(type),
            child: Text(hasDocument ? 'Remplacer' : 'Ajouter'),
          ),
          if (hasDocument)
            IconButton(
              tooltip: 'Supprimer',
              onPressed: () => removePatientMedicalDocument(type),
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.danger,
            ),
        ],
      ),
    );
  }

  Widget buildAdvancedCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      title: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visiblePatients = filteredPatients;
    final foundPatient = existingPatient;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPatients,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: ListView(
                physics: isSigning
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  104,
                ),
                children: [
                  buildSearchBar(),
                  const SizedBox(height: AppSpacing.sm),
                  buildPatientForm(foundPatient),
                  const SizedBox(height: AppSpacing.sm),
                  buildPatientsList(visiblePatients),
                  const SizedBox(height: AppSpacing.sm),
                  buildDeleteAllButton(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomSaveBar(foundPatient),
    );
  }

  Widget buildSearchBar() {
    return buildPageSection(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher un patient...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Effacer la recherche',
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget buildPatientForm(PatientLocal? foundPatient) {
    final patientExists = foundPatient != null;

    return buildPageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.person_outline_rounded,
            title: patientExists ? 'Patient déjà connu' : 'Patient identifié',
          ),
          const SizedBox(height: 10),
          buildPatientIdentityFields(),
          if (hasPatientIdentityDraft) ...[
            const SizedBox(height: 10),
            buildAdvancedIdentificationBlock(),
          ],
          if (patientExists) ...[
            const SizedBox(height: 10),
            buildExistingPatientNotice(foundPatient),
          ],
          if (!patientExists) ...[
            const SizedBox(height: 10),
            buildMedicalDiagnosisCard(),
            const SizedBox(height: 10),
            buildConsentCard(),
            const SizedBox(height: 10),
            buildSignatureHeader(),
            const SizedBox(height: 8),
            buildSignatureBox(),
            const SizedBox(height: 8),
            buildClearSignatureButton(),
          ],
        ],
      ),
    );
  }

  Widget buildMedicalDiagnosisCard() {
    return Container(
      decoration: BoxDecoration(
        color: hasMedicalDiagnosis ? AppColors.surfaceAlt : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasMedicalDiagnosis
              ? AppColors.primary.withValues(alpha: 0.32)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: hasMedicalDiagnosis,
              onChanged: (value) => updateMedicalDiagnosis(value ?? false),
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Diagnostic médical préalable',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (hasMedicalDiagnosis) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _DiagnosisDocumentCard(
                documentPath: diagnosisDocumentPath,
                documentName: diagnosisDocumentName,
                documentAddedAt: diagnosisDocumentAddedAt,
                hasStoredDocument:
                    diagnosisDocumentBase64?.trim().isNotEmpty ?? false,
                onAdd: chooseDiagnosisDocumentSource,
                onRemove: removeDiagnosisDocument,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildClearSignatureButton() {
    return Align(
      alignment: Alignment.center,
      child: OutlinedButton(
        onPressed: () {
          signatureController.clear();
          setState(() {});
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.28)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
        child: const Text('Effacer', textAlign: TextAlign.center),
      ),
    );
  }

  Widget buildExistingPatientNotice(PatientLocal patient) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSuccess,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_search_rounded, color: AppColors.successDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Patient déjà enregistré : ${patientName(patient)}. Le bouton va le mettre à jour et l’activer.',
              style: AppTypography.caption.copyWith(
                color: AppColors.successDark,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      style: AppTypography.body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }

  Widget buildConsentCard() {
    return Container(
      decoration: BoxDecoration(
        color: consentementCoche ? AppColors.surfaceSuccess : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: consentementCoche ? AppColors.success : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: CheckboxListTile(
          value: consentementCoche,
          onChanged: (value) {
            setState(() {
              consentementCoche = value ?? false;
            });
          },
          activeColor: AppColors.success,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Le patient consent à l’utilisation locale de ses données dans l’application.',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignatureBox() {
    return Listener(
      onPointerDown: (_) {
        setState(() {
          isSigning = true;
        });
      },
      onPointerUp: (_) {
        setState(() {
          isSigning = false;
        });
      },
      onPointerCancel: (_) {
        setState(() {
          isSigning = false;
        });
      },
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
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPatientsList(List<PatientLocal> visiblePatients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.folder_shared_outlined,
          title: 'Patients enregistrés',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (patients.isEmpty)
          buildEmptyCard(
            icon: Icons.folder_open_rounded,
            title: 'Aucun patient enregistré',
            text: 'Les patients créés localement apparaîtront ici.',
          )
        else if (visiblePatients.isEmpty)
          buildEmptyCard(
            icon: Icons.search_off_rounded,
            title: 'Aucun résultat',
            text: 'Essayez avec un autre nom, prénom ou une autre date.',
          )
        else
          ...visiblePatients.map(buildPatientTile),
      ],
    );
  }

  Widget buildPatientTile(PatientLocal patient) {
    final active = isCurrentPatient(patient);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceSuccess : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: active ? AppShadows.soft : const [],
        border: Border.all(
          color: active
              ? AppColors.success.withValues(alpha: 0.55)
              : AppColors.border,
          width: active ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () => selectPatient(patient),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? AppColors.success : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              active ? Icons.check_rounded : Icons.person_rounded,
              color: active ? AppColors.textOnDark : AppColors.primary,
            ),
          ),
          title: Text(
            patientName(patient),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            active
                ? 'Patient actif · Né(e) le ${patient.dateNaissance}'
                : 'Né(e) le ${patient.dateNaissance}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? AppColors.successDark : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'select') selectPatient(patient);
              if (value == 'delete') deletePatient(patient);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'select', child: Text('Activer')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer localement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDeleteAllButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.16)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: TextButton.icon(
          onPressed: confirmDeleteAll,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Supprimer tous les patients locaux'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.danger,
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 30),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomSaveBar(PatientLocal? foundPatient) {
    final hasAnyField =
        nomController.text.trim().isNotEmpty ||
        prenomController.text.trim().isNotEmpty ||
        dateNaissanceController.text.trim().isNotEmpty;
    final buttonText = foundPatient != null || editingPatient != null
        ? 'Mettre à jour / Activer'
        : hasAnyField
        ? 'Enregistrer / Activer'
        : 'Patient anonyme';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppShadows.card,
        ),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: isSaving ? null : saveOrActivatePatient,
            icon: const Icon(Icons.save_outlined),
            label: Text(
              isSaving ? 'Enregistrement...' : buttonText,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosisDocumentCard extends StatelessWidget {
  const _DiagnosisDocumentCard({
    required this.documentPath,
    required this.documentName,
    required this.documentAddedAt,
    required this.hasStoredDocument,
    required this.onAdd,
    required this.onRemove,
  });

  final String? documentPath;
  final String? documentName;
  final String? documentAddedAt;
  final bool hasStoredDocument;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasDocument =
        hasStoredDocument || (documentPath?.trim().isNotEmpty ?? false);
    final label = hasDocument
        ? (documentName?.trim().isNotEmpty ?? false)
              ? documentName!.trim()
              : 'Justificatif ajouté'
        : 'Aucun justificatif ajouté';
    final addedAt = _formatAddedAt(documentAddedAt);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasDocument ? AppColors.surfaceSuccess : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasDocument
              ? AppColors.success.withValues(alpha: 0.30)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                hasDocument
                    ? Icons.check_circle_rounded
                    : Icons.add_a_photo_outlined,
                color: hasDocument ? AppColors.successDark : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: hasDocument
                            ? AppColors.successDark
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasDocument
                          ? 'Stocké localement${addedAt == null ? '' : ' · $addedAt'}'
                          : 'Photo ou galerie',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: Icon(
                    hasDocument
                        ? Icons.change_circle_outlined
                        : Icons.add_a_photo_outlined,
                    size: 18,
                  ),
                  label: Text(hasDocument ? 'Remplacer' : 'Ajouter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.24),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              if (hasDocument) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  child: const Text('Supprimer'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String? _formatAddedAt(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    final date = DateTime.tryParse(raw);
    if (date == null) return null;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
