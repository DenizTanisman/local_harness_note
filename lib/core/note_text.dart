import 'dart:math';

/// Text helpers shared by the repository, the UI and the MCP tools.
class NoteText {
  NoteText._();

  static const _fold = {
    'ı': 'i', 'I': 'i', 'İ': 'i', 'ş': 's', 'Ş': 's', 'ç': 'c', 'Ç': 'c', //
    'ğ': 'g', 'Ğ': 'g', 'ö': 'o', 'Ö': 'o', 'ü': 'u', 'Ü': 'u', 'â': 'a', //
    'Â': 'a', 'î': 'i', 'Î': 'i', 'û': 'u', 'Û': 'u',
  };

  /// Search form of [text]: lower case with Turkish letters folded to ASCII
  /// (ı/i, ş/s …), so "isik" finds "ışık". Length-preserving (one UTF-16
  /// unit in, one out), which lets [snippet] map match offsets back onto
  /// the original text.
  static String fold(String text) {
    final out = StringBuffer();
    for (final unit in text.split('')) {
      final mapped = _fold[unit];
      if (mapped != null) {
        out.write(mapped);
        continue;
      }
      final lower = unit.toLowerCase();
      out.write(lower.length == 1 ? lower : unit);
    }
    return out.toString();
  }

  /// Turkish-aware lower case for display (İ→i, I→ı).
  static String lowerTr(String text) =>
      text.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

  static final _tagPattern = RegExp(
    r'(?:^|\s)#([\p{L}\p{N}_-]+)',
    unicode: true,
  );

  /// `#tags` in [body], lower-cased, de-duplicated, in order of appearance.
  static List<String> tags(String body) {
    final seen = <String>{};
    for (final m in _tagPattern.allMatches(body)) {
      seen.add(lowerTr(m.group(1)!));
    }
    return seen.toList();
  }

  static final _mergeHeader = RegExp(r'^— .+ —$');

  /// Index of the title line: the first non-empty line that is not a
  /// merge date separator (falls back to the first non-empty line).
  static int _titleLine(List<String> lines) {
    final i = lines.indexWhere(
      (l) => l.trim().isNotEmpty && !_mergeHeader.hasMatch(l.trim()),
    );
    return i >= 0 ? i : lines.indexWhere((l) => l.trim().isNotEmpty);
  }

  /// First meaningful line, trimmed and capped.
  static String title(String body, {int max = 80}) {
    final lines = body.split('\n');
    final i = _titleLine(lines);
    if (i < 0) return '';
    final t = lines[i].trim();
    return t.length > max ? '${t.substring(0, max)}…' : t;
  }

  /// Everything after the title line, trimmed.
  static String rest(String body) {
    final lines = body.split('\n');
    final i = _titleLine(lines);
    if (i < 0) return '';
    return lines.skip(i + 1).join('\n').trim();
  }

  /// Search terms of a free-text query (folded words, `#tags` excluded).
  static List<String> terms(String query) => [
    for (final m in RegExp(
      r'#?[\p{L}\p{N}_]+',
      unicode: true,
    ).allMatches(fold(query)))
      if (!m.group(0)!.startsWith('#')) m.group(0)!,
  ];

  /// `#tags` typed into a search query.
  static List<String> queryTags(String query) => tags(query);

  /// FTS5 MATCH expression: every term as a prefix, all required.
  static String? ftsQuery(String query) {
    final t = terms(query);
    if (t.isEmpty) return null;
    return t.map((w) => '"$w"*').join(' ');
  }

  /// ~[width] characters of [body] around the first match of [query]
  /// (falls back to the start of the body), on one line.
  static String snippet(String body, String query, {int width = 160}) {
    final flat = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    final folded = fold(flat);
    var at = -1;
    for (final term in terms(query)) {
      final i = folded.indexOf(term);
      if (i >= 0 && (at < 0 || i < at)) at = i;
    }
    if (flat.length <= width) return flat;
    final start = at < 0 ? 0 : max(0, at - width ~/ 3);
    final end = min(flat.length, start + width);
    return '${start > 0 ? '…' : ''}${flat.substring(start, end)}'
        '${end < flat.length ? '…' : ''}';
  }

  static const _months = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', //
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  /// "12 Eki 2026"
  static String date(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// Separator line placed above each part of a merged note.
  static String mergeHeader(DateTime d) => '— ${date(d)} —';

  /// Random uuid v4.
  static String uuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
