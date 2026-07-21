import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_text_styles.dart';

class RadarPrimaryButton extends StatelessWidget {
  const RadarPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: RadarColors.primary,
          foregroundColor: RadarColors.surface,
          disabledBackgroundColor: RadarColors.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
          ),
          textStyle: RadarTextStyles.secondary.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
