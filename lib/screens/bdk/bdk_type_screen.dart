import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'bdk_detail_screen.dart';

class BDKTypeScreen extends StatelessWidget {
  const BDKTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _BDKItem(
        title: 'BDK Lombalgie',
        subtitle: 'Douleur lombaire, fonction, mobilité et vigilance.',
        icon: Icons.back_hand_outlined,
        color: Color(0xFF2563EB),
      ),
      _BDKItem(
        title: 'BDK Cervicalgie',
        subtitle: 'Rachis cervical, douleur, mobilité et signes associés.',
        icon: Icons.accessibility_new_outlined,
        color: Color(0xFFDB2777),
      ),
      _BDKItem(
        title: 'BDK Cheville',
        subtitle: 'Entorse, appui, marche, stabilité et reprise fonctionnelle.',
        icon: Icons.directions_walk_outlined,
        color: Color(0xFF16A34A),
      ),
      _BDKItem(
        title: 'BDK Respiratoire',
        subtitle: 'Dyspnée, ventilation, encombrement et tolérance à l’effort.',
        icon: Icons.air_outlined,
        color: Color(0xFF7C3AED),
      ),
      _BDKItem(
        title: 'BDK Personne âgée',
        subtitle: 'Autonomie, équilibre, chutes et capacités fonctionnelles.',
        icon: Icons.elderly_outlined,
        color: Color(0xFFF97316),
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
                const _BDKTypeHeader(),
                const SizedBox(height: AppSpacing.sm),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _BDKTypeCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => BDKDetailScreen(title: item.title),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _BDKInfoBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BDKTypeHeader extends StatelessWidget {
  const _BDKTypeHeader();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.medicalBlue, AppColors.primaryDark],
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
              if (!compact) ...[
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
                    Icons.fact_check_outlined,
                    color: AppColors.textOnDark,
                    size: 24,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type de BDK',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: compact ? 21 : 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Sélectionnez le contexte clinique à structurer.',
                        style: TextStyle(
                          color: AppColors.textOnDark.withValues(alpha: 0.82),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                _HeaderChip(
                  icon: Icons.auto_awesome,
                  label: 'Auto-remplissage',
                ),
                _HeaderChip(icon: Icons.picture_as_pdf_outlined, label: 'PDF'),
                _HeaderChip(icon: Icons.edit_note_rounded, label: 'Structuré'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BDKItem {
  const _BDKItem({
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

class _BDKTypeCard extends StatelessWidget {
  const _BDKTypeCard({required this.item, required this.onTap});

  final _BDKItem item;
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
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSuccess,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Text(
                        'AUTO',
                        style: TextStyle(
                          color: AppColors.successDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
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

class _BDKInfoBanner extends StatelessWidget {
  const _BDKInfoBanner();

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
          Icon(Icons.picture_as_pdf_outlined, color: AppColors.successDark),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Chaque type ouvre le même formulaire structuré, adapté au contexte clinique choisi.',
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
