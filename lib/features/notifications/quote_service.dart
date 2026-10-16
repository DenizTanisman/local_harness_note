import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Embedded local quote pool (spec §8) — no server involved. The user can
/// override the pool per language from the editor; the override is stored in
/// app_settings under [customKey] as a JSON array of strings.
class QuoteService {
  static const customKeyPrefix = 'quotes_custom_';

  static String customKey(String lang) => '$customKeyPrefix$lang';

  /// The bundled default pool for [lang].
  static Future<List<String>> load(String lang) async {
    final raw = await rootBundle.loadString('assets/quotes_$lang.json');
    return (jsonDecode(raw) as List).cast<String>();
  }

  /// The pool actually used for notifications: the user's edited list when
  /// one exists (even if they cleared it to empty), otherwise the bundled
  /// defaults. [settings] is the app_settings map.
  static Future<List<String>> effective(
    String lang,
    Map<String, String> settings,
  ) async {
    final raw = settings[customKey(lang)];
    if (raw != null) {
      try {
        return (jsonDecode(raw) as List).cast<String>();
      } catch (_) {
        // Corrupt override → fall back to defaults rather than crash.
      }
    }
    return load(lang);
  }

  /// Deterministic daily pick: quotes[dayOfYear % quotes.length] (spec §8).
  static String quoteFor(List<String> quotes, DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return quotes[dayOfYear % quotes.length];
  }
}
