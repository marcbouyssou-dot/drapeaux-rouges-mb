import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
import '../theme/radar_spacing.dart';

class RadarSurfaceCard extends StatelessWidget {
  const RadarSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RadarSpacing.xl),
    this.margin,
    this.color = RadarColors.surface,
    this.border,
    this.borderRadius,
    this.boxShadow,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(RadarRadius.card);
    final effectiveShadow = boxShadow ?? RadarShadows.card;

    final content = Padding(padding: padding, child: child);
    final decoration = BoxDecoration(
      color: color,
      borderRadius: effectiveBorderRadius,
      border: border,
      boxShadow: effectiveShadow,
    );

    final card = DecoratedBox(
      decoration: decoration,
      child: onTap == null
          ? content
          : Material(
              color: color,
              borderRadius: effectiveBorderRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: effectiveBorderRadius,
                child: content,
              ),
            ),
    );

    if (margin == null) {
      return card;
    }

    return Padding(padding: margin!, child: card);
  }
}
