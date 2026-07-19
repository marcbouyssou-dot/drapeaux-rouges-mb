import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarDecisionCard extends StatelessWidget {
  const RadarDecisionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.vigilance,
  });

  final String title;
  final String subtitle;
  final String body;
  final String vigilance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        border: Border.all(color: RadarColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadarSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: RadarColors.success,
              size: 28,
            ),
            const SizedBox(height: RadarSpacing.md),
            Text(title, style: RadarTextStyles.title),
            const SizedBox(height: RadarSpacing.sm),
            Text(subtitle, style: RadarTextStyles.body),
            const SizedBox(height: RadarSpacing.md),
            Text(body, style: RadarTextStyles.muted),
            const SizedBox(height: RadarSpacing.sm),
            Text(vigilance, style: RadarTextStyles.muted),
          ],
        ),
      ),
    );
  }
}
