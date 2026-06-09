import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../prescription_screen.dart';

class PrescriptionTypeScreen extends StatelessWidget {
  const PrescriptionTypeScreen({super.key});

  void openPrescriptionScreen(BuildContext context, String type) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => PrescriptionScreen(initialPrescriptionType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.filledTonal(
                    tooltip: 'Retour',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...prescriptionTypeOptions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PrescriptionTypeCard(
                      item: item,
                      onTap: () => openPrescriptionScreen(context, item.title),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrescriptionTypeOption {
  const PrescriptionTypeOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
}

const prescriptionTypeOptions = [
  PrescriptionTypeOption(
    id: 'reeducation',
    title: 'Rééducation',
    icon: Icons.accessibility_new_rounded,
    color: Color(0xFF2563EB),
  ),
  PrescriptionTypeOption(
    id: 'materiel',
    title: 'Matériel',
    icon: Icons.medical_services_outlined,
    color: Color(0xFF7C3AED),
  ),
  PrescriptionTypeOption(
    id: 'examens',
    title: 'Examens',
    icon: Icons.biotech_outlined,
    color: Color(0xFFF97316),
  ),
  PrescriptionTypeOption(
    id: 'conseils',
    title: 'Conseils',
    icon: Icons.chat_bubble_outline_rounded,
    color: Color(0xFF0F766E),
  ),
  PrescriptionTypeOption(
    id: 'attestations',
    title: 'Attestations',
    icon: Icons.assignment_turned_in_outlined,
    color: Color(0xFFE11D48),
  ),
  PrescriptionTypeOption(
    id: 'autres',
    title: 'Autres',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF64748B),
  ),
];

class _PrescriptionTypeCard extends StatelessWidget {
  const _PrescriptionTypeCard({required this.item, required this.onTap});

  final PrescriptionTypeOption item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: compact ? 44 : 50,
                width: compact ? 44 : 50,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: item.color.withValues(alpha: 0.18)),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: compact ? 23 : 26,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.color,
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
