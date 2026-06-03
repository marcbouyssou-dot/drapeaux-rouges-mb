import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('local reset setting is wired to RGPD local data deletion', () {
    final source = File('lib/screens/settings_screen.dart').readAsStringSync();

    expect(source, contains('Future<void> confirmResetLocalData() async'));
    expect(source, contains('RgpdLocalService.deleteAllLocalData()'));
    expect(source, contains("title: 'Réinitialisation locale'"));
    expect(source, contains('onTap: confirmResetLocalData'));
  });
}
