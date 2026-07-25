import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import 'radar_surface_card.dart';

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
    return RadarSurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          _RadarActionIcon(icon: icon, accentColor: accentColor),
          const SizedBox(width: RadarSpacing.cardGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RadarTextStyles.question),
                const SizedBox(height: RadarSpacing.sm),
                Text(subtitle, style: RadarTextStyles.secondary),
                if (description != null) ...[
                  const SizedBox(height: RadarSpacing.sm),
                  Text(description!, style: RadarTextStyles.caption),
                ],
              ],
            ),
          ),
          const SizedBox(width: RadarSpacing.lg),
          const Icon(
            Icons.chevron_right,
            color: RadarColors.blueGrey,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _RadarActionIcon extends StatelessWidget {
  const _RadarActionIcon({required this.icon, required this.accentColor});

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadarRadius.small),
      ),
      child: SizedBox.square(
        dimension: 48,
        child: Icon(icon, color: accentColor, size: 24),
      ),
    );
  }
}
