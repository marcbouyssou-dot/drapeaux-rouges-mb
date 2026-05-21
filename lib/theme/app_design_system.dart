import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color softBlue = Color(0xFFEFF6FF);

  static const Color successGreen = Color(0xFF16A34A);
  static const Color softGreen = Color(0xFFDCFCE7);

  static const Color warningOrange = Color(0xFFF97316);
  static const Color softOrange = Color(0xFFFFEDD5);

  static const Color dangerRed = Color(0xFFDC2626);
  static const Color softRed = Color(0xFFFEE2E2);

  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Colors.white;

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color border = Color(0xFFE2E8F0);
}

class AppSpacing {
  static const double screenPadding = 20;
  static const double cardPadding = 20;
  static const double cardRadius = 28;
  static const double sectionSpacing = 18;
  static const double buttonRadius = 22;
}

class AppShadows {
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}

class AppTextStyles {
  static const TextStyle screenTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}