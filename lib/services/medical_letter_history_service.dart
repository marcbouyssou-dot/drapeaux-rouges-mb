import 'package:hive_flutter/hive_flutter.dart';

import '../models/medical_letter/medical_letter_history_item.dart';
import 'secure_hive_service.dart';

class MedicalLetterHistoryService {
  static const String boxName = 'medical_letters_box';
  static const String _key = 'medical_letters_history';
  static Future<void> _mutationQueue = Future<void>.value();

  static Future<Box> _openBox() {
    if (Hive.isBoxOpen(boxName)) {
      return Future.value(Hive.box(boxName));
    }

    return SecureHiveService.openProtectedBox(boxName);
  }

  static Future<void> saveLetter(MedicalLetterHistoryItem letter) async {
    await _serializeMutation(() async {
      final letters = await getLetters();
      letters.removeWhere((item) => item.id == letter.id);
      letters.insert(0, letter);

      final box = await _openBox();
      await box.put(_key, letters.map((item) => item.toMap()).toList());
    });
  }

  static Future<List<MedicalLetterHistoryItem>> getLetters() async {
    final box = await _openBox();
    final raw = box.get(_key);

    if (raw is! List) return [];

    final letters = raw
        .whereType<Map>()
        .map(
          (item) => MedicalLetterHistoryItem.tryFromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .whereType<MedicalLetterHistoryItem>()
        .toList();

    letters.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

    return letters;
  }

  static Future<void> deleteById(String id) async {
    await _serializeMutation(() async {
      final letters = await getLetters();
      letters.removeWhere((item) => item.id == id);

      final box = await _openBox();
      await box.put(_key, letters.map((item) => item.toMap()).toList());
    });
  }

  static Future<void> deleteForPatient(
    String localId,
    String anonymousId,
  ) async {
    await _serializeMutation(() async {
      final normalizedLocalId = localId.trim();
      final normalizedAnonymousId = anonymousId.trim();
      final letters = await getLetters();

      letters.removeWhere(
        (item) =>
            (normalizedLocalId.isNotEmpty &&
                item.patientLocalId.trim() == normalizedLocalId) ||
            (normalizedAnonymousId.isNotEmpty &&
                item.patientAnonymousId.trim() == normalizedAnonymousId),
      );

      final box = await _openBox();
      await box.put(_key, letters.map((item) => item.toMap()).toList());
    });
  }

  static Future<void> clearLetters() async {
    await _serializeMutation(() async {
      final box = await _openBox();
      await box.clear();
    });
  }

  static Future<void> _serializeMutation(Future<void> Function() mutation) {
    final operation = _mutationQueue.then((_) => mutation());
    _mutationQueue = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return operation;
  }
}
