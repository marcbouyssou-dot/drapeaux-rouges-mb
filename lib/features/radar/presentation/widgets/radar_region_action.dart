import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import 'radar_surface_card.dart';

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
    return RadarSurfaceCard(
      onTap: onTap,
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
    );
  }
}
