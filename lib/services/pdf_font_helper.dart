import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFontHelper {
  static pw.ThemeData? _cachedTheme;

  static Future<pw.ThemeData> unicodeTheme() async {
    final cached = _cachedTheme;
    if (cached != null) return cached;

    final regularData = await rootBundle.load(
      'assets/fonts/Roboto-Regular.ttf',
    );
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    final regular = pw.Font.ttf(regularData);
    final bold = pw.Font.ttf(boldData);

    final theme = pw.ThemeData.withFont(
      base: regular,
      bold: bold,
      fontFallback: [regular],
    );

    _cachedTheme = theme;
    return theme;
  }
}
