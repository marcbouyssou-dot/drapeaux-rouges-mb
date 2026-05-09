import 'package:flutter/material.dart';

import '../services/history_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> clearHistory(BuildContext context) async {
    await HistoryService.clearHistory();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historique supprime'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text('Reglages'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          settingCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Confidentialite RGPD',
            subtitle:
                'Ne jamais saisir de nom, prenom, date de naissance ou donnee directement identifiante.',
          ),
          settingCard(
            icon: Icons.medical_information_outlined,
            title: 'Usage clinique',
            subtitle:
                'Cette application est une aide au reperage. Elle ne pose pas de diagnostic medical.',
          ),
          settingCard(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: 'Drapeaux rouges MB - Version 1.0.0',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => clearHistory(context),
            icon: const Icon(Icons.delete_outline),
            label: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Supprimer tout l historique'),
            ),
          ),
        ],
      ),
    );
  }

  Widget settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}