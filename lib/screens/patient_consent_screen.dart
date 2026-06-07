import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../models/patient_local.dart';
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

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  List<PatientLocal> patients = [];
  PatientLocal? currentPatient;

  String searchQuery = '';
  bool consentementCoche = false;
  bool isSaving = false;
  bool isSigning = false;

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
    signatureController.dispose();
    super.dispose();
  }

  Future<void> loadPatients() async {
    final loadedPatients =
        await RgpdLocalService.getPatientsSortedAlphabetically();
    final activePatient = await RgpdLocalService.getCurrentPatient();

    if (!mounted) return;

    setState(() {
      patients = loadedPatients;
      currentPatient = activePatient;
    });
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

  void openIdentifiedPatientPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PatientIdentifiedPage(parent: this)),
    );
  }

  Future<void> activateAnonymousMode() async {
    await RgpdLocalService.clearCurrentPatient();
    await loadPatients();

    if (!mounted) return;

    showMessage('Mode patient anonyme activé.');
  }

  Future<void> saveOrActivatePatient() async {
    if (nomController.text.trim().isEmpty ||
        prenomController.text.trim().isEmpty ||
        dateNaissanceController.text.trim().isEmpty) {
      showMessage('Merci de renseigner nom, prénom et date de naissance.');
      return;
    }

    final foundPatient = existingPatient;

    if (foundPatient != null) {
      await selectPatient(foundPatient);
      clearForm();
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

  void clearForm() {
    nomController.clear();
    prenomController.clear();
    dateNaissanceController.clear();
    consentementCoche = false;
    signatureController.clear();

    if (mounted) setState(() {});
  }

  Future<void> selectPatient(PatientLocal patient) async {
    await RgpdLocalService.setCurrentPatientId(patient.localId);
    await loadPatients();

    if (!mounted) return;

    showMessage('${patient.nom.toUpperCase()} ${patient.prenom} activé.');
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

  Widget buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.medicalBlue,
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.textOnDark.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.textOnDark,
                  size: 27,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Identité locale, consentement RGPD et patient actif.',
                      style: TextStyle(
                        color: AppColors.textOnDark.withValues(alpha: 0.82),
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
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeaderBadge(
                label: '${patients.length} local',
                icon: Icons.people_alt_outlined,
              ),
              const _HeaderBadge(
                label: 'Données appareil',
                icon: Icons.lock_outline_rounded,
              ),
              _HeaderBadge(
                label: currentPatient == null ? 'Anonyme' : 'Actif',
                icon: currentPatient == null
                    ? Icons.no_accounts_outlined
                    : Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPatientWorkspaceIntro() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        final cards = [
          _InsightCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Identifier',
            text: 'Créer ou retrouver un patient local avec consentement.',
            color: AppColors.primary,
          ),
          _InsightCard(
            icon: Icons.no_accounts_rounded,
            title: 'Anonyme',
            text: 'Continuer sans données nominatives si nécessaire.',
            color: AppColors.teal,
          ),
          _InsightCard(
            icon: Icons.security_rounded,
            title: 'Local',
            text: 'Les données patient restent gérées sur cet appareil.',
            color: AppColors.warningDark,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: card == cards.last ? 0 : AppSpacing.sm,
                      ),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: cards
              .map(
                (card) => Padding(
                  padding: EdgeInsets.only(
                    bottom: card == cards.last ? 0 : AppSpacing.sm,
                  ),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget buildStatusPanel() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: currentPatient != null
          ? buildCurrentPatientBanner()
          : buildAnonymousBanner(),
    );
  }

  Widget buildPageSection({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }

  Widget buildConsentBullet(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.successDark, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signature patient',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Trace locale du consentement, sans envoi externe.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFormFieldGroup({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget buildPatientMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInlineAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = AppColors.primary,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.28)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget buildSaveHint(PatientLocal? foundPatient) {
    return Text(
      foundPatient == null
          ? 'Création locale après identité, consentement et signature.'
          : 'Ce patient existe déjà : le bouton active le dossier local.',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
    );
  }

  Widget buildResponsiveActions({
    required List<Widget> children,
    MainAxisAlignment alignment = MainAxisAlignment.start,
  }) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: alignment == MainAxisAlignment.center
          ? WrapAlignment.center
          : WrapAlignment.start,
      children: children,
    );
  }

  Widget buildFieldGap() => const SizedBox(height: AppSpacing.sm);

  Widget buildMobileDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      color: AppColors.border,
    );
  }

  Widget buildPatientsSummary(List<PatientLocal> visiblePatients) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        buildPatientMetaChip(
          icon: Icons.folder_shared_outlined,
          label: '${patients.length} enregistré(s)',
          color: AppColors.primary,
        ),
        buildPatientMetaChip(
          icon: Icons.filter_alt_outlined,
          label: '${visiblePatients.length} affiché(s)',
          color: AppColors.teal,
        ),
      ],
    );
  }

  Widget buildConsentStatusChip() {
    return buildPatientMetaChip(
      icon: consentementCoche
          ? Icons.check_circle_outline_rounded
          : Icons.radio_button_unchecked_rounded,
      label: consentementCoche ? 'Consentement coché' : 'Consentement requis',
      color: consentementCoche ? AppColors.successDark : AppColors.warningDark,
    );
  }

  Widget buildPatientIdentityFields() {
    return buildFormFieldGroup(
      title: 'Identité patient',
      subtitle:
          'Ces informations servent uniquement à retrouver le dossier local.',
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

  Widget buildAnonymousModeNote() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Le mode anonyme reste disponible à tout moment pour poursuivre sans patient identifié.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
                  AppSpacing.md,
                  AppSpacing.md,
                  120,
                ),
                children: [
                  buildPatientHeader(),
                  const SizedBox(height: AppSpacing.md),
                  buildPatientWorkspaceIntro(),
                  const SizedBox(height: AppSpacing.md),
                  buildStatusPanel(),
                  const SizedBox(height: AppSpacing.md),
                  buildSearchBar(),
                  const SizedBox(height: AppSpacing.md),
                  buildPatientForm(foundPatient),
                  const SizedBox(height: AppSpacing.lg),
                  buildPatientsList(visiblePatients),
                  const SizedBox(height: AppSpacing.md),
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

  Widget buildAnonymousBanner() {
    return buildPageSection(
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
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: const Icon(
                  Icons.no_accounts_outlined,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode patient anonyme',
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aucun patient identifié actif. Les évaluations restent associées à “Patient non renseigné”.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          buildMobileDivider(),
          buildResponsiveActions(
            children: [
              buildInlineAction(
                icon: Icons.no_accounts_rounded,
                label: 'Confirmer le mode anonyme',
                onPressed: activateAnonymousMode,
                color: AppColors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCurrentPatientBanner() {
    return buildPageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.textOnDark,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient actif',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.successDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      patientName(currentPatient!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        buildPatientMetaChip(
                          icon: Icons.cake_outlined,
                          label: 'Né(e) le ${currentPatient!.dateNaissance}',
                          color: AppColors.successDark,
                        ),
                        buildPatientMetaChip(
                          icon: Icons.tag_outlined,
                          label: currentPatient!.anonymousId,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          buildMobileDivider(),
          buildResponsiveActions(
            children: [
              buildInlineAction(
                icon: Icons.no_accounts_outlined,
                label: 'Passer en anonyme',
                onPressed: activateAnonymousMode,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
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

  Widget buildEntryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildBigEntryCard(
                  title: 'PATIENT IDENTIFIÉ',
                  subtitle:
                      'Créer ou activer un patient avec consentement et signature.',
                  buttonText: 'Renseigner le patient',
                  icon: Icons.person_add_alt_1_rounded,
                  backgroundColor: AppColors.surfaceAlt,
                  borderColor: AppColors.borderStrong,
                  mainColor: AppColors.primary,
                  onTap: openIdentifiedPatientPage,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: buildBigEntryCard(
                  title: 'PATIENT ANONYME',
                  subtitle:
                      'Évaluation rapide sans données personnelles nominatives.',
                  buttonText: 'Utiliser le mode anonyme',
                  icon: Icons.no_accounts_rounded,
                  backgroundColor: AppColors.surface,
                  borderColor: AppColors.border,
                  mainColor: AppColors.textSecondary,
                  onTap: activateAnonymousMode,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            buildBigEntryCard(
              title: 'PATIENT IDENTIFIÉ',
              subtitle:
                  'Créer ou activer un patient avec consentement et signature.',
              buttonText: 'Renseigner le patient',
              icon: Icons.person_add_alt_1_rounded,
              backgroundColor: AppColors.surfaceAlt,
              borderColor: AppColors.borderStrong,
              mainColor: AppColors.primary,
              onTap: openIdentifiedPatientPage,
            ),
            const SizedBox(height: 18),
            buildBigEntryCard(
              title: 'PATIENT ANONYME',
              subtitle:
                  'Évaluation rapide sans données personnelles nominatives.',
              buttonText: 'Utiliser le mode anonyme',
              icon: Icons.no_accounts_rounded,
              backgroundColor: AppColors.surface,
              borderColor: AppColors.border,
              mainColor: AppColors.textSecondary,
              onTap: activateAnonymousMode,
            ),
          ],
        );
      },
    );
  }

  Widget buildBigEntryCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color mainColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          height: 360,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: mainColor.withValues(alpha: 0.08),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [mainColor.withValues(alpha: 0.78), mainColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 58),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
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
            title: patientExists ? 'Patient déjà connu' : 'Créer un patient',
            subtitle: patientExists
                ? 'Activez le dossier existant sans recréer de données.'
                : 'Renseignez l’identité et le consentement local.',
          ),
          const SizedBox(height: AppSpacing.md),
          buildPatientIdentityFields(),
          if (patientExists) ...[
            const SizedBox(height: AppSpacing.md),
            buildExistingPatientNotice(foundPatient),
          ],
          if (!patientExists) ...[
            const SizedBox(height: AppSpacing.md),
            Row(children: [Expanded(child: buildConsentStatusChip())]),
            const SizedBox(height: AppSpacing.sm),
            buildConsentCard(),
            const SizedBox(height: AppSpacing.md),
            buildSignatureHeader(),
            const SizedBox(height: AppSpacing.sm),
            buildSignatureBox(),
            const SizedBox(height: AppSpacing.sm),
            buildResponsiveActions(
              children: [
                buildInlineAction(
                  icon: Icons.cleaning_services_rounded,
                  label: 'Effacer la signature',
                  onPressed: signatureController.clear,
                ),
              ],
            ),
            buildAnonymousModeNote(),
          ],
        ],
      ),
    );
  }

  Widget buildExistingPatientNotice(PatientLocal patient) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
              'Patient déjà enregistré : ${patientName(patient)}. Le bouton va l’activer.',
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
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
        height: 108,
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
          subtitle: '${visiblePatients.length}/${patients.length} affiché(s)',
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
      child: ListTile(
        onTap: () => selectPatient(patient),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
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
            PopupMenuItem(value: 'delete', child: Text('Supprimer localement')),
          ],
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
      padding: const EdgeInsets.all(AppSpacing.md),
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
    final buttonText = foundPatient == null
        ? 'Enregistrer / Activer'
        : 'Activer ce patient';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
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

class _PatientIdentifiedPage extends StatelessWidget {
  const _PatientIdentifiedPage({required this.parent});

  final _PatientConsentScreenState parent;

  @override
  Widget build(BuildContext context) {
    final visiblePatients = parent.filteredPatients;
    final foundPatient = parent.existingPatient;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: parent.loadPatients,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: ListView(
                physics: parent.isSigning
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  120,
                ),
                children: [
                  parent.buildSearchBar(),
                  const SizedBox(height: AppSpacing.md),
                  parent.buildPatientForm(foundPatient),
                  const SizedBox(height: AppSpacing.lg),
                  parent.buildPatientsList(visiblePatients),
                  const SizedBox(height: AppSpacing.md),
                  parent.buildDeleteAllButton(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: parent.buildBottomSaveBar(foundPatient),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.textOnDark.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.textOnDark.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textOnDark, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withValues(alpha: 0.18)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
              const SizedBox(height: 2),
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
      ],
    );
  }
}
