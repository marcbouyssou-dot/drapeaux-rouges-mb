import { writeFileSync } from 'node:fs';

const endpoint = process.argv[2] ?? 'http://127.0.0.1:9223';
const targetUrl = process.argv[3] ?? 'http://127.0.0.1:8765/';
const waitMillis = Number(process.argv[4] ?? 12000);
const emulateOffline = process.argv[5] === 'offline';

const pages = await fetch(`${endpoint}/json`).then((response) => response.json());
const page = pages.find((candidate) => candidate.type === 'page');
if (!page) throw new Error('No Chrome page target is available.');

const socket = new WebSocket(page.webSocketDebuggerUrl);
const pending = new Map();
const requests = new Set();
const navigationResponses = [];
let sequence = 0;

socket.addEventListener('message', (event) => {
  const message = JSON.parse(event.data);
  if (message.id && pending.has(message.id)) {
    const { resolve, reject } = pending.get(message.id);
    pending.delete(message.id);
    if (message.error) reject(new Error(message.error.message));
    else resolve(message.result);
    return;
  }

  if (message.method === 'Network.requestWillBeSent') {
    requests.add(message.params.request.url);
  }
  if (
    message.method === 'Network.responseReceived' &&
    message.params.type === 'Document'
  ) {
    navigationResponses.push({
      url: message.params.response.url,
      status: message.params.response.status,
      mimeType: message.params.response.mimeType,
      fromServiceWorker: message.params.response.fromServiceWorker,
    });
  }
});

await new Promise((resolve, reject) => {
  socket.addEventListener('open', resolve, { once: true });
  socket.addEventListener('error', reject, { once: true });
});

function command(method, params = {}) {
  const id = ++sequence;
  socket.send(JSON.stringify({ id, method, params }));
  return new Promise((resolve, reject) => {
    pending.set(id, { resolve, reject });
  });
}

await command('Network.enable');
await command('Runtime.enable');
await command('Page.enable');
if (emulateOffline) {
  await command('Network.emulateNetworkConditions', {
    offline: true,
    latency: 0,
    downloadThroughput: 0,
    uploadThroughput: 0,
  });
}
await command('Page.navigate', { url: targetUrl });
await new Promise((resolve) => setTimeout(resolve, waitMillis));

const evaluation = await command('Runtime.evaluate', {
  expression: `(async () => {
    const registration = await navigator.serviceWorker.getRegistration('/');
    const diagnostic = navigator.serviceWorker.controller
      ? await new Promise((resolve) => {
          const timeout = setTimeout(
            () => resolve({ error: 'diagnostic timeout' }),
            3000,
          );
          const listener = (event) => {
            if (event.data?.type !== 'RADAR_PWA_DIAGNOSTIC_RESULT') return;
            clearTimeout(timeout);
            navigator.serviceWorker.removeEventListener('message', listener);
            resolve(event.data.diagnostic);
          };
          navigator.serviceWorker.addEventListener('message', listener);
          navigator.serviceWorker.controller.postMessage({
            type: 'RADAR_PWA_DIAGNOSTIC',
            navigationUrl: location.href,
          });
        })
      : null;
    const cacheNames = await caches.keys();
    const cacheEntries = {};
    for (const name of cacheNames) {
      const cache = await caches.open(name);
      cacheEntries[name] = (await cache.keys()).map((request) => request.url);
    }
    return {
      href: location.href,
      title: document.title,
      bodyText: document.body.innerText,
      flutterViewCount: document.querySelectorAll('flutter-view').length,
      canvasCount: document.querySelectorAll('canvas').length,
      controlled: Boolean(navigator.serviceWorker.controller),
      controllerUrl: navigator.serviceWorker.controller?.scriptURL ?? null,
      registrationScope: registration?.scope ?? null,
      activeWorkerUrl: registration?.active?.scriptURL ?? null,
      activeWorkerState: registration?.active?.state ?? null,
      diagnostic,
      cacheNames,
      cacheEntries,
    };
  })()`,
  awaitPromise: true,
  returnByValue: true,
});

const screenshot = await command('Page.captureScreenshot', { format: 'png' });
const screenshotPath = process.argv[6];
if (screenshotPath) {
  writeFileSync(screenshotPath, Buffer.from(screenshot.data, 'base64'));
}

console.log(
  JSON.stringify(
    {
      page: evaluation.result.value,
      requests: [...requests].sort(),
      navigationResponses,
    },
    null,
    2,
  ),
);
socket.close();
