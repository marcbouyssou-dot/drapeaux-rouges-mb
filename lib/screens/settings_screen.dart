import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../models/practitioner_profile.dart';
import '../services/global_statistics_csv_service.dart';
import '../services/patient_record_service.dart';
import '../services/practitioner_profile_service.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_colors.dart' as ds;
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart' as spacing;
import 'access_direct_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PractitionerProfile practitioner = PractitionerProfile.empty();

  @override
  void initState() {
    super.initState();
    loadPractitioner();
  }

  Future<void> loadPractitioner() async {
    final profile = await PractitionerProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      practitioner = profile;
    });
  }

  Future<void> showAnonymousRecordsExport(BuildContext context) async {
    final data = await PatientRecordService.getAnonymousRecordsExport();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Export pseudonymisé'),
          content: SingleChildScrollView(
            child: Text(const JsonEncoder.withIndent('  ').convert(data)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
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
    final structureAddressController = TextEditingController(
      text: practitioner.adresseStructure,
    );
    final departementController = TextEditingController(
      text: practitioner.departement,
    );
    var exerciceCoordonne = practitioner.exerciceCoordonne;
    var exerciceAccesDirect = practitioner.exerciceAccesDirect;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Informations MK'),
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
                    SwitchListTile(
                      value: exerciceAccesDirect,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Exercice en accès direct'),
                      subtitle: const Text(
                        'Un seul item coché suffit à valider le statut accès direct.',
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          exerciceAccesDirect = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: structureController,
                      label: 'Nom de structure',
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: structureAddressController,
                      label: 'Adresse de la structure',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    buildDialogField(
                      controller: departementController,
                      label: 'Département',
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
                  exerciceAccesDirect: exerciceAccesDirect,
                  nomStructure: structureController.text.trim(),
                  adresseStructure: structureAddressController.text.trim(),
                  departement: departementController.text.trim(),
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
    structureAddressController.dispose();
    departementController.dispose();

    if (saved == true) {
      await loadPractitioner();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations MK enregistrées')),
      );
    }
  }

  Future<void> showPractitionerSignatureDialog() async {
    final signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    var signaturePreview = practitioner.signatureBase64;
    var saved = false;

    try {
      saved =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    title: const Text('Signature praticien'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (signaturePreview.trim().isNotEmpty) ...[
                            const Text(
                              'Signature enregistrée',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            _signaturePreview(signaturePreview),
                            const SizedBox(height: 14),
                          ],
                          const Text(
                            'Nouvelle signature',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          _signaturePad(signatureController),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: signatureController.clear,
                            icon: const Icon(Icons.backspace_outlined),
                            label: const Text('Effacer le tracé'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final updatedProfile = practitioner.copyWith(
                            signatureBase64: '',
                          );

                          await PractitionerProfileService.saveProfile(
                            updatedProfile,
                          );

                          if (!dialogContext.mounted) return;

                          setDialogState(() {
                            signaturePreview = '';
                            signatureController.clear();
                          });

                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text('Supprimer'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          if (signatureController.isEmpty) {
                            Navigator.pop(dialogContext, false);
                            return;
                          }

                          final signatureBytes = await signatureController
                              .toPngBytes();

                          if (signatureBytes == null) {
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext, false);
                            return;
                          }

                          final updatedProfile = practitioner.copyWith(
                            signatureBase64: base64Encode(signatureBytes),
                          );

                          await PractitionerProfileService.saveProfile(
                            updatedProfile,
                          );

                          if (!dialogContext.mounted) return;

                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  );
                },
              );
            },
          ) ??
          false;
    } finally {
      signatureController.dispose();
    }

    if (!saved) return;

    await loadPractitioner();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signature praticien mise à jour')),
    );
  }

  Widget _signaturePad(SignatureController controller) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ds.AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Signature(controller: controller, backgroundColor: Colors.white),
            const Center(
              child: IgnorePointer(
                child: Text(
                  'Signer ici',
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
    );
  }

  Widget _signaturePreview(String signatureBase64) {
    Uint8List? bytes;

    try {
      bytes = base64Decode(signatureBase64);
    } catch (_) {
      bytes = null;
    }

    if (bytes == null) {
      return const Text('Signature enregistrée illisible.');
    }

    return Container(
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ds.AppColors.border),
      ),
      child: Image.memory(bytes, fit: BoxFit.contain),
    );
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title : option non disponible pour le moment.')),
    );
  }

  Future<void> confirmResetLocalData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Réinitialiser les données locales ?'),
          content: const Text(
            'Cette action efface les patients, le patient actif et l’historique des évaluations stockés sur cet appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await RgpdLocalService.deleteAllLocalData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Données locales réinitialisées')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final practitionerComplete = practitioner.isComplete;
    final practitionerSubtitle = practitionerComplete
        ? [
            practitioner.fullName,
            if (practitioner.exerciceAccesDirect) 'Accès direct',
          ].join(' · ')
        : 'Nom, RPPS, ADELI, cabinet.';

    return Scaffold(
      backgroundColor: ds.AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                spacing.AppSpacing.md,
                spacing.AppSpacing.sm,
                spacing.AppSpacing.md,
                112,
              ),
              children: [
                buildSectionLabel('PROFIL MK'),
                const SizedBox(height: 6),
                settingCard(
                  icon: practitionerComplete
                      ? Icons.verified_user_outlined
                      : Icons.badge_outlined,
                  iconColor: ds.AppColors.primary,
                  title: 'Informations MK',
                  subtitle: practitionerSubtitle,
                  onTap: showPractitionerDialog,
                ),
                settingCard(
                  icon: Icons.draw_outlined,
                  iconColor: ds.AppColors.primary,
                  title: 'Signature praticien',
                  subtitle: practitioner.hasSignature
                      ? 'Signature enregistrée pour les prescriptions.'
                      : 'Signature pour prescriptions et PDF.',
                  onTap: showPractitionerSignatureDialog,
                ),

                const SizedBox(height: 8),
                buildSectionLabel('CONFIDENTIALITÉ'),
                const SizedBox(height: 6),
                settingCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: ds.AppColors.primary,
                  title: 'Consentement et confidentialité',
                  subtitle: 'Gestion RGPD et consentement patient.',
                  onTap: () => showComingSoon(
                    context,
                    'Consentement et confidentialité',
                  ),
                ),
                settingCard(
                  icon: Icons.storage_rounded,
                  iconColor: ds.AppColors.teal,
                  title: 'Stockage local sécurisé',
                  subtitle: 'Aucune transmission automatique.',
                  onTap: () =>
                      showComingSoon(context, 'Stockage local sécurisé'),
                ),
                settingCard(
                  icon: Icons.ios_share_outlined,
                  iconColor: ds.AppColors.raspberryDark,
                  title: 'Export pseudonymisé',
                  subtitle: 'Données cliniques sans nom ni prénom.',
                  onTap: () => showAnonymousRecordsExport(context),
                ),

                const SizedBox(height: 8),
                buildSectionLabel('EXPORTS'),
                const SizedBox(height: 6),
                settingCard(
                  icon: Icons.picture_as_pdf_outlined,
                  iconColor: ds.AppColors.dangerDark,
                  title: 'Préférences PDF',
                  subtitle: 'Couleur, impression et signature.',
                  onTap: () => showComingSoon(context, 'Préférences PDF'),
                ),
                settingCard(
                  icon: Icons.table_chart_outlined,
                  iconColor: ds.AppColors.primary,
                  title: 'CSV statistiques',
                  subtitle: 'Exporter les évaluations pseudonymisées.',
                  onTap: GlobalStatisticsCsvService.exportGlobalStatisticsCsv,
                ),

                const SizedBox(height: 8),
                buildSectionLabel('APPLICATION'),
                const SizedBox(height: 6),
                settingCard(
                  icon: Icons.medical_information_outlined,
                  iconColor: ds.AppColors.warningDark,
                  title: 'Accès direct',
                  subtitle: 'Conditions réglementaires et séances.',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AccessDirectSettingsScreen(),
                      ),
                    );
                  },
                ),
                settingCard(
                  icon: Icons.dark_mode_outlined,
                  iconColor: ds.AppColors.raspberryDark,
                  title: 'Apparence',
                  subtitle: 'Thème, taille de texte et affichage.',
                  onTap: () => showComingSoon(context, 'Apparence'),
                ),
                settingCard(
                  icon: Icons.restart_alt_rounded,
                  iconColor: ds.AppColors.danger,
                  title: 'Réinitialisation locale',
                  subtitle: 'Effacer les données stockées sur cet appareil.',
                  onTap: confirmResetLocalData,
                ),

                const SizedBox(height: 8),
                buildVersionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget settingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: ds.AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: ds.AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        leading: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: ds.AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ds.AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: ds.AppColors.borderStrong),
        boxShadow: AppShadows.soft,
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Drapeaux Rouges — Version 1.0.0',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
