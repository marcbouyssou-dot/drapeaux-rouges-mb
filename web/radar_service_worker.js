'use strict';

const CACHE_VERSION = 'radar-app-v3';
const NAVIGATION_TIMEOUT_MS = 3000;
const DEBUG = true;
const fetchDiagnostics = [];

// This list is derived from the release build and from the requests observed
// between index.html and Radar's first rendered screen.
const CRITICAL_RESOURCES = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/manifest.json',
  '/favicon.png',
  '/assets/AssetManifest.bin',
  '/assets/AssetManifest.bin.json',
  '/assets/FontManifest.json',
  '/assets/NOTICES',
  '/assets/fonts/MaterialIcons-Regular.otf',
  '/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  '/assets/shaders/ink_sparkle.frag',
  '/assets/shaders/stretch_effect.frag',
  '/assets/assets/fonts/Roboto-Bold.ttf',
  '/assets/assets/fonts/Roboto-Regular.ttf',
  '/assets/assets/icons/app_icon.png',
  '/assets/assets/icons/app_icon_foreground.png',
  '/assets/assets/icons/urps_pictogram_bordeaux.png',
  '/assets/assets/icons/urps_pictogram_official.png',
  '/assets/assets/icons/urps_pictogram_official_transparent.png',
  '/assets/assets/images/app_header_banner.png',
  '/assets/assets/images/banner_urps_compact.png',
  '/assets/assets/images/banner_urps_large.png',
  '/assets/assets/images/login_background.png',
  '/assets/assets/images/login_full_mock.png',
  '/assets/assets/images/login_header_premium.png',
  '/assets/assets/images/logo_urps_modern.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/canvaskit/canvaskit.js',
  '/canvaskit/canvaskit.wasm',
  '/canvaskit/chromium/canvaskit.js',
  '/canvaskit/chromium/canvaskit.wasm',
];

self.addEventListener('install', (event) => {
  log('installation started', {
    cache: CACHE_VERSION,
    resources: CRITICAL_RESOURCES.length,
  });
  event.waitUntil(precacheCriticalResources());
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      for (const name of await caches.keys()) {
        if (name.startsWith('radar-app-') && name !== CACHE_VERSION) {
          await caches.delete(name);
          log('old cache removed', name);
        }
      }
      await self.clients.claim();
      log('worker activated', CACHE_VERSION);
    })(),
  );
});

self.addEventListener('message', (event) => {
  if (event.data?.type !== 'RADAR_PWA_DIAGNOSTIC') return;

  event.waitUntil(
    navigationCacheDiagnostic(event.data.navigationUrl).then((diagnostic) => {
      event.source?.postMessage({
        type: 'RADAR_PWA_DIAGNOSTIC_RESULT',
        diagnostic,
      });
    }),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  const details = requestDetails(request, url);

  if (request.method !== 'GET' || url.origin !== self.location.origin) {
    fetchLog('request ignored', { ...details, branch: 'ignored' });
    return;
  }

  const isNavigation =
    request.mode === 'navigate' || request.destination === 'document';
  if (isNavigation) {
    fetchLog('request received', { ...details, branch: 'navigation' });
    event.respondWith(networkFirstNavigation(request));
    return;
  }

  event.respondWith(cacheFirstStatic(request));
});

async function precacheCriticalResources() {
  const cache = await caches.open(CACHE_VERSION);

  for (const path of CRITICAL_RESOURCES) {
    try {
      const response = await fetch(path, { cache: 'reload' });
      if (!isCacheable(response)) {
        throw new Error(`HTTP ${response.status}`);
      }
      await cache.put(path, response);
    } catch (error) {
      console.error('[Radar SW] critical resource failed', path, error);
      throw error;
    }
  }

  log('critical resources cached', CRITICAL_RESOURCES.length);
}

async function networkFirstNavigation(request) {
  fetchLog('network attempt started', requestDetails(request));
  try {
    const response = await fetchWithTimeout(request, NAVIGATION_TIMEOUT_MS);
    fetchLog('network response received', {
      status: response.status,
      type: response.type,
      url: response.url,
    });
    if (isCacheable(response)) {
      const cache = await caches.open(CACHE_VERSION);
      await cache.put('/index.html', response.clone());
      fetchLog('final response', {
        source: 'network',
        status: response.status,
        type: response.type,
        url: response.url,
      });
      return response;
    }
  } catch (error) {
    fetchLog(
      error?.name === 'AbortError' ? 'network timeout' : 'network error',
      { url: request.url, error: String(error) },
    );
  }

  const cache = await caches.open(CACHE_VERSION);
  const exactKey = request.url;
  fetchLog('cache lookup', { key: exactKey, ignoreSearch: true });
  const exactMatch = await cache.match(request, { ignoreSearch: true });
  fetchLog('cache lookup result', responseDetails(exactMatch));

  const indexKey = absoluteUrl('/index.html');
  fetchLog('cache lookup', { key: indexKey, ignoreSearch: true });
  const indexMatch = await cache.match(indexKey, { ignoreSearch: true });
  fetchLog('cache lookup result', responseDetails(indexMatch));

  const rootKey = absoluteUrl('/');
  fetchLog('cache lookup', { key: rootKey, ignoreSearch: true });
  const rootMatch = await cache.match(rootKey, { ignoreSearch: true });
  fetchLog('cache lookup result', responseDetails(rootMatch));

  const fallback = exactMatch ?? indexMatch ?? rootMatch;
  if (fallback) {
    fetchLog('fallback selected', {
      source: exactMatch
        ? 'exact-request'
        : indexMatch
          ? 'index.html'
          : 'root',
      responseUrl: fallback.url,
    });
    fetchLog('final response', responseDetails(fallback));
    return fallback;
  }

  const emergencyResponse = offlineHtmlResponse();
  fetchLog('fallback selected', {
    source: 'minimal-offline-html',
    responseUrl: '',
  });
  fetchLog('final response', responseDetails(emergencyResponse));
  return emergencyResponse;
}

async function cacheFirstStatic(request) {
  const cache = await caches.open(CACHE_VERSION);
  const normalized = normalizedPath(request);
  const cached =
    (await cache.match(request, { ignoreSearch: true })) ??
    (await cache.match(normalized));
  if (cached) return cached;

  log('resource absent from cache', normalized);
  try {
    const response = await fetch(request);
    if (isCacheable(response)) {
      await cache.put(normalized, response.clone());
    }
    return response;
  } catch (_) {
    return Response.error();
  }
}

function normalizedPath(request) {
  const url = new URL(
    typeof request === 'string' ? request : request.url,
    self.location.origin,
  );
  return url.pathname;
}

function absoluteUrl(path) {
  return new URL(path, self.location.origin).href;
}

function requestDetails(request, parsedUrl = new URL(request.url)) {
  return {
    url: request.url,
    method: request.method,
    mode: request.mode,
    destination: request.destination,
    cache: request.cache,
    credentials: request.credentials,
    redirect: request.redirect,
    pathname: parsedUrl.pathname,
    search: parsedUrl.search,
  };
}

async function navigationCacheDiagnostic(navigationUrl = '/') {
  const cache = await caches.open(CACHE_VERSION);
  const origin = self.location.origin;
  const navigationRequest = new Request(
    new URL(navigationUrl, origin).href,
    { mode: 'same-origin' },
  );
  const checks = {
    matchRoot: await cache.match('/'),
    matchIndex: await cache.match('/index.html'),
    matchAbsoluteRoot: await cache.match(new Request(`${origin}/`)),
    matchAbsoluteIndex: await cache.match(
      new Request(`${origin}/index.html`),
    ),
    matchNavigationIgnoreSearch: await cache.match(navigationRequest, {
      ignoreSearch: true,
    }),
    matchIndexIgnoreSearch: await cache.match('/index.html', {
      ignoreSearch: true,
    }),
  };

  return {
    cache: CACHE_VERSION,
    origin,
    navigationUrl: navigationRequest.url,
    keys: (await cache.keys()).map((request) => ({
      url: request.url,
      pathname: new URL(request.url).pathname,
      search: new URL(request.url).search,
    })),
    matches: Object.fromEntries(
      Object.entries(checks).map(([name, response]) => [
        name,
        responseDetails(response),
      ]),
    ),
    fetchEvents: [...fetchDiagnostics],
  };
}

function responseDetails(response) {
  return response
    ? {
        found: true,
        status: response.status,
        type: response.type,
        url: response.url,
      }
    : { found: false };
}

function offlineHtmlResponse() {
  return new Response(
    '<!doctype html><html lang="fr"><meta charset="utf-8">' +
      '<meta name="viewport" content="width=device-width,initial-scale=1">' +
      '<title>Radar hors ligne</title>' +
      '<body><p>Radar ne peut pas charger ses ressources locales.</p></body>' +
      '</html>',
    {
      status: 200,
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'no-store',
      },
    },
  );
}

function isCacheable(response) {
  return response && response.ok && response.type !== 'error';
}

async function fetchWithTimeout(request, timeoutMillis) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMillis);
  try {
    return await fetch(request, { signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

function log(message, detail) {
  if (DEBUG) console.info('[Radar SW]', message, detail ?? '');
}

function fetchLog(message, detail) {
  fetchDiagnostics.push({
    at: new Date().toISOString(),
    message,
    detail: detail ?? null,
  });
  if (fetchDiagnostics.length > 100) fetchDiagnostics.shift();
  if (DEBUG) console.info('[Radar SW][fetch]', message, detail ?? '');
}
