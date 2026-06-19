{{flutter_js}}
{{flutter_build_config}}
(() => {
  const overlay = document.getElementById('startup-debug-overlay');
  if (overlay) {
    overlay.textContent = 'BOOTSTRAP START';
  }
})();
_flutter.loader.load();
