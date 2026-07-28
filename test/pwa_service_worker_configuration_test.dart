import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radar registers a maintained application service worker', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();
    final worker = File('web/radar_service_worker.js').readAsStringSync();

    expect(bootstrap, contains("'/radar_service_worker.js'"));
    expect(bootstrap, contains("scope: '/'"));
    expect(bootstrap, contains("updateViaCache: 'none'"));
    expect(bootstrap, contains('navigator.serviceWorker.ready'));
    expect(worker, contains("const CACHE_VERSION = 'radar-app-v3'"));
    expect(worker, contains("caches.open(CACHE_VERSION)"));
    expect(worker, contains("request.mode === 'navigate'"));
    expect(worker, contains("request.destination === 'document'"));
    expect(worker, contains("fetchLog('NAVIGATION_INTERCEPTED'"));
    expect(worker, contains("fetchLog('NAVIGATION_RESPONSE_SENT'"));
    expect(worker, contains('safeRequestHeaders(request.headers)'));
    expect(worker, contains('safeResponseHeaders(response.headers)'));
    expect(worker, contains('networkFirstNavigation(request, fetchId)'));
    expect(worker, contains("cache.match('/index.html')"));
    expect(worker, contains("name.startsWith('radar-app-')"));
    expect(worker, contains('self.clients.claim()'));
    expect(worker, isNot(contains('unregister()')));

    final navigationHandler = RegExp(
      r'async function networkFirstNavigation[\s\S]*?'
      r'\n}\n\nasync function cacheFirstStatic',
    ).firstMatch(worker)!.group(0)!;
    expect(navigationHandler, contains('offlineHtmlResponse()'));
    expect(navigationHandler, isNot(contains('Response.error()')));
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
        '/assets/AssetManifest.bin.json',
        '/assets/FontManifest.json',
        '/assets/NOTICES',
        '/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
        '/canvaskit/canvaskit.js',
        '/canvaskit/canvaskit.wasm',
        '/canvaskit/chromium/canvaskit.js',
        '/canvaskit/chromium/canvaskit.wasm',
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
    expect(config, contains('--no-web-resources-cdn'));
    expect(config, contains('rm -f build/web/flutter_service_worker.js'));
    expect(
      RegExp(
        r'for = "/radar_service_worker\.js"[\s\S]*?'
        r'Cache-Control = "no-cache, no-store, must-revalidate"',
      ).hasMatch(config),
      isTrue,
    );
    expect(
      RegExp(
        r'for = "/index\.html"[\s\S]*?'
        r'Cache-Control = "no-cache, no-store, must-revalidate"',
      ).hasMatch(config),
      isTrue,
    );
  });

  test('worker cannot be confused with the SPA fallback', () {
    final index = File('web/index.html').readAsStringSync();
    final worker = File('web/radar_service_worker.js').readAsStringSync();

    expect(worker, isNot(index));
    expect(worker, startsWith("'use strict';"));
    expect(index, contains('<!DOCTYPE html>'));
    expect(worker, isNot(contains('<!DOCTYPE html>')));
  });

  test('worker cache contains application code only', () {
    final worker = File('web/radar_service_worker.js').readAsStringSync();

    expect(worker, isNot(contains('patient')));
    expect(worker, isNot(contains('Hive')));
    expect(worker, isNot(contains('localStorage')));
    expect(worker, isNot(contains('indexedDB')));
  });

  test('release artifact is self-contained when a build is available', () {
    final buildDirectory = Directory('build/web');
    if (!buildDirectory.existsSync()) return;

    final workerFile = File('build/web/radar_service_worker.js');
    final indexFile = File('build/web/index.html');
    final bootstrapFile = File('build/web/flutter_bootstrap.js');
    expect(workerFile.existsSync(), isTrue);
    expect(indexFile.existsSync(), isTrue);
    expect(File('build/web/flutter_service_worker.js').existsSync(), isFalse);

    final worker = workerFile.readAsStringSync();
    final index = indexFile.readAsStringSync();
    final bootstrap = bootstrapFile.readAsStringSync();
    expect(worker, isNot(index));
    expect(worker, isNot(contains('unregister()')));
    expect(bootstrap, contains('"useLocalCanvasKit":true'));

    final paths = RegExp(
      r"^\s*'(/[^']+)',?$",
      multiLine: true,
    ).allMatches(worker).map((match) => match.group(1)!).toSet();
    for (final path in paths) {
      if (path == '/') continue;
      expect(
        File('build/web${Uri.decodeComponent(path)}').existsSync(),
        isTrue,
        reason: '$path must exist in the release artifact',
      );
    }
  });
}
