import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/lesson_format.dart';
import '../../core/note_text.dart';
import '../../core/recall_planner.dart';
import '../../core/system_channel.dart';
import '../../data/db/app_database.dart';
import '../../theme/app_tokens.dart';
import 'lessons_providers.dart';
import 'recall_page.dart';

/// Reads a lesson in a WebView. Not adds a ▶ Recall button under every
/// section title (the file itself has none, so it reads clean elsewhere),
/// marks cards answered wrong and, at the bottom, a "Yanlışlar 2/5 ◀ ▶"
/// bar jumps between them.
class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({
    super.key,
    required this.lessonId,
    this.section,
    this.recall = false,
  });

  final String lessonId;

  /// Section to scroll to on open.
  final String? section;

  /// Start [section]'s recall right away (review reminder tap).
  final bool recall;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  static const _base = 'https://ders.not.local/';

  Lesson? _lesson;
  LessonPack? _pack;
  String? _error;
  WebViewController? _web;
  bool _loaded = false;
  StreamSubscription<void>? _changes;
  Timer? _scrollSave;

  /// Marked card ids in tutorial order, and where the bar stands (-1: not
  /// yet on one).
  List<String> _marks = const [];
  int _at = -1;
  bool _barHidden = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final repo = ref.read(lessonsRepositoryProvider);
    final lesson = await repo.get(widget.lessonId);
    if (!mounted) return;
    if (lesson == null) {
      setState(() => _error = 'Ders bulunamadı.');
      return;
    }
    final LessonPack pack;
    try {
      pack = repo.pack(lesson);
    } on LessonFormatException catch (e) {
      setState(() => _error = e.message);
      return;
    }
    await repo.markOpened(lesson.id);
    final web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // A lesson without its own background is black on white, as in a
      // browser.
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('NotRecall', onMessageReceived: _onMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _onLoaded(),
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.startsWith(_base) ||
                url.startsWith('about:') ||
                url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }
            // Outside links go to their own app / the browser.
            SystemChannel.openUrl(url);
            return NavigationDecision.prevent;
          },
        ),
      );
    await web.loadHtmlString(lesson.html, baseUrl: _base);
    _changes = repo.watchRecall().listen((_) => _refresh());
    setState(() {
      _lesson = lesson;
      _pack = pack;
      _web = web;
    });
  }

  @override
  void dispose() {
    _changes?.cancel();
    _scrollSave?.cancel();
    super.dispose();
  }

  Future<void> _onLoaded() async {
    final web = _web;
    final lesson = _lesson;
    if (web == null || lesson == null || _loaded) return;
    _loaded = true;
    await web.runJavaScript(_script);
    await _refresh();
    if (widget.section != null) {
      await _go(widget.section!, flash: false);
      if (widget.recall) await _recall(widget.section!);
    } else if ((lesson.scrollY ?? 0) > 0) {
      await web.runJavaScript('window.scrollTo(0, ${lesson.scrollY});');
    }
  }

  void _onMessage(JavaScriptMessage message) {
    final Object? data;
    try {
      data = jsonDecode(message.message);
    } on FormatException {
      return;
    }
    if (data is! Map) return;
    switch (data['type']) {
      case 'recall' when data['section'] is String:
        _recall(data['section'] as String);
      case 'scroll' when data['y'] is num:
        final y = (data['y'] as num).round();
        _scrollSave?.cancel();
        _scrollSave = Timer(const Duration(milliseconds: 800), () {
          final lesson = _lesson;
          if (lesson != null) {
            ref.read(lessonsRepositoryProvider).saveScroll(lesson.id, y);
          }
        });
    }
  }

  Future<RecallPlanner?> _planner() async {
    final lesson = _lesson;
    if (lesson == null) return null;
    return ref.read(lessonsRepositoryProvider).plannerFor(lesson);
  }

  /// Re-labels the Recall buttons and re-applies the wrong-card marks.
  Future<void> _refresh() async {
    final web = _web;
    final pack = _pack;
    final planner = await _planner();
    if (web == null || pack == null || planner == null || !_loaded) return;
    final sections = [
      for (final s in pack.sections) _buttonFor(planner.status(s.id)),
    ];
    final marks = planner.markedAnchors();
    final current = _at >= 0 && _at < _marks.length ? _marks[_at] : null;
    if (mounted) {
      setState(() {
        _marks = marks;
        _at = current == null ? -1 : marks.indexOf(current);
      });
    }
    await web.runJavaScript(
      'notRecall.setSections(${jsonEncode(sections)});'
      'notRecall.setMarks(${jsonEncode(marks)});',
    );
  }

  Map<String, Object> _buttonFor(SectionStatus s) {
    final today = ref.read(lessonsRepositoryProvider).today;
    final String sub;
    if (s.resume > 0) {
      sub = 'Devam et · ${s.resume} soru kaldı';
    } else if (s.due > 0) {
      sub = !s.started
          ? 'Başla · ${s.due} soru'
          : s.review
          ? 'Genel tekrar · ${s.due} soru'
          : 'Bugün ${s.due} soru';
    } else if (s.nextDay != null) {
      sub =
          'Sıradaki: ${_stageShort(s.nextStage!)} · '
          '${_dayLabel(s.nextDay!, today)}';
    } else {
      sub = 'Tamamlandı ✓';
    }
    return {
      'id': s.section,
      'sub': s.wrong > 0 ? '$sub · ● ${s.wrong} yanlış' : sub,
      'due': s.due > 0,
    };
  }

  static String _stageShort(int stage) =>
      stage == recallReviewStage ? 'genel tekrar' : 'aşama $stage';

  static String _dayLabel(int day, int today) => switch (day - today) {
    0 => 'bugün',
    1 => 'yarın',
    _ => NoteText.date(RecallDay.start(day)),
  };

  Future<void> _go(String id, {bool flash = true}) async {
    await _web?.runJavaScript('notRecall.go(${jsonEncode(id)}, $flash);');
  }

  Future<void> _step(int delta) async {
    if (_marks.isEmpty) return;
    final next = _at < 0
        ? (delta > 0 ? 0 : _marks.length - 1)
        : (_at + delta) % _marks.length;
    setState(() => _at = next < 0 ? next + _marks.length : next);
    await _go(_marks[_at]);
  }

  Future<void> _jumpTo(String anchor) async {
    await _refresh();
    if (!mounted) return;
    setState(() {
      _barHidden = false;
      _at = _marks.indexOf(anchor);
    });
    await _go(anchor);
  }

  Future<void> _recall(String section, {bool practice = false}) async {
    final lesson = _lesson;
    final pack = _pack;
    if (lesson == null || pack == null) return;
    final repo = ref.read(lessonsRepositoryProvider);
    final run = await repo.startOrResume(lesson, section, practice: practice);
    if (!mounted) return;
    if (run == null) {
      await _nothingDue(section);
      return;
    }
    final review = (await _planner())?.isReview(section) ?? false;
    if (!mounted) return;
    final anchor = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => RecallPage(
          lesson: lesson,
          review: review && !practice,
          sectionTitle: pack.section(section)?.title ?? section,
          session: run.$1,
          questions: run.$2,
        ),
      ),
    );
    if (anchor != null) {
      await _jumpTo(anchor);
    } else {
      await _refresh();
    }
  }

  Future<void> _nothingDue(String section) async {
    final planner = await _planner();
    if (planner == null || !mounted) return;
    final s = planner.status(section);
    final today = ref.read(lessonsRepositoryProvider).today;
    final again = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bugün bu bölüm için soru yok',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                s.nextDay != null
                    ? 'Sıradaki: ${_stageShort(s.nextStage!)}, '
                          '${_dayLabel(s.nextDay!, today)}.'
                    : 'Bu bölümün bütün aşamaları bitti.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.replay),
                label: const Text('Açılmış soruları yeniden çöz'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Kapat'),
              ),
            ],
          ),
        ),
      ),
    );
    if (again == true) await _recall(section, practice: true);
  }

  Future<void> _history() async {
    final lesson = _lesson;
    final pack = _pack;
    if (lesson == null || pack == null) return;
    final runs = await ref.read(lessonsRepositoryProvider).history(lesson);
    if (!mounted) return;
    final anchor = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scroll) => runs.isEmpty
            ? const Center(child: Text('Henüz recall yapılmadı.'))
            : ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text('Recall geçmişi'),
                  ),
                  for (final r in runs)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: r.wrong.isEmpty
                            ? AppTokens.catGreen.withValues(alpha: 0.2)
                            : AppTokens.danger.withValues(alpha: 0.2),
                        child: Text(
                          '${r.correct}',
                          style: TextStyle(
                            color: r.wrong.isEmpty
                                ? AppTokens.catGreen
                                : AppTokens.danger,
                          ),
                        ),
                      ),
                      title: Text(
                        pack.section(r.session.section)?.title ??
                            r.session.section,
                      ),
                      subtitle: Text(
                        '${NoteText.date(DateTime.fromMillisecondsSinceEpoch(r.session.createdAt))}'
                        ' · ${r.correct}/${r.items.length} doğru'
                        '${r.answered < r.items.length ? ' · yarım kaldı' : ''}',
                      ),
                      onTap: () async {
                        final picked = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (_) => RecallResultPage(
                              result: r,
                              sectionTitle:
                                  pack.section(r.session.section)?.title ??
                                  r.session.section,
                            ),
                          ),
                        );
                        if (picked != null && context.mounted) {
                          Navigator.pop(context, picked);
                        }
                      },
                    ),
                ],
              ),
      ),
    );
    if (anchor != null) await _jumpTo(anchor);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    final web = _web;
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson?.title ?? 'Ders', overflow: TextOverflow.ellipsis),
        actions: [
          if (lesson != null) ...[
            IconButton(
              tooltip: 'Recall geçmişi',
              icon: const Icon(Icons.history),
              onPressed: _history,
            ),
            PopupMenuButton<String>(
              onSelected: (_) => SystemChannel.openLessonFile(
                lessonFileName(lesson.title),
                lesson.html,
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'open',
                  child: Text('Başka uygulamada aç'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : web == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(child: WebViewWidget(controller: web)),
                if (_marks.isNotEmpty && !_barHidden)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: SafeArea(
                      top: false,
                      child: _WrongBar(
                        at: _at,
                        count: _marks.length,
                        onPrev: () => _step(-1),
                        onNext: () => _step(1),
                        onClose: () => setState(() => _barHidden = true),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  /// Injected once per load: styles, the Recall buttons, marks, jumps and
  /// scroll reporting. Lesson colours come from its own CSS variables when
  /// it has them.
  static const _script = r'''
(function(){
if (window.notRecall) return;
var css = `
.not-recall{display:flex;flex-direction:column;align-items:flex-start;gap:2px;width:100%;box-sizing:border-box;margin:12px 0 16px;padding:12px 16px;border-radius:14px;border:1.5px solid var(--acc,#2E7CF6);background:transparent;color:inherit;font:inherit;text-align:left;cursor:pointer}
.not-recall b{font-size:15px;color:var(--acc,#2E7CF6);letter-spacing:.02em}
.not-recall span{font-size:12.5px;opacity:.8}
.not-recall.due{background:var(--acc,#2E7CF6);color:var(--onacc,#fff)}
.not-recall.due b{color:inherit}
.not-mark{outline:2.5px solid #e5484d !important;outline-offset:3px}
.not-badge{align-self:flex-start;margin:8px 8px 0;padding:3px 10px;border-radius:999px;background:#e5484d;color:#fff;font-size:12px;font-weight:700;line-height:1.4}
.not-flash{animation:notflash 1.4s ease-out 1}
@keyframes notflash{0%{box-shadow:0 0 0 0 rgba(229,72,77,.8)}100%{box-shadow:0 0 0 22px rgba(229,72,77,0)}}
:where([id]){scroll-margin-top:16px}`;
var st = document.createElement('style'); st.textContent = css; document.head.appendChild(st);
function send(o){ try { NotRecall.postMessage(JSON.stringify(o)); } catch(e){} }
var t = null;
window.addEventListener('scroll', function(){
  clearTimeout(t);
  t = setTimeout(function(){ send({type:'scroll', y: Math.round(window.scrollY)}); }, 400);
}, {passive:true});
window.notRecall = {
  setSections: function(list){
    list.forEach(function(s){
      var sec = document.getElementById(s.id); if (!sec) return;
      var b = sec.querySelector('.not-recall');
      if (!b) {
        b = document.createElement('button'); b.type = 'button'; b.className = 'not-recall';
        b.addEventListener('click', function(){ send({type:'recall', section: s.id}); });
        var h = sec.querySelector('h1,h2,h3'), at = h;
        while (at && at.parentElement !== sec) at = at.parentElement;
        if (at) at.after(b); else sec.prepend(b);
      }
      b.innerHTML = '<b>▶ Recall</b><span></span>';
      b.querySelector('span').textContent = s.sub;
      b.classList.toggle('due', !!s.due);
    });
  },
  setMarks: function(ids){
    document.querySelectorAll('.not-badge').forEach(function(e){ e.remove(); });
    document.querySelectorAll('.not-mark').forEach(function(e){ e.classList.remove('not-mark'); });
    ids.forEach(function(id){
      var e = document.getElementById(id); if (!e) return;
      e.classList.add('not-mark');
      var badge = document.createElement('div'); badge.className = 'not-badge';
      badge.textContent = '● Yanlış — tekrar oku';
      e.prepend(badge);
    });
  },
  go: function(id, flash){
    var e = document.getElementById(id); if (!e) return;
    e.scrollIntoView({behavior:'smooth', block:'start'});
    if (flash) { e.classList.remove('not-flash'); void e.offsetWidth; e.classList.add('not-flash'); }
  }
};
})();
''';
}

class _WrongBar extends StatelessWidget {
  const _WrongBar({
    required this.at,
    required this.count,
    required this.onPrev,
    required this.onNext,
    required this.onClose,
  });

  final int at;
  final int count;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.menuFill,
      shape: const StadiumBorder(side: BorderSide(color: AppTokens.danger)),
      elevation: 8,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.circle, size: 12, color: AppTokens.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                at < 0 ? '$count yanlış' : 'Yanlışlar ${at + 1}/$count',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Önceki yanlış',
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrev,
            ),
            IconButton(
              tooltip: 'Sonraki yanlış',
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
            ),
            IconButton(
              tooltip: 'Gizle',
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
