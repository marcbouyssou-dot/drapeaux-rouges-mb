import 'package:flutter/material.dart';

import 'features/radar/presentation/theme/radar_theme.dart';
import 'screens/auth/radar_auth_gate.dart';
import 'services/secure_hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureHiveService.initFlutter();
  runApp(const RadarPreviewApp());
}

class RadarPreviewApp extends StatelessWidget {
  const RadarPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radar',
      theme: RadarTheme.lightTheme,
      home: RadarAuthGate(),
    );
  }
}
