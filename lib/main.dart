import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RedFlagsApp());
}

class RedFlagsApp extends StatelessWidget {
  const RedFlagsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drapeaux rouges MB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}