import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'services/secure_hive_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  debugPrint('[BOOT] main() START');
  WidgetsFlutterBinding.ensureInitialized();

  await initializeApp();

  debugPrint('[BOOT] runApp()');
  runApp(const RedFlagsApp());
}

Future<void> initializeApp() async {
  debugPrint('[BOOT] initializeApp() START');
  debugPrint('[BOOT] CONFIGURING ORIENTATION');
  await _configureSmartphoneOrientation();
  debugPrint('[BOOT] ORIENTATION OK');

  debugPrint('[BOOT] INITIALIZING STORAGE');
  await SecureHiveService.initFlutter();
  debugPrint('[BOOT] STORAGE OK');
  debugPrint('[BOOT] initializeApp() OK');
}

Future<void> _configureSmartphoneOrientation() async {
  if (kIsWeb) return;

  final platform = defaultTargetPlatform;
  final isMobilePlatform =
      platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  if (!isMobilePlatform) return;

  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) return;

  final view = views.first;
  final logicalSize = view.physicalSize / view.devicePixelRatio;
  final isSmartphone = logicalSize.shortestSide < 600;
  if (!isSmartphone) {
    await SystemChrome.setPreferredOrientations([]);
    return;
  }

  // Smartphones stay in portrait; tablets, desktop and web keep full rotation.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class RedFlagsApp extends StatelessWidget {
  const RedFlagsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accès Direct MK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthGate(),
    );
  }
}
