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
    this.onTap,
  });

  final String patientName;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(RadarRadius.card);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RadarSpacing.xl,
        vertical: RadarSpacing.lg,
      ),
      child: Row(
        children: [
          const _RadarNeutralAvatar(),
          const SizedBox(width: RadarSpacing.lg),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: RadarTextStyles.contextTitle),
                const SizedBox(height: RadarSpacing.xs),
                Text(status, style: RadarTextStyles.contextSecondary),
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
    );

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: RadarColors.surfaceMuted,
            borderRadius: borderRadius,
            boxShadow: RadarShadows.card,
          ),
          child: content,
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
        color: RadarColors.blueGrey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadarRadius.small),
      ),
      child: const SizedBox.square(
        dimension: 36,
        child: Icon(Icons.person_outline, color: RadarColors.slate, size: 20),
      ),
    );
  }
}
