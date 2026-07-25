import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class SelectedDocumentData {
  const SelectedDocumentData({
    required this.bytes,
    required this.base64Data,
    required this.filename,
    required this.source,
    required this.temporaryPath,
  });

  final Uint8List bytes;
  final String base64Data;
  final String filename;
  final ImageSource source;
  final String? temporaryPath;

  static Future<SelectedDocumentData> read({
    required XFile file,
    required ImageSource source,
  }) async {
    final path = file.path.trim();
    late final Uint8List bytes;

    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      if (source == ImageSource.camera && path.isNotEmpty) {
        try {
          await _deleteIfPresent(path);
        } on FileSystemException {
          // Preserve the original read error.
        }
      }
      rethrow;
    }

    return SelectedDocumentData(
      bytes: bytes,
      base64Data: base64Encode(bytes),
      filename: file.name,
      source: source,
      temporaryPath: source == ImageSource.camera && path.isNotEmpty
          ? path
          : null,
    );
  }

  Future<void> deleteTemporaryCameraFile() async {
    final path = temporaryPath;
    if (source != ImageSource.camera || path == null || path.isEmpty) return;

    await _deleteIfPresent(path);
  }

  static Future<void> _deleteIfPresent(String path) async {
    final file = File(path);
    if (!await file.exists()) return;

    try {
      await file.delete();
    } on FileSystemException {
      if (await file.exists()) rethrow;
    }
  }
}
