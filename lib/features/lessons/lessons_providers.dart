import 'dart:convert';

import 'package:file_picker/file_picker.dart';
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

/// The + on the Dersler tab: pick an .html file.
Future<Lesson?> pickLesson(BuildContext context, LessonsRepository repo) async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['html', 'htm'],
    withData: true,
  );
  final bytes = picked?.files.single.bytes;
  if (bytes == null || !context.mounted) return null;
  final String html;
  try {
    html = const Utf8Decoder().convert(bytes);
  } on FormatException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dosya okunamadı (UTF-8 değil).')),
    );
    return null;
  }
  return importLesson(context, repo, html);
}
