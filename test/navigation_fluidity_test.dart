import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main navigation ignores selection of the already active tab', () {
    final source = File(
      'lib/screens/main_navigation_screen.dart',
    ).readAsStringSync();

    expect(source, contains('if (index == currentIndex) return;'));
    expect(source, contains('final List<Widget> _pages = const ['));
  });

  test('cockpit and home serialize route openings', () {
    final cockpitSource = File(
      'lib/features/radar/presentation/screens/radar_cockpit_screen.dart',
    ).readAsStringSync();
    final homeSource = File('lib/screens/home_screen.dart').readAsStringSync();

    for (final source in [cockpitSource, homeSource]) {
      expect(source, contains('if (_navigationPending) return false;'));
      expect(source, contains('await Navigator.of(context).push<T>(route)'));
      expect(source, contains('_navigationPending = false;'));
    }
  });

  test('history deletion reloads remain conditional', () {
    final source = File('lib/screens/history_screen.dart').readAsStringSync();

    expect(
      RegExp(
        r'if \(deleted == true\) \{\s+await loadHistory\(\);',
      ).allMatches(source),
      hasLength(5),
    );
    expect(source, contains('if (_clearHistoryPending) return;'));
  });
}
