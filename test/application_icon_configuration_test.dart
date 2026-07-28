import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'all Radar platforms derive their launcher icon from the shared asset',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('image_path: "assets/icons/app_icon.png"'));
      expect(
        pubspec,
        contains(
          'adaptive_icon_foreground: '
          '"assets/icons/app_icon_foreground.png"',
        ),
      );
      expect(pubspec, contains('adaptive_icon_background: "#F8FAFC"'));
      expect(pubspec, contains('web:\n    generate: true'));
      expect(pubspec, contains('macos:\n    generate: true'));

      for (final path in [
        'web/favicon.png',
        'web/icons/Icon-192.png',
        'web/icons/Icon-512.png',
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
        'android/app/src/main/res/drawable-xxxhdpi/'
            'ic_launcher_foreground.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/'
            'Icon-App-1024x1024@1x.png',
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png',
      ]) {
        final icon = File(path);
        expect(icon.existsSync(), isTrue, reason: '$path must exist');
        expect(
          icon.lengthSync(),
          greaterThan(0),
          reason: '$path must not be empty',
        );
      }
    },
  );

  test('the PWA manifest uses the pearl Radar application colors', () {
    final manifest = File('web/manifest.json').readAsStringSync();

    expect(manifest, contains('"background_color": "#F8FAFC"'));
    expect(manifest, contains('"theme_color": "#3B82F6"'));
    expect(manifest, isNot(contains('ACCÈS DIRECT')));
    expect(manifest, isNot(contains('URPS')));
  });
}
