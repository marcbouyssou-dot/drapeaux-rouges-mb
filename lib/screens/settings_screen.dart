import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/practitioner_profile.dart';
import '../services/global_statistics_csv_service.dart';
import '../services/patient_record_service.dart';
import '../services/practitioner_profile_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/urps_banner.dart';

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
      builder: (_) {
        return AlertDialog(
          title: const Text('Export statistique pseudonymisé'),
          content: SingleChildScrollView(
            child: Text(
              const JsonEncoder.withIndent('  ').convert(data),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
        title: const Text('Profil professionnel'),
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
      const SnackBar(
        content: Text('Profil professionnel enregistré'),
      ),
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
      SnackBar(
        content: Text('$title : fonctionnalité à venir.'),
      ),
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
            const UrpsBanner(isLarge: false),
            buildTitle(),
            const SizedBox(height: 22),
            buildHeroCard(),
            const SizedBox(height: 24),
            buildSectionLabel('PROFIL PROFESSIONNEL'),
            const SizedBox(height: 12),
            settingCard(
              context: context,
              icon: practitionerComplete
                  ? Icons.verified_user_outlined
                  : Icons.badge_outlined,
              title: 'Informations MK',
              subtitle: practitionerComplete
                  ? practitioner.fullName
                  : 'Nom, prénom, adresse, ADELI, RPPS pour les prescriptions.',
              onTap: showPractitionerDialog,
            ),
            const SizedBox(height: 26),
            buildSectionLabel('CONFIDENTIALITÉ'),
            const SizedBox(height: 12),
            settingCard(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: 'Confidentialité RGPD',
              subtitle: 'Données nominatives conservées localement.',
              onTap: () => showComingSoon(context, 'Confidentialité RGPD'),
            ),
            settingCard(
              context: context,
              icon: Icons.cloud_off_outlined,
              title: 'Protection des données',
              subtitle: 'Aucune transmission automatique.',
              onTap: () => showComingSoon(context, 'Protection des données'),
            ),
            settingCard(
              context: context,
              icon: Icons.cloud_outlined,
              title: 'Export statistique pseudonymisé',
              subtitle: 'Données cliniques sans nom ni prénom.',
              onTap: () => showAnonymousRecordsExport(context),
            ),
            settingCard(
              context: context,
              icon: Icons.table_chart_outlined,
              title: 'CSV statistiques pseudonymisées',
              subtitle: 'Exporter toutes les évaluations locales en CSV.',
              onTap: GlobalStatisticsCsvService.exportGlobalStatisticsCsv,
            ),
            const SizedBox(height: 26),
            buildSectionLabel('PARAMÈTRES CLINIQUES'),
            const SizedBox(height: 12),
            settingCard(
              context: context,
              icon: Icons.medical_information_outlined,
              title: 'Usage clinique',
              subtitle: 'Aide au raisonnement clinique.',
              onTap: () => showComingSoon(context, 'Usage clinique'),
            ),
            settingCard(
              context: context,
              icon: Icons.picture_as_pdf_outlined,
              title: 'Exports PDF',
              subtitle: 'PDF couleur ou impression noir et blanc.',
              onTap: () => showComingSoon(context, 'Exports PDF'),
            ),
            settingCard(
              context: context,
              icon: Icons.analytics_outlined,
              title: 'Statistiques locales',
              subtitle: 'Analyse locale dans Historique.',
              onTap: () => showComingSoon(context, 'Statistiques locales'),
            ),
            const SizedBox(height: 30),
            buildVersionCard(),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Réglages', style: AppTextStyles.pageTitle),
        SizedBox(height: 4),
        Text(
          'Configuration de l’application',
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }

  Widget buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
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
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Paramètres de l’application',
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

  Widget buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget settingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        leading: Container(
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
        title: Text(title, style: AppTextStyles.cardTitle),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: AppTextStyles.cardSubtitle),
        ),
        trailing: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF2FF),
            Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0xFFBFDBFE)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.verified_rounded,
            color: Color(0xFF2563EB),
            size: 34,
          ),
          SizedBox(height: 12),
          Text(
            'Drapeaux Rouges',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}