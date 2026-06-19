import 'dart:convert';
import 'dart:io';

const _buildWebPath = 'build/web';
const _outputFileName = 'pwa_service_worker.js';
const _cachePrefix = 'drapeaux-rouges-pwa';
const _lastBuildIdFileName = '.last_build_id';
const _criticalAppShellResources = [
  'flutter_bootstrap.js',
  '/flutter_bootstrap.js',
  'flutter.js',
  '/flutter.js',
  'main.dart.js',
  '/main.dart.js',
];

void main() {
  final buildDir = Directory(_buildWebPath);
  if (!buildDir.existsSync()) {
    stderr.writeln('Build web directory not found: $_buildWebPath');
    exitCode = 1;
    return;
  }

  final buildId = _buildId();
  _writeLastBuildId(buildDir, buildId);
  _versionBootstrap(buildDir, buildId);

  final resources = _collectResources(buildDir);
  final version = _buildCacheVersion(buildDir, resources, buildId);
  final worker = _renderServiceWorker(version, buildId, resources);

  File('$_buildWebPath/$_outputFileName').writeAsStringSync(worker);
  stdout.writeln(
    'Generated $_buildWebPath/$_outputFileName with '
    '${resources.length} cached resources ($version, buildId=$buildId).',
  );
}

String _buildId() {
  final timestamp = DateTime.now().toUtc().toIso8601String();
  return timestamp.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
}

void _writeLastBuildId(Directory buildDir, String buildId) {
  File('${buildDir.path}/$_lastBuildIdFileName').writeAsStringSync(buildId);
}

void _versionBootstrap(Directory buildDir, String buildId) {
  final indexFile = File('${buildDir.path}/index.html');
  if (!indexFile.existsSync()) return;

  final html = indexFile.readAsStringSync();
  final versioned = html.replaceAllMapped(
    RegExp(r'src="flutter_bootstrap\.js(?:\?v=[^"]*)?"'),
    (_) => 'src="flutter_bootstrap.js?v=$buildId"',
  );

  if (versioned != html) {
    indexFile.writeAsStringSync(versioned);
  }
}

List<String> _collectResources(Directory buildDir) {
  final resources = <String>{'/'};
  resources.addAll(_criticalAppShellResources);

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
  if (relativePath == _lastBuildIdFileName) return true;
  if (relativePath == _outputFileName) return true;
  if (relativePath == 'flutter_service_worker.js') return true;
  return false;
}

String _buildCacheVersion(
  Directory buildDir,
  List<String> resources,
  String buildId,
) {
  var hash = 0x811c9dc5;
  hash = _hashString(hash, buildId);

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

String _renderServiceWorker(
  String version,
  String buildId,
  List<String> resources,
) {
  final encodedResources = const JsonEncoder.withIndent(
    '  ',
  ).convert(resources);
  final encodedVersionedResources = const JsonEncoder.withIndent('  ').convert([
    'flutter_bootstrap.js?v=$buildId',
    '/flutter_bootstrap.js?v=$buildId',
  ]);

  return '''
'use strict';

const CACHE_NAME = '$version';
const CACHE_PREFIX = '$_cachePrefix-';
const SERVICE_WORKER_VERSION = '$version';
const BUILD_ID = '$buildId';
const APP_SHELL = $encodedResources;
const VERSIONED_APP_SHELL = $encodedVersionedResources;

async function cacheMatchIgnoringSearch(request) {
  const directMatch = await caches.match(request);
  if (directMatch) {
    return directMatch;
  }

  const url = new URL(request.url || request, self.location.origin);
  if (url.origin !== self.location.origin) {
    return null;
  }

  const cleanHref = new URL(url.href);
  cleanHref.search = '';
  url.search = '';
  const cleanPath = url.pathname.startsWith('/')
      ? url.pathname.substring(1)
      : url.pathname;
  const candidates = [
    cleanHref.toString(),
    url.pathname,
    cleanPath,
  ];

  for (const candidate of candidates) {
    const match = await caches.match(candidate);
    if (match) {
      return match;
    }
  }

  return null;
}

function offlineFetchErrorResponse(requestUrl, cacheMatched) {
  const safeUrl = JSON.stringify(requestUrl);
  const safeCacheMatched = JSON.stringify(cacheMatched ? 'oui' : 'non');
  const body =
    '(() => {' +
    'const overlay = document.getElementById("startup-debug-overlay") || document.body.appendChild(document.createElement("div"));' +
    'overlay.id = "startup-debug-overlay";' +
    'overlay.style.position = "fixed";' +
    'overlay.style.zIndex = "2147483647";' +
    'overlay.style.top = "max(12px, env(safe-area-inset-top))";' +
    'overlay.style.left = "12px";' +
    'overlay.style.right = "12px";' +
    'overlay.style.padding = "10px 12px";' +
    'overlay.style.borderRadius = "14px";' +
    'overlay.style.background = "rgba(225, 29, 72, 0.94)";' +
    'overlay.style.color = "#ffffff";' +
    'overlay.style.fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, sans-serif";' +
    'overlay.style.fontSize = "13px";' +
    'overlay.style.fontWeight = "800";' +
    'overlay.style.lineHeight = "1.25";' +
    'overlay.style.textAlign = "center";' +
    'overlay.textContent = "BOOTSTRAP ERROR: fetch offline impossible\\\\nURL: " + ' + safeUrl + ' + "\\\\nCache match: " + ' + safeCacheMatched + ';' +
    '})();';

  return new Response(body, {
    status: 504,
    headers: { 'Content-Type': 'application/javascript; charset=utf-8' }
  });
}

self.addEventListener('install', (event) => {
  self.skipWaiting();

  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(
        APP_SHELL.concat(VERSIONED_APP_SHELL).map((url) => new Request(url, { cache: 'reload' }))
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
      .then(() => self.clients.matchAll({ type: 'window' }))
      .then((clients) => {
        clients.forEach((client) => {
          client.postMessage({
            type: 'PWA_SERVICE_WORKER_ACTIVE',
            cacheName: CACHE_NAME,
            buildId: BUILD_ID,
            version: SERVICE_WORKER_VERSION
          });
        });
      })
  );
});

self.addEventListener('message', (event) => {
  if (!event.data || event.data.type !== 'PWA_DEBUG_VERSION') {
    return;
  }

  if (event.source) {
    event.source.postMessage({
      type: 'PWA_DEBUG_VERSION_RESPONSE',
      cacheName: CACHE_NAME,
      buildId: BUILD_ID,
      version: SERVICE_WORKER_VERSION
    });
  }
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
            (await cacheMatchIgnoringSearch('index.html')) ||
            (await cacheMatchIgnoringSearch('/')) ||
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
    cacheMatchIgnoringSearch(request).then((cached) => {
      if (cached) {
        return cached;
      }

      return fetch(request).then((response) => {
        if (response && response.ok) {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, copy));
        }
        return response;
      }).catch(async () => {
        const cachedAfterFailure = await cacheMatchIgnoringSearch(request);
        if (cachedAfterFailure) {
          return cachedAfterFailure;
        }

        if (request.destination === 'script' || url.pathname.endsWith('.js')) {
          return offlineFetchErrorResponse(url.href, false);
        }

        return new Response('Offline fetch failed: ' + url.href, {
          status: 504,
          headers: { 'Content-Type': 'text/plain; charset=utf-8' }
        });
      });
    })
  );
});
''';
}
