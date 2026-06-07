import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class HomeDesktopActionButton extends StatelessWidget {
  const HomeDesktopActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl + 2),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.11), AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl + 2),
            border: Border.all(color: color.withValues(alpha: 0.20)),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppRadius.xl - 2),
                  border: Border.all(color: color.withValues(alpha: 0.24)),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppRadius.md + 1),
                  border: Border.all(color: color.withValues(alpha: 0.12)),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.70),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeToolbarItem extends StatelessWidget {
  const HomeToolbarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surfaceBlue,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: const Color(0xFFC9DDF4)),
            ),
            child: Icon(icon, color: AppColors.medicalBlue, size: 16),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.medicalBlue,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeToolbarDivider extends StatelessWidget {
  const HomeToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: AppColors.borderStrong);
  }
}
