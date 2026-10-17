import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/note_links.dart';
import '../../core/system_channel.dart';
import '../../theme/app_tokens.dart';

/// Opens [link] in its own app (YouTube, Instagram, X …) or the browser.
Future<void> openNoteLink(BuildContext context, NoteLink link) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!await SystemChannel.openUrl(link.url)) {
    messenger.showSnackBar(
      SnackBar(content: Text('Açılamadı: ${NoteLinks.shortUrl(link.url)}')),
    );
  }
}

/// A note as it reads: links show their short phrase (or a short URL) and
/// open on tap; `#tags` are highlighted. Tapping anywhere else reports the
/// matching raw offset through [onTapText], so editing starts right there.
class NoteBodyView extends StatefulWidget {
  const NoteBodyView({super.key, required this.body, required this.onTapText});

  final String body;
  final ValueChanged<int> onTapText;

  @override
  State<NoteBodyView> createState() => _NoteBodyViewState();
}

class _NoteBodyViewState extends State<NoteBodyView> {
  final _textKey = GlobalKey();
  final _recognizers = <TapGestureRecognizer>[];
  List<NoteSegment> _segments = const [];

  static final _tag = RegExp(r'(?:^|(?<=\s))#[\p{L}\p{N}_-]+', unicode: true);

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  /// Plain text with `#tags` highlighted.
  List<InlineSpan> _plain(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    var i = 0;
    for (final m in _tag.allMatches(text)) {
      if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
      spans.add(
        TextSpan(
          text: m.group(0),
          style: base.copyWith(color: AppTokens.textAccent),
        ),
      );
      i = m.end;
    }
    if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
    return spans;
  }

  void _onTapUp(TapUpDetails details) {
    final paragraph =
        _textKey.currentContext?.findRenderObject() as RenderParagraph?;
    if (paragraph == null) return;
    final local = paragraph.globalToLocal(details.globalPosition);
    final position = paragraph.getPositionForOffset(local);
    widget.onTapText(NoteLinks.rawOffset(_segments, position.offset));
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge!;
    final linkStyle = base.copyWith(
      color: AppTokens.accentEnd,
      decoration: TextDecoration.underline,
      decorationColor: AppTokens.accentEnd,
    );
    _disposeRecognizers();
    _segments = NoteLinks.segments(widget.body);
    final spans = <InlineSpan>[];
    for (final s in _segments) {
      final link = s.link;
      if (link == null) {
        spans.addAll(_plain(s.display, base));
        continue;
      }
      final recognizer = TapGestureRecognizer()
        ..onTap = () => openNoteLink(context, link);
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(text: s.display, style: linkStyle, recognizer: recognizer),
      );
    }
    // Link spans win the tap (deepest recognizer); anywhere else edits.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _onTapUp,
      child: Text.rich(
        key: _textKey,
        TextSpan(style: base, children: spans),
      ),
    );
  }
}
