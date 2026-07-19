import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarQuestionOption extends StatelessWidget {
  const RadarQuestionOption({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RadarColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: RadarSpacing.md),
          child: Row(
            children: [
              Expanded(child: Text(label, style: RadarTextStyles.body)),
              const Icon(
                Icons.chevron_right,
                color: RadarColors.mutedInk,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
