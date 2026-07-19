import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarContextBar extends StatelessWidget {
  const RadarContextBar({
    super.key,
    required this.patientName,
    required this.status,
  });

  final String patientName;
  final String status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        border: Border.all(color: RadarColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadarSpacing.md,
          vertical: 12,
        ),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: RadarColors.success,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName, style: RadarTextStyles.sectionTitle),
                  const SizedBox(height: 2),
                  Text(status, style: RadarTextStyles.muted),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: RadarColors.mutedInk,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
