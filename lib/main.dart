import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'services/patient_session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PatientSessionService.loadPatient();

  runApp(const RedFlagsApp());
}

class RedFlagsApp extends StatelessWidget {
  const RedFlagsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accès Direct MK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
    );
  }
}