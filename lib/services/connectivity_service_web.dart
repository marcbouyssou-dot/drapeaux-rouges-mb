// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

void platformStartListening(void Function(bool isOnline) onChanged) {
  html.window.onOnline.listen((_) => onChanged(true));
  html.window.onOffline.listen((_) => onChanged(false));
}

bool platformIsOnline() => html.window.navigator.onLine ?? true;
