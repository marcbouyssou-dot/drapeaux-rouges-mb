import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history exposes completed BDKs through a read-only detail screen', () {
    final historySource = File(
      'lib/screens/history_screen.dart',
    ).readAsStringSync();
    final detailSource = File(
      'lib/screens/bdk/bdk_history_detail_screen.dart',
    ).readAsStringSync();

    expect(historySource, contains('HistoryView.bdks'));
    expect(historySource, contains('BdkHistoryService.getHistory()'));
    expect(historySource, contains('BdkHistoryDetailScreen(item: item)'));
    expect(detailSource, contains('BdkPdfService.exportBdkPdf('));
    expect(detailSource, isNot(contains('BDKSessionService')));
    expect(detailSource, isNot(contains('BdkDraftService')));
  });

  test('completed snapshot is saved only after successful PDF export', () {
    final source = File(
      'lib/screens/bdk/bdk_detail_screen.dart',
    ).readAsStringSync();
    final exportIndex = source.indexOf('await BdkPdfService.exportBdkPdf(');
    final historyIndex = source.indexOf('await BdkHistoryService.save(');

    expect(exportIndex, greaterThanOrEqualTo(0));
    expect(historyIndex, greaterThan(exportIndex));
  });

  test('detail deletion is confirmed and reloads the BDK history', () {
    final historySource = File(
      'lib/screens/history_screen.dart',
    ).readAsStringSync();
    final detailSource = File(
      'lib/screens/bdk/bdk_history_detail_screen.dart',
    ).readAsStringSync();

    expect(detailSource, contains('showRadarDestructiveConfirmationDialog('));
    expect(detailSource, contains('BdkHistoryService.deleteById(item.id)'));
    expect(detailSource, contains('Navigator.pop(context, true)'));
    expect(
      historySource,
      contains('final deleted = await Navigator.push<bool>'),
    );
    expect(historySource, contains('if (deleted == true)'));
    expect(historySource, contains('await loadHistory()'));
  });
}
