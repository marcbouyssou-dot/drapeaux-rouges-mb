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

    final String imagePath = isLarge
        ? 'assets/images/banner_urps_large.png'
        : 'assets/images/banner_urps_compact.png';

    final double aspectRatio = isLarge ? 1600 / 520 : 1600 / 300;

    return Padding(
      padding: EdgeInsets.only(
        top: width < 600 ? 10 : 14,
        bottom: width < 600 ? 18 : 22,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          width < 600 ? 28 : 32,
        ),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}