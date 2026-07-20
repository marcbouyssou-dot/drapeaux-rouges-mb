import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarRegionAction extends StatelessWidget {
  const RadarRegionAction({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(RadarRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: borderRadius,
        boxShadow: RadarShadows.card,
      ),
      child: Material(
        color: RadarColors.surface,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RadarSpacing.cardGap,
              vertical: RadarSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(child: Text(label, style: RadarTextStyles.body)),
                const Icon(
                  Icons.chevron_right,
                  color: RadarColors.blueGrey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
