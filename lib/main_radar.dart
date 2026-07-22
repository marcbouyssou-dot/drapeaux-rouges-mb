import 'package:flutter/material.dart';

import 'features/radar/presentation/radar_demo_shell.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radar',
      home: RadarDemoShell(),
    );
  }
}
