import 'package:flutter/widgets.dart';

class ClinicalResponsiveInfo {
  const ClinicalResponsiveInfo({
    required this.width,
    required this.height,
    required this.shortestSide,
  });

  factory ClinicalResponsiveInfo.fromConstraints(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    return ClinicalResponsiveInfo(
      width: width,
      height: height,
      shortestSide: width < height ? width : height,
    );
  }

  final double width;
  final double height;
  final double shortestSide;

  bool get isCompactPhone => width < 600 || shortestSide < 600;
  bool get isPhoneLandscape => isCompactPhone && width > height;
  bool get isTablet => width >= 600 && width < 900;
  bool get isDesktop => width >= 900;
  bool get isTabletOrDesktop => width >= 600;

  double get patientContentMaxWidth {
    if (isPhoneLandscape) return 620;
    if (isDesktop) return 960;
    if (isTablet) return 760;
    return 520;
  }

  EdgeInsets get patientPagePadding {
    if (isPhoneLandscape) {
      return const EdgeInsets.fromLTRB(12, 8, 12, 96);
    }
    if (isCompactPhone) {
      return const EdgeInsets.fromLTRB(14, 8, 14, 104);
    }
    return const EdgeInsets.fromLTRB(16, 10, 16, 112);
  }

  EdgeInsets get patientCardPadding {
    if (isPhoneLandscape) return const EdgeInsets.all(10);
    if (isCompactPhone) return const EdgeInsets.all(12);
    return const EdgeInsets.all(14);
  }
}
