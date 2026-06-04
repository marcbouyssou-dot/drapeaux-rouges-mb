import 'package:flutter/material.dart';

import 'home_action_card.dart';

class HomeEvaluationShortcutRow extends StatelessWidget {
  const HomeEvaluationShortcutRow({
    super.key,
    required this.onPatientTap,
    required this.onBdkTap,
    required this.onPrescriptionTap,
  });

  final VoidCallback onPatientTap;
  final VoidCallback onBdkTap;
  final VoidCallback onPrescriptionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E6F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004A8F).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: HomeToolbarItem(
              icon: Icons.person_outline_rounded,
              title: 'Patient',
              subtitle: 'Dossier',
              onTap: onPatientTap,
            ),
          ),
          const HomeToolbarDivider(),
          Expanded(
            child: HomeToolbarItem(
              icon: Icons.description_outlined,
              title: 'BDK',
              subtitle: 'Bilan',
              onTap: onBdkTap,
            ),
          ),
          const HomeToolbarDivider(),
          Expanded(
            child: HomeToolbarItem(
              icon: Icons.medication_liquid_outlined,
              title: 'Prescription',
              subtitle: 'Ordonnance',
              onTap: onPrescriptionTap,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeDesktopQuickActions extends StatelessWidget {
  const HomeDesktopQuickActions({
    super.key,
    required this.onPatientTap,
    required this.onBdkTap,
    required this.onPrescriptionTap,
  });

  final VoidCallback onPatientTap;
  final VoidCallback onBdkTap;
  final VoidCallback onPrescriptionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeDesktopActionButton(
          icon: Icons.person_outline_rounded,
          title: 'Patient',
          subtitle: 'Dossier patient et consentement',
          color: const Color(0xFF2563EB),
          onTap: onPatientTap,
        ),
        const SizedBox(height: 12),
        HomeDesktopActionButton(
          icon: Icons.description_outlined,
          title: 'BDK',
          subtitle: 'Bilan diagnostic kinésithérapique',
          color: const Color(0xFF0F766E),
          onTap: onBdkTap,
        ),
        const SizedBox(height: 12),
        HomeDesktopActionButton(
          icon: Icons.medication_liquid_outlined,
          title: 'Prescription',
          subtitle: 'Ordonnance et recommandations',
          color: const Color(0xFFE0005B),
          onTap: onPrescriptionTap,
        ),
      ],
    );
  }
}
