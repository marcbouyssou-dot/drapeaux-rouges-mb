import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BDK type screen aligns BDK owner before opening detail', () {
    final source = File(
      'lib/screens/bdk/bdk_type_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Future<void> _alignBdkOwnerWithCurrentPatient()'));
    expect(source, contains('RgpdLocalService.getCurrentPatient()'));
    expect(source, contains('BDKSessionService.isAssociatedWithPatient('));
    expect(source, contains('BDKSessionService.clear();'));
    expect(source, contains('BDKSessionService.associatePatient('));
    expect(
      source.indexOf('await _alignBdkOwnerWithCurrentPatient();'),
      lessThan(source.indexOf('Navigator.push(')),
    );
  });
}
