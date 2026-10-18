import 'dart:convert';

/// A lesson file: one self-contained HTML tutorial with its active-recall
/// pack embedded as
/// `<script type="application/json" id="not-recall">{…}</script>`
/// (docs/lesson-format.md).
class LessonPack {
  const LessonPack({
    required this.title,
    required this.sections,
    required this.questions,
  });

  final String title;
  final List<LessonSection> sections;
  final List<RecallQuestion> questions;

  List<RecallQuestion> ofSection(String id) => [
    for (final q in questions)
      if (q.section == id) q,
  ];

  LessonSection? section(String id) {
    for (final s in sections) {
      if (s.id == id) return s;
    }
    return null;
  }
}

class LessonSection {
  const LessonSection(this.id, this.title);

  /// Element id of the section in the HTML.
  final String id;
  final String title;
}

/// When a question is asked, counted from the day its section's recall was
/// first started: stage 1 that day, 2 the next day, 3 a week later.
const recallStageOffsets = {1: 0, 2: 1, 3: 7};

const recallStageNames = {
  1: 'Aşama 1 · hemen sonra',
  2: 'Aşama 2 · ertesi gün',
  3: 'Aşama 3 · bir hafta sonra',
};

class RecallQuestion {
  const RecallQuestion({
    required this.id,
    required this.section,
    required this.stage,
    required this.anchor,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.why,
  });

  final String id;
  final String section;
  final int stage;

  /// Element id in the HTML the question is about (a concept card); wrong
  /// answers mark it and the "Yanlışlar" bar jumps to it.
  final String anchor;
  final String prompt;
  final List<String> options;

  /// Index into [options].
  final int answer;

  /// Why the answer is right (shown on the results screen).
  final String why;
}

class LessonFormatException implements Exception {
  const LessonFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LessonFormat {
  LessonFormat._();

  static final _pack = RegExp(
    r'<script[^>]*\bid="not-recall"[^>]*>(.*?)</script>',
    dotAll: true,
  );
  static final _title = RegExp(r'<title>([^<]*)</title>');

  /// Reads the recall pack out of [html]; throws [LessonFormatException]
  /// with a Turkish message when it is missing or malformed.
  static LessonPack parse(String html) {
    final m = _pack.firstMatch(html);
    if (m == null) {
      throw const LessonFormatException(
        'Bu dosyada recall soruları yok (not-recall bloğu bulunamadı).',
      );
    }
    final Object? raw;
    try {
      raw = jsonDecode(m.group(1)!.trim());
    } on FormatException catch (e) {
      throw LessonFormatException('Soru paketi okunamadı: ${e.message}');
    }
    if (raw is! Map) throw const LessonFormatException('Soru paketi bozuk.');
    final sections = [
      for (final s in (raw['sections'] as List? ?? const []))
        if (s is Map && s['id'] is String)
          LessonSection(s['id'] as String, '${s['title'] ?? s['id']}'),
    ];
    final ids = {for (final s in sections) s.id};
    final questions = <RecallQuestion>[];
    for (final q in (raw['questions'] as List? ?? const [])) {
      if (q is! Map) continue;
      final options = [for (final o in (q['options'] as List? ?? [])) '$o'];
      final answer = (q['answer'] as num?)?.toInt() ?? -1;
      final stage = (q['stage'] as num?)?.toInt() ?? 1;
      if (!ids.contains(q['section']) ||
          options.length < 2 ||
          answer < 0 ||
          answer >= options.length ||
          !recallStageOffsets.containsKey(stage)) {
        continue; // skip a broken question rather than the whole lesson
      }
      questions.add(
        RecallQuestion(
          id: '${q['id'] ?? '${q['section']}-${questions.length}'}',
          section: q['section'] as String,
          stage: stage,
          anchor: '${q['anchor'] ?? q['section']}',
          prompt: '${q['q'] ?? ''}',
          options: options,
          answer: answer,
          why: '${q['why'] ?? ''}',
        ),
      );
    }
    if (sections.isEmpty || questions.isEmpty) {
      throw const LessonFormatException('Soru paketinde bölüm ya da soru yok.');
    }
    final title =
        (raw['title'] as String?) ??
        _title.firstMatch(html)?.group(1)?.trim() ??
        'Ders';
    return LessonPack(title: title, sections: sections, questions: questions);
  }
}
