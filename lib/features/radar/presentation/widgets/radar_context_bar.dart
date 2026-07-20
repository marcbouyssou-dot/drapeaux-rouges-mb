import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
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
    final borderRadius = BorderRadius.circular(RadarRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: borderRadius,
        boxShadow: RadarShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadarSpacing.xl),
        child: Row(
          children: [
            const _RadarNeutralAvatar(),
            const SizedBox(width: RadarSpacing.cardGap),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName, style: RadarTextStyles.body),
                  const SizedBox(height: RadarSpacing.xs),
                  Text(status, style: RadarTextStyles.caption),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: RadarColors.blueGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarNeutralAvatar extends StatelessWidget {
  const _RadarNeutralAvatar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.background,
        borderRadius: BorderRadius.circular(RadarRadius.small),
      ),
      child: const SizedBox.square(
        dimension: 48,
        child: Icon(Icons.person_outline, color: RadarColors.slate, size: 24),
      ),
    );
  }
}
