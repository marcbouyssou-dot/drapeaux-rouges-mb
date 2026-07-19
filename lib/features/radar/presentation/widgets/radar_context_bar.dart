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
        padding: const EdgeInsets.all(RadarSpacing.md),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: RadarColors.surfaceMuted,
              child: Icon(Icons.person_outline, color: RadarColors.primary),
            ),
            const SizedBox(width: RadarSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName, style: RadarTextStyles.sectionTitle),
                  const SizedBox(height: RadarSpacing.xs),
                  Text(status, style: RadarTextStyles.muted),
                ],
              ),
            ),
            const Icon(Icons.more_horiz, color: RadarColors.mutedInk),
          ],
        ),
      ),
    );
  }
}
