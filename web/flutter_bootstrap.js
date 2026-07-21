{{flutter_js}}
{{flutter_build_config}}

_flutter.loader
  .load({
    onEntrypointLoaded: async (engineInitializer) => {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    },
  })
  .catch((error) => {
    console.error('Flutter bootstrap failed', error);
  });
