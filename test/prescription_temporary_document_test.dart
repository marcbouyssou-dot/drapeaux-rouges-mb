import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/screens/prescription_screen.dart').readAsStringSync();
  });

  test('prescription keeps selected bytes instead of a File path', () {
    expect(source, contains('SelectedDocumentData? _selectedDocument;'));
    expect(source, isNot(contains('File? justificatifImage')));
    expect(source, contains('Image.memory('));
    expect(source, contains('_selectedDocument!.bytes'));
  });

  test('replacement reads the new capture before cleaning the old one', () {
    final pickStart = source.indexOf('Future<void> pickJustificatif()');
    final read = source.indexOf('SelectedDocumentData.read(', pickStart);
    final previous = source.indexOf(
      'final previousDocument = _selectedDocument;',
      read,
    );
    final cleanup = source.indexOf(
      'await previousDocument?.deleteTemporaryCameraFile();',
      previous,
    );
    final assignment = source.indexOf(
      '_selectedDocument = nextDocument;',
      cleanup,
    );

    expect(read, greaterThan(pickStart));
    expect(previous, greaterThan(read));
    expect(cleanup, greaterThan(previous));
    expect(assignment, greaterThan(cleanup));
  });

  test('PDF and history use the same selected document data', () {
    final exportStart = source.indexOf('Future<void> exportPdf()');
    final localReference = source.indexOf(
      'final document = _selectedDocument;',
      exportStart,
    );
    final historyBase64 = source.indexOf(
      'justificatifImageBase64: document?.base64Data',
      localReference,
    );
    final pdfBytes = source.indexOf(
      'justificatifImageBytes: document?.bytes',
      historyBase64,
    );
    final historySave = source.indexOf(
      'PrescriptionService.savePrescription(prescription)',
      pdfBytes,
    );
    final finallyBlock = source.indexOf('finally {', historySave);
    final cleanup = source.indexOf(
      'await _cleanupTemporaryDocument(document);',
      finallyBlock,
    );

    expect(localReference, greaterThan(exportStart));
    expect(historyBase64, greaterThan(localReference));
    expect(pdfBytes, greaterThan(historyBase64));
    expect(historySave, greaterThan(pdfBytes));
    expect(finallyBlock, greaterThan(historySave));
    expect(cleanup, greaterThan(finallyBlock));
  });

  test('manual removal, reset and dispose clean pending captures', () {
    expect(source, contains('Future<void> _clearSelectedDocument()'));
    expect(source, contains('onPressed: _clearSelectedDocument'));

    final resetStart = source.indexOf('Future<void> resetForm()');
    expect(
      source.indexOf('await _clearSelectedDocument();', resetStart),
      greaterThan(resetStart),
    );

    final disposeStart = source.indexOf('void dispose()');
    final pending = source.indexOf(
      'final pendingDocument = _selectedDocument;',
      disposeStart,
    );
    final detach = source.indexOf('_selectedDocument = null;', pending);
    final cleanup = source.indexOf(
      'unawaited(_cleanupTemporaryDocument(pendingDocument));',
      detach,
    );

    expect(pending, greaterThan(disposeStart));
    expect(detach, greaterThan(pending));
    expect(cleanup, greaterThan(detach));
  });
}
