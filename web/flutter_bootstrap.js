{{flutter_js}}
{{flutter_build_config}}

async function startRadar() {
  if ('serviceWorker' in navigator) {
    try {
      await navigator.serviceWorker.register('/radar_service_worker.js', {
        updateViaCache: 'none',
      });
    } catch (error) {
      console.warn('Radar service worker registration failed', error);
    }
  }

  await _flutter.loader.load({
    onEntrypointLoaded: async (engineInitializer) => {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    },
  });
}

startRadar().catch((error) => {
  console.error('Flutter bootstrap failed', error);
});
