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
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: RadarSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: RadarColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: RadarTextStyles.body)),
              const Icon(Icons.arrow_forward, color: RadarColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
