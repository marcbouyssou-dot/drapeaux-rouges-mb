import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarActionCard extends StatelessWidget {
  const RadarActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RadarColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(RadarSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: RadarColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: RadarColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: RadarColors.primary),
                ),
              ),
              const SizedBox(width: RadarSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: RadarTextStyles.sectionTitle),
                    const SizedBox(height: RadarSpacing.xs),
                    Text(subtitle, style: RadarTextStyles.muted),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: RadarColors.mutedInk),
            ],
          ),
        ),
      ),
    );
  }
}
