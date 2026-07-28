import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radar registers a maintained application service worker', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();
    final worker = File('web/radar_service_worker.js').readAsStringSync();

    expect(bootstrap, contains("register('/radar_service_worker.js'"));
    expect(bootstrap, contains("updateViaCache: 'none'"));
    expect(worker, contains("const CACHE_VERSION = 'radar-app-v"));
    expect(worker, contains("caches.open(CACHE_VERSION)"));
    expect(worker, contains("request.mode === 'navigate'"));
    expect(worker, contains("networkFirst(request, '/index.html')"));
    expect(worker, contains("name.startsWith('radar-app-')"));
    expect(worker, isNot(contains('unregister()')));
  });

  test(
    'application shell contains the required generated Flutter resources',
    () {
      final worker = File('web/radar_service_worker.js').readAsStringSync();
      const requiredPaths = [
        '/',
        '/index.html',
        '/main.dart.js',
        '/flutter.js',
        '/flutter_bootstrap.js',
        '/manifest.json',
        '/assets/AssetManifest.bin',
        '/assets/FontManifest.json',
        '/assets/NOTICES',
        '/icons/Icon-192.png',
        '/icons/Icon-512.png',
      ];

      for (final path in requiredPaths) {
        expect(worker, contains("'$path'"), reason: '$path must be precached');
      }
    },
  );

  test('Netlify does not HTTP-cache the worker or application entry point', () {
    final config = File('netlify.toml').readAsStringSync();

    expect(config, contains('for = "/radar_service_worker.js"'));
    expect(config, contains('Service-Worker-Allowed = "/"'));
    expect(
      RegExp(
        r'for = "/radar_service_worker\.js"[\s\S]*?Cache-Control = "no-cache"',
      ).hasMatch(config),
      isTrue,
    );
    expect(
      RegExp(
        r'for = "/index\.html"[\s\S]*?Cache-Control = "no-cache"',
      ).hasMatch(config),
      isTrue,
    );
  });
}
