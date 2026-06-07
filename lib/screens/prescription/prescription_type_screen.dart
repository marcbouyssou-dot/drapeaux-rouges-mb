import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
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
    final items = [
      _PrescriptionItem(
        title: 'Rééducation',
        subtitle:
            'Pathologie, objectifs, fréquence et durée de prise en charge.',
        icon: Icons.accessibility_new_rounded,
        color: Color(0xFF2563EB),
      ),
      _PrescriptionItem(
        title: 'Matériel',
        subtitle: 'Aide technique, orthèse, contention ou matériel clinique.',
        icon: Icons.medical_services_outlined,
        color: Color(0xFF7C3AED),
      ),
      _PrescriptionItem(
        title: 'Examens',
        subtitle: 'Avis, examen complémentaire ou orientation à discuter.',
        icon: Icons.biotech_outlined,
        color: Color(0xFFF97316),
      ),
      _PrescriptionItem(
        title: 'Conseils',
        subtitle: 'Recommandations, surveillance et consignes patient.',
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xFF0F766E),
      ),
      _PrescriptionItem(
        title: 'Autres',
        subtitle: 'Document libre ou prescription personnalisée.',
        icon: Icons.more_horiz_rounded,
        color: Color(0xFF64748B),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                120,
              ),
              children: [
                const _PrescriptionTypeHeader(),
                const SizedBox(height: AppSpacing.md),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PrescriptionTypeCard(
                      item: item,
                      onTap: () {
                        openPrescriptionScreen(context, item.title);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _PrescriptionInfoBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionTypeHeader extends StatelessWidget {
  const _PrescriptionTypeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.raspberry,
            AppColors.raspberryDark,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.textOnDark.withValues(alpha: 0.20),
                  ),
                ),
                child: IconButton(
                  tooltip: 'Retour',
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.textOnDark,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.textOnDark.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  Icons.library_books_outlined,
                  color: AppColors.textOnDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type de prescription',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Choisissez le document clinique à préparer.',
                      style: TextStyle(
                        color: AppColors.textOnDark.withValues(alpha: 0.82),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              _HeaderChip(icon: Icons.library_books_outlined, label: 'Modèles'),
              _HeaderChip(icon: Icons.picture_as_pdf_outlined, label: 'PDF'),
              _HeaderChip(icon: Icons.badge_outlined, label: 'Patient lié'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrescriptionItem {
  const _PrescriptionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _PrescriptionTypeCard extends StatelessWidget {
  const _PrescriptionTypeCard({required this.item, required this.onTap});

  final _PrescriptionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: item.color.withValues(alpha: 0.18)),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
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

class _PrescriptionInfoBanner extends StatelessWidget {
  const _PrescriptionInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: AppColors.raspberryDark),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Le type choisi configure les champs et les modèles rapides du formulaire.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.textOnDark.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.textOnDark.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textOnDark, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
