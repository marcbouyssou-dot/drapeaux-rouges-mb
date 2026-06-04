import 'package:flutter/material.dart';

class AppShadows {
  static const card = [
    BoxShadow(blurRadius: 20, offset: Offset(0, 8), color: Color(0x11000000)),
  ];

  static const soft = [
    BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14004A8F)),
  ];

  static const elevated = [
    BoxShadow(blurRadius: 24, offset: Offset(0, 12), color: Color(0x1A2563EB)),
  ];
}
