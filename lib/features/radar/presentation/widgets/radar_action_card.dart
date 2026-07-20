import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarActionCard extends StatelessWidget {
  const RadarActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    required this.icon,
    required this.onTap,
    this.accentColor = RadarColors.primary,
  });

  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RadarColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.symmetric(
            horizontal: RadarSpacing.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: RadarColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(icon, color: accentColor, size: 21),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: RadarTextStyles.sectionTitle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: RadarTextStyles.muted),
                    if (description != null) ...[
                      const SizedBox(height: 1),
                      Text(description!, style: RadarTextStyles.muted),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: RadarColors.mutedInk,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
