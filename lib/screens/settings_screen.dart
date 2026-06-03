import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/practitioner_profile.dart';
import '../services/global_statistics_csv_service.dart';
import '../services/patient_record_service.dart';
import '../services/practitioner_profile_service.dart';
import '../services/rgpd_local_service.dart';
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

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Informations MK'),
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
      await loadPractitioner();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations MK enregistrées')),
      );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
          children: [
            buildCompactHeader(),
            const SizedBox(height: 14),

            buildSectionLabel('PROFIL MK'),
            const SizedBox(height: 10),
            settingCard(
              icon: practitionerComplete
                  ? Icons.verified_user_outlined
                  : Icons.badge_outlined,
              iconColor: const Color(0xFF2563EB),
              title: 'Informations MK',
              subtitle: practitionerComplete
                  ? practitioner.fullName
                  : 'Nom, RPPS, ADELI, cabinet.',
              onTap: showPractitionerDialog,
            ),
            settingCard(
              icon: Icons.draw_outlined,
              iconColor: const Color(0xFF2563EB),
              title: 'Signature praticien',
              subtitle: 'Signature pour prescriptions et PDF.',
              onTap: () => showComingSoon(context, 'Signature praticien'),
            ),

            const SizedBox(height: 14),
            buildSectionLabel('CONFIDENTIALITÉ'),
            const SizedBox(height: 10),
            settingCard(
              icon: Icons.verified_user_outlined,
              iconColor: const Color(0xFF2563EB),
              title: 'Consentement et confidentialité',
              subtitle: 'Gestion RGPD et consentement patient.',
              onTap: () =>
                  showComingSoon(context, 'Consentement et confidentialité'),
            ),
            settingCard(
              icon: Icons.storage_rounded,
              iconColor: const Color(0xFF0F766E),
              title: 'Stockage local sécurisé',
              subtitle: 'Aucune transmission automatique.',
              onTap: () => showComingSoon(context, 'Stockage local sécurisé'),
            ),
            settingCard(
              icon: Icons.ios_share_outlined,
              iconColor: const Color(0xFF7C3AED),
              title: 'Export pseudonymisé',
              subtitle: 'Données cliniques sans nom ni prénom.',
              onTap: () => showAnonymousRecordsExport(context),
            ),

            const SizedBox(height: 14),
            buildSectionLabel('EXPORTS'),
            const SizedBox(height: 10),
            settingCard(
              icon: Icons.picture_as_pdf_outlined,
              iconColor: const Color(0xFFDC2626),
              title: 'Préférences PDF',
              subtitle: 'Couleur, impression et signature.',
              onTap: () => showComingSoon(context, 'Préférences PDF'),
            ),
            settingCard(
              icon: Icons.table_chart_outlined,
              iconColor: const Color(0xFF2563EB),
              title: 'CSV statistiques',
              subtitle: 'Exporter les évaluations pseudonymisées.',
              onTap: GlobalStatisticsCsvService.exportGlobalStatisticsCsv,
            ),

            const SizedBox(height: 14),
            buildSectionLabel('APPLICATION'),
            const SizedBox(height: 10),
            settingCard(
              icon: Icons.medical_information_outlined,
              iconColor: const Color(0xFFEA580C),
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
              iconColor: const Color(0xFF7C3AED),
              title: 'Apparence',
              subtitle: 'Thème, taille de texte et affichage.',
              onTap: () => showComingSoon(context, 'Apparence'),
            ),
            settingCard(
              icon: Icons.restart_alt_rounded,
              iconColor: const Color(0xFFEF4444),
              title: 'Réinitialisation locale',
              subtitle: 'Effacer les données stockées sur cet appareil.',
              onTap: confirmResetLocalData,
            ),

            const SizedBox(height: 14),
            buildVersionCard(),
          ],
        ),
      ),
    );
  }

  Widget buildCompactHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFF334155)],
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Réglages et données locales',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
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
            color: const Color(0xFFF8FAFC),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Drapeaux Rouges — Version 1.0.0',
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
