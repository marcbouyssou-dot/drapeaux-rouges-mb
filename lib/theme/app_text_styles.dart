import 'package:flutter/material.dart';

class AppTextStyles {
  static const Color title = Color(0xFF0F172A);
  static const Color subtitle = Color(0xFF64748B);
  static const Color primary = Color(0xFF2563EB);

  static const TextStyle pageTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.9,
    height: 1.05,
    color: title,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    height: 1.35,
    color: subtitle,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
    color: title,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: title,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: subtitle,
  );
}
