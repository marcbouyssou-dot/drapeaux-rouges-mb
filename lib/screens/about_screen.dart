import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          infoHeader(),
          const SizedBox(height: 18),
          infoCard(
            icon: Icons.person_outline,
            title: 'Editeur',
            text: 'Application drapeaux_rouges_MB.',
          ),
          infoCard(
            icon: Icons.health_and_safety_outlined,
            title: 'Usage',
            text: 'Outil professionnel d aide au reperage des drapeaux rouges.',
          ),
          infoCard(
            icon: Icons.warning_amber_rounded,
            title: 'Prudence',
            text:
                'Cette application ne pose pas de diagnostic medical et ne remplace pas une evaluation par un professionnel de sante.',
          ),
          infoCard(
            icon: Icons.privacy_tip_outlined,
            title: 'RGPD',
            text:
                'Ne jamais saisir de donnees nominatives. Utiliser uniquement un code patient pseudonymise.',
          ),
          infoCard(
            icon: Icons.info_outline,
            title: 'Version',
            text: 'drapeaux_rouges_MB - Version 1.0.0',
          ),
        ],
      ),
    );
  }

  Widget infoHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1E40AF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.medical_information_rounded,
            color: Colors.white,
            size: 46,
          ),
          SizedBox(height: 18),
          Text(
            'drapeaux_rouges_MB',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Application clinique de reperage rapide',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 30),
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
                  text,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.4,
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