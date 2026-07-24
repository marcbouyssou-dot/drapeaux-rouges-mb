import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarPageHeader extends StatelessWidget {
  const RadarPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null || trailing != null) ...[
          Row(
            children: [
              if (onBack != null)
                RadarPageBackButton(onPressed: onBack!)
              else
                const SizedBox.shrink(),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: RadarSpacing.xl),
        ],
        Text(title, style: RadarTextStyles.screenTitle),
        const SizedBox(height: RadarSpacing.sm),
        Text(subtitle, style: RadarTextStyles.secondary),
      ],
    );
  }
}

class RadarPageBackButton extends StatelessWidget {
  const RadarPageBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: 'Retour',
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      style: IconButton.styleFrom(
        backgroundColor: RadarColors.surface,
        foregroundColor: RadarColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadarRadius.small),
        ),
      ),
    );
  }
}
