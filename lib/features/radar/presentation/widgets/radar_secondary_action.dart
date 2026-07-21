import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_text_styles.dart';

class RadarSecondaryAction extends StatelessWidget {
  const RadarSecondaryAction({
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
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: RadarColors.primaryDark,
          side: const BorderSide(color: RadarColors.border),
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
