import 'dart:convert';
import 'dart:io';

const _buildWebPath = 'build/web';
const _outputFileName = 'pwa_service_worker.js';
const _cachePrefix = 'drapeaux-rouges-pwa';

void main() {
  final buildDir = Directory(_buildWebPath);
  if (!buildDir.existsSync()) {
    stderr.writeln('Build web directory not found: $_buildWebPath');
    exitCode = 1;
    return;
  }

  final resources = _collectResources(buildDir);
  final version = _buildCacheVersion(buildDir, resources);
  final worker = _renderServiceWorker(version, resources);

  File('$_buildWebPath/$_outputFileName').writeAsStringSync(worker);
  stdout.writeln(
    'Generated $_buildWebPath/$_outputFileName with '
    '${resources.length} cached resources ($version).',
  );
}

List<String> _collectResources(Directory buildDir) {
  final resources = <String>{'/'};

  for (final entity in buildDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;

    final relativePath = entity.path
        .substring(buildDir.path.length + 1)
        .replaceAll(Platform.pathSeparator, '/');

    if (_shouldExclude(relativePath)) continue;
    resources.add(relativePath);
  }

  final ordered = resources.toList()..sort();
  return ordered;
}

bool _shouldExclude(String relativePath) {
  final name = relativePath.split('/').last;
  if (name.startsWith('.')) return true;
  if (relativePath.endsWith('.map')) return true;
  if (relativePath == _outputFileName) return true;
  if (relativePath == 'flutter_service_worker.js') return true;
  return false;
}

String _buildCacheVersion(Directory buildDir, List<String> resources) {
  var hash = 0x811c9dc5;

  for (final resource in resources) {
    hash = _hashString(hash, resource);
    if (resource == '/') continue;

    final file = File('${buildDir.path}/$resource');
    if (!file.existsSync()) continue;

    hash = _hashBytes(hash, file.readAsBytesSync());
  }

  return '$_cachePrefix-${hash.toRadixString(16).padLeft(8, '0')}';
}

int _hashString(int hash, String value) => _hashBytes(hash, utf8.encode(value));

int _hashBytes(int hash, List<int> bytes) {
  var current = hash;
  for (final byte in bytes) {
    current ^= byte;
    current = (current * 0x01000193) & 0xffffffff;
  }
  return current;
}

String _renderServiceWorker(String version, List<String> resources) {
  final encodedResources = const JsonEncoder.withIndent(
    '  ',
  ).convert(resources);

  return '''
'use strict';

const CACHE_NAME = '$version';
const CACHE_PREFIX = '$_cachePrefix-';
const APP_SHELL = $encodedResources;

self.addEventListener('install', (event) => {
  self.skipWaiting();

  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(
        APP_SHELL.map((url) => new Request(url, { cache: 'reload' }))
      );
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key.startsWith(CACHE_PREFIX) && key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;

  if (request.method !== 'GET') {
    return;
  }

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) {
    return;
  }

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put('index.html', copy));
          return response;
        })
        .catch(async () => {
          return (
            (await caches.match('index.html')) ||
            (await caches.match('/')) ||
            new Response(
              `<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Drapeaux Rouges - Offline</title>
  <style>
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      background: #032052;
      color: #ffffff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      text-align: center;
    }
    main {
      width: min(88vw, 420px);
      line-height: 1.5;
    }
    a {
      color: #7db7ff;
    }
  </style>
</head>
<body>
  <main>
    <h1>Mode hors connexion</h1>
    <p>Le service worker projet est actif, mais l'app shell Flutter n'a pas pu être relu depuis le cache.</p>
    <p><a href="/offline-debug.html">Ouvrir le diagnostic offline</a></p>
  </main>
</body>
</html>`,
              { headers: { 'Content-Type': 'text/html; charset=utf-8' } }
            )
          );
        })
    );
    return;
  }

  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) {
        return cached;
      }

      return fetch(request).then((response) => {
        if (response && response.ok) {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, copy));
        }
        return response;
      });
    })
  );
});
''';
}
