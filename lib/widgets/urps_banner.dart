import 'package:flutter/material.dart';

class UrpsBanner extends StatelessWidget {
  const UrpsBanner({
    super.key,
    required this.isLarge,
  });

  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final double horizontalMargin = width < 600 ? 18 : 24;
    final double maxWidth = width >= 900 ? 1600 : double.infinity;

    final String imagePath = isLarge
        ? 'assets/images/banner_urps_large.png'
        : 'assets/images/banner_urps_compact.png';

    final double aspectRatio = isLarge ? 1600 / 520 : 1600 / 300;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        width < 600 ? 14 : 18,
        horizontalMargin,
        width < 600 ? 18 : 22,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width < 600 ? 22 : 26),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Image.asset(
                imagePath,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}