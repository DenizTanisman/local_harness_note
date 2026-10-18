import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/lesson_format.dart';
import '../../core/system_channel.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/lessons_repository.dart';

final lessonsRepositoryProvider = Provider<LessonsRepository>(
  (ref) => LessonsRepository(ref.watch(databaseProvider)),
);

/// File name of a lesson's copy in Documents/Not/Dersler/.
String lessonFileName(String title) {
  final safe = title
      .replaceAll(RegExp(r'[\\/:*?"<>|\n\r\t]'), '-')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return '${safe.isEmpty ? 'Ders' : safe}.html';
}

/// Adds (or updates) a lesson from [html], keeps a copy in
/// Documents/Not/Dersler/ and tells the user what happened. Null when the
/// file is not a lesson.
Future<Lesson?> importLesson(
  BuildContext context,
  LessonsRepository repo,
  String html,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final (lesson, replaced) = await repo.import(html);
    final path = await SystemChannel.saveLessonFile(
      lessonFileName(lesson.title),
      html,
    );
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          '${replaced ? '“${lesson.title}” güncellendi — ilerlemen duruyor' : '“${lesson.title}” eklendi'}'
          '${path != null ? '\nKopyası: $path' : ''}',
        ),
      ),
    );
    return lesson;
  } on LessonFormatException catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(e.message)));
    return null;
  }
}

/// The + on the Dersler tab: lessons usually arrive in Downloads or over
/// WhatsApp, so the system picker opens right there (HTML only, with its
/// own search); other places stay one tap away.
Future<Lesson?> pickLesson(BuildContext context, LessonsRepository repo) async {
  final place = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              'Dersi nereden ekleyelim?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final (key, icon, title, sub) in const [
            (
              'download',
              Icons.download,
              'İndirilenler',
              'Tarayıcıdan, Claude\'dan inenler',
            ),
            ('whatsapp', Icons.chat, 'WhatsApp', 'Sohbetlerden gelen belgeler'),
            (
              'lessons',
              Icons.school,
              'Not › Dersler',
              'Daha önce eklenenlerin kopyaları',
            ),
            ('other', Icons.search, 'Başka bir yer', 'Telefonun tamamında ara'),
          ])
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(sub),
              onTap: () => Navigator.pop(context, key),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (place == null || !context.mounted) return null;
  final html = await SystemChannel.pickLesson(place == 'other' ? null : place);
  if (html == null || !context.mounted) return null;
  if (html.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dosya okunamadı.')));
    return null;
  }
  return importLesson(context, repo, html);
}
