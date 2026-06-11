import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Embedded local quote pool (spec §8) — no server involved.
class QuoteService {
  static Future<List<String>> load(String lang) async {
    final raw = await rootBundle.loadString('assets/quotes_$lang.json');
    return (jsonDecode(raw) as List).cast<String>();
  }

  /// Deterministic daily pick: quotes[dayOfYear % quotes.length] (spec §8).
  static String quoteFor(List<String> quotes, DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return quotes[dayOfYear % quotes.length];
  }
}
