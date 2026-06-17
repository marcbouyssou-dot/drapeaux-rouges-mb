import 'package:hive_flutter/hive_flutter.dart';

import '../models/medical_letter/medical_letter_history_item.dart';
import 'secure_hive_service.dart';

class MedicalLetterHistoryService {
  static const String boxName = 'medical_letters_box';
  static const String _key = 'medical_letters_history';

  static Future<Box> _openBox() {
    if (Hive.isBoxOpen(boxName)) {
      return Future.value(Hive.box(boxName));
    }

    return SecureHiveService.openProtectedBox(boxName);
  }

  static Future<void> saveLetter(MedicalLetterHistoryItem letter) async {
    final letters = await getLetters();
    letters.removeWhere((item) => item.id == letter.id);
    letters.insert(0, letter);

    final box = await _openBox();
    await box.put(_key, letters.map((item) => item.toMap()).toList());
  }

  static Future<List<MedicalLetterHistoryItem>> getLetters() async {
    final box = await _openBox();
    final raw = box.get(_key);

    if (raw is! List) return [];

    final letters = raw
        .whereType<Map>()
        .map(
          (item) =>
              MedicalLetterHistoryItem.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();

    letters.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

    return letters;
  }

  static Future<void> clearLetters() async {
    final box = await _openBox();
    await box.delete(_key);
  }
}
