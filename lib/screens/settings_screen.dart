import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/practitioner_profile.dart';
import '../services/global_statistics_csv_service.dart';
import '../services/patient_record_service.dart';
import '../services/practitioner_profile_service.dart';

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
            child: Text(
              const JsonEncoder.withIndent('  ').convert(data),
            ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title : fonctionnalité à venir.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final practitionerComplete = practitioner.isComplete;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
          children: [
            
            buildHeroCard(),
            const SizedBox(height: 26),

            buildSectionLabel('PROFIL MK'),
            const SizedBox(height: 12),
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

            const SizedBox(height: 22),
            buildSectionLabel('CONFIDENTIALITÉ'),
            const SizedBox(height: 12),
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

            const SizedBox(height: 22),
            buildSectionLabel('EXPORTS'),
            const SizedBox(height: 12),
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
              title: 'CSV statistiques pseudonymisées',
              subtitle: 'Exporter les évaluations locales.',
              onTap: GlobalStatisticsCsvService.exportGlobalStatisticsCsv,
            ),
            settingCard(
              icon: Icons.history_rounded,
              iconColor: const Color(0xFF0F766E),
              title: 'Historique et exports',
              subtitle: 'Retrouver les bilans et exports.',
              onTap: () => showComingSoon(context, 'Historique et exports'),
            ),

            const SizedBox(height: 22),
            buildSectionLabel('APPLICATION'),
            const SizedBox(height: 12),
            settingCard(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xFF7C3AED),
              title: 'Apparence',
              subtitle: 'Thème, taille de texte et affichage.',
              onTap: () => showComingSoon(context, 'Apparence'),
            ),
            settingCard(
  icon: Icons.medical_information_outlined,
  iconColor: const Color(0xFFEA580C),
  title: 'Accès direct',
  subtitle: 'Conditions réglementaires, diagnostic préalable et séances.',
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AccessDirectSettingsScreen(),
      ),
    );
  },
),
            settingCard(
              icon: Icons.restart_alt_rounded,
              iconColor: const Color(0xFFEF4444),
              title: 'Réinitialisation locale',
              subtitle: 'Effacer les données stockées sur cet appareil.',
              onTap: () => showComingSoon(context, 'Réinitialisation locale'),
            ),

            const SizedBox(height: 22),
            buildVersionCard(),
          ],
        ),
      ),
    );
  }
  Widget buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 34, 26, 34),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF64748B),
                  Color(0xFF334155),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF334155)
                      .withValues(alpha: 0.20),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 58,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'PARAMÈTRES',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Profil praticien, confidentialité, exports et préférences de l’application.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w700,
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
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
        ),
        title: Text(
  title,
  style: const TextStyle(
    color: Color(0xFF0F172A),
    fontSize: 15.5,
    fontWeight: FontWeight.w900,
  ),
),
subtitle: Padding(
  padding: const EdgeInsets.only(top: 3),
  child: Text(
    subtitle,
    style: const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
  ),
),
        trailing: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(13),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_rounded,
            color: Color(0xFF2563EB),
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Drapeaux Rouges — Version 1.0.0',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}