import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/system_channel.dart';
import '../../data/repositories/lessons_repository.dart';
import '../../theme/app_tokens.dart';
import 'lesson_page.dart';
import 'lessons_providers.dart';

/// Dersler tab: HTML tutorials with active recall. + (nav bar) adds one;
/// an .html opened with Not from a file manager lands here too.
class LessonsPage extends ConsumerStatefulWidget {
  const LessonsPage({super.key});

  @override
  ConsumerState<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends ConsumerState<LessonsPage> {
  Stream<List<LessonSummary>>? _lessons;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(lessonsRepositoryProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<List<LessonSummary>>(
          stream: _lessons ??= repo.watchLessons(),
          builder: (context, snap) {
            final items = snap.data;
            if (items == null) return const SizedBox.shrink();
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Henüz ders yok.\n\nSağ alttaki + ile bir HTML eğitici '
                    'ekle ya da dosya yöneticisinde bir derse dokunup '
                    '“Not” ile aç.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTokens.textSecondary,
                    ),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
              children: [
                for (final item in items)
                  _LessonTile(
                    item: item,
                    onOpen: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonPage(lessonId: item.lesson.id),
                      ),
                    ),
                    onMenu: (action) => _act(action, item),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _act(_LessonAction action, LessonSummary item) async {
    final lesson = item.lesson;
    switch (action) {
      case _LessonAction.openElsewhere:
        final ok = await SystemChannel.openLessonFile(
          lessonFileName(lesson.title),
          lesson.html,
        );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Açacak uygulama bulunamadı.')),
          );
        }
      case _LessonAction.delete:
        final sure = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ders silinsin mi?'),
            content: Text(
              '“${lesson.title}” ve tüm recall geçmişi silinir. '
              'Documents/Not/Dersler içindeki kopyası durur.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Sil',
                  style: TextStyle(color: AppTokens.danger),
                ),
              ),
            ],
          ),
        );
        if (sure == true) {
          await ref.read(lessonsRepositoryProvider).delete(lesson.id);
        }
    }
  }
}

enum _LessonAction { openElsewhere, delete }

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.item,
    required this.onOpen,
    required this.onMenu,
  });

  final LessonSummary item;
  final VoidCallback onOpen;
  final ValueChanged<_LessonAction> onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTokens.accentGradient,
                ),
                child: const Icon(Icons.school, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.sections} bölüm · ${item.questions} soru'
                      '${item.started > 0 ? ' · ${item.started} bölüm başladı' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTokens.textSecondary,
                      ),
                    ),
                    if (item.dueToday > 0 || item.wrong > 0) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (item.dueToday > 0)
                            _Pill(
                              text: 'Bugün ${item.dueToday} soru',
                              color: AppTokens.accentEnd,
                            ),
                          if (item.wrong > 0)
                            _Pill(
                              text: '● ${item.wrong} yanlış',
                              color: AppTokens.danger,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_LessonAction>(
                onSelected: onMenu,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _LessonAction.openElsewhere,
                    child: Text('Başka uygulamada aç'),
                  ),
                  PopupMenuItem(
                    value: _LessonAction.delete,
                    child: Text('Sil'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
