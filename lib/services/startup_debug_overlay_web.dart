// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

void platformSetStartupDebugStep(String step) {
  final overlay =
      html.document.getElementById('startup-debug-overlay') ??
      _createStartupDebugOverlay();

  overlay.text = step;
}

html.Element _createStartupDebugOverlay() {
  final overlay = html.DivElement()
    ..id = 'startup-debug-overlay'
    ..text = 'STARTUP DEBUG'
    ..style.position = 'fixed'
    ..style.zIndex = '2147483647'
    ..style.top = '12px'
    ..style.left = '12px'
    ..style.right = '12px'
    ..style.padding = '10px 12px'
    ..style.borderRadius = '14px'
    ..style.backgroundColor = 'rgba(225, 29, 72, 0.94)'
    ..style.color = '#ffffff'
    ..style.fontFamily =
        '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif'
    ..style.fontSize = '13px'
    ..style.fontWeight = '800'
    ..style.lineHeight = '1.25'
    ..style.textAlign = 'center'
    ..style.pointerEvents = 'none';

  html.document.body?.append(overlay);
  return overlay;
}
