import 'package:flutter/material.dart';

import '../../theme/app_design_system.dart';
import '../../widgets/design_system/clinical_list_item.dart';
import '../history_screen.dart';
import '../settings_screen.dart';

class FollowUpScreen extends StatelessWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 120),
          children: [
            ClinicalListItem(
              title: 'Historique',
              subtitle: 'Retrouver les évaluations, prescriptions et BDK.',
              icon: Icons.history_outlined,
              color: AppColors.primaryBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            ClinicalListItem(
              title: 'Dashboard',
              subtitle: 'Statistiques locales et suivi global.',
              icon: Icons.bar_chart_outlined,
              color: Colors.indigo,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dashboard à venir.')),
                );
              },
            ),
            ClinicalListItem(
              title: 'Réglages',
              subtitle: 'Profil MK, préférences et configuration.',
              icon: Icons.settings_outlined,
              color: Colors.blueGrey,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
