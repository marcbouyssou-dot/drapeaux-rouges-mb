import 'package:flutter/material.dart';

import '../history_screen.dart';
import '../settings_screen.dart';

class HistorySettingsScreen extends StatelessWidget {
  const HistorySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 120),
          child: Column(
            children: [
              const SizedBox(height: 18),
              _bigButton(
                context: context,
                icon: Icons.history_rounded,
                title: 'HISTORIQUE',
                subtitle: 'Consulter les évaluations précédentes',
                buttonText: 'Ouvrir l’historique',
                backgroundColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFBFDBFE),
                mainColor: const Color(0xFF2563EB),
                page: const HistoryScreen(),
              ),
              const SizedBox(height: 18),
              _bigButton(
                context: context,
                icon: Icons.settings_rounded,
                title: 'PARAMÈTRES',
                subtitle: 'Profil praticien, RGPD, exports et préférences',
                buttonText: 'Ouvrir les paramètres',
                backgroundColor: const Color(0xFFF8FAFC),
                borderColor: const Color(0xFFE2E8F0),
                mainColor: const Color(0xFF64748B),
                page: const SettingsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color backgroundColor,
    required Color borderColor,
    required Color mainColor,
    required Widget page,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
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
                    colors: [
                      mainColor.withValues(alpha: 0.78),
                      mainColor,
                    ],
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
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 58,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
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
}