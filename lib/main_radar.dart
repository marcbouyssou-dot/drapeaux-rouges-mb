import 'package:flutter/material.dart';

import 'features/radar/presentation/radar_demo_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
