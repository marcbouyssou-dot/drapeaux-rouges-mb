'use strict';

// Increment this version whenever the application shell changes. Activating the
// new worker removes every older Radar application cache.
const CACHE_VERSION = 'radar-app-v1';
const APP_SHELL = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/manifest.json',
  '/favicon.png',
  '/assets/AssetManifest.bin',
  '/assets/FontManifest.json',
  '/assets/NOTICES',
  '/assets/fonts/MaterialIcons-Regular.otf',
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
  event.waitUntil(
    caches.open(CACHE_VERSION).then((cache) => cache.addAll(APP_SHELL)),
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((names) =>
        Promise.all(
          names
            .filter((name) => name.startsWith('radar-app-') && name !== CACHE_VERSION)
            .map((name) => caches.delete(name)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (request.mode === 'navigate') {
    event.respondWith(networkFirst(request, '/index.html'));
    return;
  }

  if (APP_SHELL.includes(url.pathname)) {
    event.respondWith(cacheFirst(request));
  }
});

async function cacheFirst(request) {
  const cached = await caches.match(request, { ignoreSearch: true });
  if (cached) return cached;

  const response = await fetch(request);
  if (response.ok) {
    const cache = await caches.open(CACHE_VERSION);
    await cache.put(request, response.clone());
  }
  return response;
}

async function networkFirst(request, fallbackPath) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(CACHE_VERSION);
      await cache.put('/index.html', response.clone());
    }
    return response;
  } catch (_) {
    return (await caches.match(request, { ignoreSearch: true })) ||
      (await caches.match(fallbackPath)) ||
      Response.error();
  }
}
