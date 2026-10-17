/// Links in note bodies: bare URLs (`https://…`, `www.…`) and labelled
/// links written `[kısa ifade](https://…)`, which read as just the label.
class NoteLink {
  const NoteLink({
    required this.start,
    required this.end,
    required this.url,
    this.label,
  });

  /// Range in the raw body.
  final int start;
  final int end;

  /// Openable URL (scheme added for `www.` links).
  final String url;

  /// The short phrase shown instead of the URL, if any.
  final String? label;

  /// What a reader sees.
  String get display => label ?? NoteLinks.shortUrl(url);
}

/// A piece of a body as shown in reading view.
class NoteSegment {
  const NoteSegment(this.start, this.end, this.display, {this.link});

  /// Range in the raw body.
  final int start;
  final int end;
  final String display;
  final NoteLink? link;
}

class NoteLinks {
  NoteLinks._();

  static final _labelled = RegExp(
    r'\[([^\]\n]+)\]\(((?:https?://|www\.)[^\s)]+)\)',
  );
  static final _bare = RegExp(r'(?:https?://|www\.)[^\s<>()\[\]]+');
  static const _trailing = '.,;:!?\'"»';

  static String _openable(String url) =>
      url.startsWith('www.') ? 'https://$url' : url;

  /// Every link in [body], in order.
  static List<NoteLink> find(String body) {
    final links = <NoteLink>[];
    for (final m in _labelled.allMatches(body)) {
      links.add(
        NoteLink(
          start: m.start,
          end: m.end,
          url: _openable(m.group(2)!),
          label: m.group(1)!.trim(),
        ),
      );
    }
    bool inside(int i) => links.any((l) => i >= l.start && i < l.end);
    for (final m in _bare.allMatches(body)) {
      if (inside(m.start)) continue;
      var end = m.end;
      while (end > m.start && _trailing.contains(body[end - 1])) {
        end--;
      }
      links.add(
        NoteLink(
          start: m.start,
          end: end,
          url: _openable(body.substring(m.start, end)),
        ),
      );
    }
    links.sort((a, b) => a.start.compareTo(b.start));
    return links;
  }

  /// The link the cursor at [offset] is on (edges included).
  static NoteLink? at(String body, int offset) {
    for (final l in find(body)) {
      if (offset >= l.start && offset <= l.end) return l;
    }
    return null;
  }

  /// `youtube.com/watch?v=abc…` — host without `www.`, path capped.
  static String shortUrl(String url, {int max = 32}) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    final host = uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
    var rest = url.substring(url.indexOf(uri.host) + uri.host.length);
    if (rest == '/' || rest.isEmpty) return host;
    final full = '$host$rest';
    return full.length > max ? '${full.substring(0, max)}…' : full;
  }

  /// Gives [link] the short phrase [label] (empty → back to the bare URL).
  static String setLabel(String body, NoteLink link, String label) {
    final clean = label.replaceAll(RegExp(r'[\[\]\n]'), ' ').trim();
    final replacement = clean.isEmpty ? link.url : '[$clean](${link.url})';
    return body.replaceRange(link.start, link.end, replacement);
  }

  /// [body] cut into plain text and links, for the reading view.
  static List<NoteSegment> segments(String body) {
    final out = <NoteSegment>[];
    var i = 0;
    for (final l in find(body)) {
      if (l.start > i) {
        out.add(NoteSegment(i, l.start, body.substring(i, l.start)));
      }
      out.add(NoteSegment(l.start, l.end, l.display, link: l));
      i = l.end;
    }
    if (i < body.length) {
      out.add(NoteSegment(i, body.length, body.substring(i)));
    }
    return out;
  }

  /// [body] as a reader sees it: labels instead of `[…](…)`, short URLs.
  static String displayText(String body) =>
      segments(body).map((s) => s.display).join();

  /// Raw offset for a position in the reading view's text. Inside a link
  /// it lands at the link's end, so editing starts after it.
  static int rawOffset(List<NoteSegment> segments, int displayOffset) {
    var shown = 0;
    for (final s in segments) {
      final len = s.display.length;
      if (displayOffset <= shown + len) {
        return s.link == null ? s.start + (displayOffset - shown) : s.end;
      }
      shown += len;
    }
    return segments.isEmpty ? 0 : segments.last.end;
  }
}
