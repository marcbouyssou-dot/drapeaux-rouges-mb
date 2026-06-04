import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: AppShadows.soft,
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
          color: AppColors.primary,
          onTap: onPatientTap,
        ),
        const SizedBox(height: AppSpacing.md - 4),
        HomeDesktopActionButton(
          icon: Icons.description_outlined,
          title: 'BDK',
          subtitle: 'Bilan diagnostic kinésithérapique',
          color: const Color(0xFF0F766E),
          onTap: onBdkTap,
        ),
        const SizedBox(height: AppSpacing.md - 4),
        HomeDesktopActionButton(
          icon: Icons.medication_liquid_outlined,
          title: 'Prescription',
          subtitle: 'Ordonnance et recommandations',
          color: AppColors.raspberry,
          onTap: onPrescriptionTap,
        ),
      ],
    );
  }
}
