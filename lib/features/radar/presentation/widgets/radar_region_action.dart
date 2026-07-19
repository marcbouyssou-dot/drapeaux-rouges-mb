import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarRegionAction extends StatelessWidget {
  const RadarRegionAction({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? RadarColors.successSoft : RadarColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(
            horizontal: RadarSpacing.md,
            vertical: RadarSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? RadarColors.primary : RadarColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.circle_outlined,
                color: selected ? RadarColors.primary : RadarColors.mutedInk,
                size: 20,
              ),
              const SizedBox(width: RadarSpacing.sm),
              Expanded(child: Text(label, style: RadarTextStyles.body)),
            ],
          ),
        ),
      ),
    );
  }
}
