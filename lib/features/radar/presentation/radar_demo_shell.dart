import 'package:flutter/material.dart';

import 'screens/radar_cockpit_screen.dart';
import 'theme/radar_theme.dart';

class RadarDemoShell extends StatelessWidget {
  const RadarDemoShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RadarTheme.lightTheme,
      child: const RadarCockpitScreen(),
    );
  }
}
