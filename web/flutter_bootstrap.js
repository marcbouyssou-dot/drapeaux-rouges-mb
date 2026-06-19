{{flutter_js}}
{{flutter_build_config}}
(() => {
  function startupOverlay() {
    let overlay = document.getElementById('startup-debug-overlay');
    if (!overlay) {
      overlay = document.createElement('div');
      overlay.id = 'startup-debug-overlay';
      overlay.style.position = 'fixed';
      overlay.style.zIndex = '2147483647';
      overlay.style.top = 'max(12px, env(safe-area-inset-top))';
      overlay.style.left = '12px';
      overlay.style.right = '12px';
      overlay.style.padding = '10px 12px';
      overlay.style.borderRadius = '14px';
      overlay.style.background = 'rgba(225, 29, 72, 0.94)';
      overlay.style.color = '#ffffff';
      overlay.style.fontFamily =
        '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif';
      overlay.style.fontSize = '13px';
      overlay.style.fontWeight = '800';
      overlay.style.lineHeight = '1.25';
      overlay.style.textAlign = 'center';
      overlay.style.boxShadow = '0 10px 28px rgba(0, 0, 0, 0.24)';
      overlay.style.pointerEvents = 'none';
      document.body.appendChild(overlay);
    }
    return overlay;
  }

  function showStartupStep(step) {
    startupOverlay().textContent = step;
    window.__flutterStartupStep = step;
  }

  function showStartupError(error, url) {
    const message = error && error.message ? error.message : String(error);
    const stack = error && error.stack ? `\n${error.stack}` : '';
    startupOverlay().textContent =
      `BOOTSTRAP ERROR: ${message}\nURL: ${url || window.__flutterStartupUrl || location.href}${stack}`;
  }

  window.addEventListener('error', (event) => {
    showStartupError(
      event.error || event.message || 'Erreur JavaScript',
      event.filename,
    );
  });

  window.addEventListener('unhandledrejection', (event) => {
    showStartupError(event.reason || 'Promise rejetée', window.__flutterStartupUrl);
  });

  async function startFlutter() {
    try {
      showStartupStep('BOOTSTRAP START');
      window.__flutterStartupUrl = 'main.dart.js';
      showStartupStep('BEFORE FLUTTER LOADER');

      await _flutter.loader.load({
        onEntrypointLoaded: async (engineInitializer) => {
          window.__flutterStartupUrl = 'Flutter engine';
          showStartupStep('BEFORE ENGINE LOAD');

          const appRunner = await engineInitializer.initializeEngine();
          showStartupStep('BEFORE APP RUNNER');

          showStartupStep('BEFORE RUN APP');
          await appRunner.runApp();
          showStartupStep('AFTER RUN APP');
        },
      });
    } catch (error) {
      showStartupError(error, window.__flutterStartupUrl);
    }
  }

  startFlutter();
})();
