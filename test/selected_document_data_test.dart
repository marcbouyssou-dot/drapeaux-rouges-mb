import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drapeaux_rouges_mb/core/utils/selected_document_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'selected_document_data_test_',
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('reads bytes once into reusable bytes and base64 data', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    final file = File('${tempDir.path}/document.jpg');
    await file.writeAsBytes(bytes);

    final selected = await SelectedDocumentData.read(
      file: XFile(file.path),
      source: ImageSource.camera,
    );

    expect(selected.bytes, bytes);
    expect(selected.base64Data, base64Encode(bytes));
    expect(selected.filename, 'document.jpg');
    expect(selected.source, ImageSource.camera);
    expect(selected.temporaryPath, file.path);
  });

  test('deletes a camera capture idempotently', () async {
    final file = File('${tempDir.path}/camera.jpg');
    await file.writeAsBytes([5, 6, 7]);
    final selected = await SelectedDocumentData.read(
      file: XFile(file.path),
      source: ImageSource.camera,
    );

    await selected.deleteTemporaryCameraFile();
    await selected.deleteTemporaryCameraFile();

    expect(await file.exists(), isFalse);
  });

  test('never exposes or deletes a gallery path', () async {
    final file = File('${tempDir.path}/gallery.jpg');
    await file.writeAsBytes([8, 9, 10]);
    final selected = await SelectedDocumentData.read(
      file: XFile(file.path),
      source: ImageSource.gallery,
    );

    await selected.deleteTemporaryCameraFile();

    expect(selected.temporaryPath, isNull);
    expect(await file.exists(), isTrue);
  });

  test('does not fail when a known camera file is already absent', () async {
    final selected = SelectedDocumentData(
      bytes: Uint8List(0),
      base64Data: '',
      filename: 'missing.jpg',
      source: ImageSource.camera,
      temporaryPath: '${tempDir.path}/missing.jpg',
    );

    await expectLater(selected.deleteTemporaryCameraFile(), completes);
  });
}
