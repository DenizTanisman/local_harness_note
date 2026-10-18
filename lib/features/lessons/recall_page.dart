import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/lesson_format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/lessons_repository.dart';
import '../../theme/app_tokens.dart';
import 'lessons_providers.dart';

/// One recall run of one section. Right/wrong stays hidden until the last
/// question; every answer is saved as it is given, so leaving midway
/// resumes later the same day. Pops with a card id to jump to.
class RecallPage extends ConsumerStatefulWidget {
  const RecallPage({
    super.key,
    required this.lesson,
    required this.sectionTitle,
    required this.session,
    required this.questions,
    this.review = false,
  });

  final Lesson lesson;

  /// The 5-day genel tekrar run.
  final bool review;
  final String sectionTitle;
  final RecallSession session;

  /// Still to answer, in order.
  final List<RecallQuestion> questions;

  @override
  ConsumerState<RecallPage> createState() => _RecallPageState();
}

class _RecallPageState extends ConsumerState<RecallPage> {
  int _index = 0;
  final _chosen = <String, int>{};
  bool _saving = false;
  RecallResult? _result;

  RecallQuestion get _q => widget.questions[_index];
  bool get _last => _index == widget.questions.length - 1;

  Future<void> _next() async {
    final pick = _chosen[_q.id];
    if (pick == null || _saving) return;
    setState(() => _saving = true);
    final repo = ref.read(lessonsRepositoryProvider);
    await repo.answer(widget.session.id, _q, pick);
    if (_last) {
      await repo.finish(widget.session.id);
      final result = await repo.result(widget.lesson, widget.session.id);
      if (mounted) {
        setState(() {
          _result = result;
          _saving = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _index++;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return RecallResultPage(
        result: result,
        sectionTitle: widget.sectionTitle,
      );
    }
    final theme = Theme.of(context);
    final total = widget.questions.length;
    final pick = _chosen[_q.id];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recall · ${widget.sectionTitle}'),
            Text(
              recallStageNames[widget.review ? recallReviewStage : _q.stage]!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_index) / total,
                        minHeight: 6,
                        backgroundColor: AppTokens.surfaceCard,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_index + 1}/$total',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(
                    _q.prompt,
                    style: theme.textTheme.titleLarge?.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < _q.options.length; i++)
                    _Option(
                      letter: String.fromCharCode(65 + i),
                      text: _q.options[i],
                      selected: pick == i,
                      onTap: () => setState(() => _chosen[_q.id] = i),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  if (_index > 0)
                    TextButton.icon(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _index--),
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Önceki'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: pick == null || _saving ? null : _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 48),
                    ),
                    child: Text(_last ? 'Bitir' : 'İleri'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppTokens.navSelectedFill : AppTokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppTokens.accentEnd : AppTokens.surfaceCardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: selected
                      ? AppTokens.accentStart
                      : AppTokens.surfaceCardBorder,
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Score, then every wrong answer with the right one and why. "Yanlışlara
/// git" pops with the first wrong card; each wrong also has its own jump.
class RecallResultPage extends StatelessWidget {
  const RecallResultPage({
    super.key,
    required this.result,
    required this.sectionTitle,
  });

  final RecallResult result;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wrong = result.wrong;
    final right = [
      for (final i in result.items)
        if (i.chosen == i.question.answer) i,
    ];
    final skipped = result.items.length - result.answered;
    return Scaffold(
      appBar: AppBar(title: Text('Sonuç · $sectionTitle')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  _Score(correct: result.correct, total: result.items.length),
                  const SizedBox(height: 8),
                  Text(
                    wrong.isEmpty
                        ? (skipped > 0
                              ? '$skipped soru cevapsız kaldı.'
                              : 'Hepsi doğru. Sıradaki aşamada görüşürüz.')
                        : '${wrong.length} yanlış — eğiticide kartları '
                              'işaretlendi.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final item in wrong)
                    _AnswerCard(
                      question: item.question,
                      chosen: item.chosen,
                      onShow: () =>
                          Navigator.pop(context, item.question.anchor),
                    ),
                  if (right.isNotEmpty)
                    Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text('Doğrular (${right.length})'),
                        children: [
                          for (final item in right)
                            _AnswerCard(
                              question: item.question,
                              chosen: item.chosen,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: wrong.isEmpty
                  ? FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Derse dön'),
                    )
                  : FilledButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, wrong.first.question.anchor),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppTokens.danger,
                      ),
                      icon: const Icon(Icons.my_location),
                      label: const Text('Yanlışlara git'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : correct / total;
    final color = ratio >= 0.8
        ? AppTokens.catGreen
        : ratio >= 0.5
        ? AppTokens.catYellow
        : AppTokens.danger;
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: ratio,
              strokeWidth: 10,
              color: color,
              backgroundColor: AppTokens.surfaceCard,
            ),
            Center(
              child: Text(
                '$correct/$total',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.question, this.chosen, this.onShow});

  final RecallQuestion question;
  final int? chosen;
  final VoidCallback? onShow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wrong = chosen != null && chosen != question.answer;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: BorderSide(
          color: wrong
              ? AppTokens.danger.withValues(alpha: 0.6)
              : AppTokens.surfaceCardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.prompt, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            if (wrong)
              _Line(
                icon: Icons.close,
                color: AppTokens.danger,
                text: question.options[chosen!],
              ),
            _Line(
              icon: Icons.check,
              color: AppTokens.catGreen,
              text: question.options[question.answer],
            ),
            if (question.why.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                question.why,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            if (onShow != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onShow,
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text('Eğiticide göster'),
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
