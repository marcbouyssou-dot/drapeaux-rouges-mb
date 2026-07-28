'use strict';

const CACHE_VERSION = 'radar-app-v2';
const NAVIGATION_TIMEOUT_MS = 3000;
const DEBUG = true;

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

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (request.mode === 'navigate') {
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
  try {
    const response = await fetchWithTimeout(request, NAVIGATION_TIMEOUT_MS);
    if (isCacheable(response)) {
      const cache = await caches.open(CACHE_VERSION);
      await cache.put('/index.html', response.clone());
      log('navigation served from network', request.url);
      return response;
    }
  } catch (error) {
    log('navigation network unavailable', request.url);
  }

  const cache = await caches.open(CACHE_VERSION);
  const cachedNavigation = await cache.match(normalizedPath(request));
  const fallback = cachedNavigation ?? (await cache.match('/index.html'));
  if (fallback) {
    log('navigation served from cache', request.url);
    return fallback;
  }

  console.error('[Radar SW] navigation fallback missing', request.url);
  return Response.error();
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
