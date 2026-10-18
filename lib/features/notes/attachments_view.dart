import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voice_player/voice_player.dart';

import 'attachment_importer.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/attachments_repository.dart';
import '../../data/db/database_provider.dart';
import '../../theme/app_tokens.dart';

final attachmentsRepositoryProvider = Provider<AttachmentsRepository>(
  (ref) => AttachmentsRepository(
    ref.watch(databaseProvider),
    importer: deviceAttachmentImporter,
  ),
);

String formatDuration(Duration d) {
  final s = d.inSeconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

enum AttachAction { record, audioFile, camera, gallery }

/// "Ekle" sheet: record a voice note, pick an audio file, take or pick a
/// picture. Returns the file to attach with its MIME type.
Future<({String path, String mime})?> pickAttachment(
  BuildContext context,
) async {
  final action = await showModalBottomSheet<AttachAction>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              'Nota ekle',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final (action, icon, title, sub) in const [
            (
              AttachAction.record,
              Icons.mic,
              'Ses kaydet',
              'Şimdi konuş, kaydet',
            ),
            (
              AttachAction.audioFile,
              Icons.audio_file,
              'Ses dosyası',
              'Telefondaki bir kayıt ya da sesli mesaj',
            ),
            (AttachAction.camera, Icons.photo_camera, 'Fotoğraf çek', ''),
            (AttachAction.gallery, Icons.photo_library, 'Galeriden görsel', ''),
          ])
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: sub.isEmpty ? null : Text(sub),
              onTap: () => Navigator.pop(context, action),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return null;
  switch (action) {
    case AttachAction.record:
      final path = await showModalBottomSheet<String>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => const _RecordSheet(),
      );
      return path == null ? null : (path: path, mime: 'audio/mp4');
    case AttachAction.audioFile:
      final picked = await FilePicker.platform.pickFiles(type: FileType.audio);
      final path = picked?.files.single.path;
      if (path == null) return null;
      final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
      return (path: path, mime: 'audio/${ext.isEmpty ? 'mpeg' : ext}');
    case AttachAction.camera:
    case AttachAction.gallery:
      final image = await ImagePicker().pickImage(
        source: action == AttachAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        requestFullMetadata: false,
      );
      return image == null ? null : (path: image.path, mime: 'image/jpeg');
  }
}

/// Records with the microphone; pops with the file path, or null.
class _RecordSheet extends StatefulWidget {
  const _RecordSheet();

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  final _recorder = AudioRecorder();
  final _watch = Stopwatch();
  Timer? _tick;
  StreamSubscription<Amplitude>? _level;
  double _amp = 0;
  bool _recording = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      setState(
        () => _error =
            'Mikrofon izni yok. Ayarlar › Uygulamalar › Not '
            '› İzinler bölümünden açabilirsin.',
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = p.join(
      dir.path,
      'kayit-${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: path,
    );
    _watch.start();
    _tick = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => setState(() {}),
    );
    _level = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen(
          (a) => setState(() => _amp = ((a.current + 50) / 50).clamp(0, 1)),
        );
    setState(() => _recording = true);
  }

  Future<void> _finish(bool keep) async {
    _tick?.cancel();
    _watch.stop();
    String? path;
    if (_recording) {
      path = keep ? await _recorder.stop() : null;
      if (!keep) await _recorder.cancel();
    }
    if (mounted) Navigator.pop(context, path);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _level?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ses kaydı', style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, textAlign: TextAlign.center)
            else ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 96 + 40 * _amp,
                height: 96 + 40 * _amp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTokens.danger.withValues(alpha: 0.15 + 0.25 * _amp),
                ),
                child: const Icon(Icons.mic, size: 44, color: AppTokens.danger),
              ),
              const SizedBox(height: 16),
              Text(
                formatDuration(_watch.elapsed),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _finish(false),
                    child: const Text('Vazgeç'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _recording ? () => _finish(true) : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Bitir ve ekle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A note's voice clips and pictures, above its text.
class AttachmentStrip extends ConsumerWidget {
  const AttachmentStrip({super.key, required this.noteId, required this.title});

  final String noteId;

  /// Names the clip in the "Çalınıyor" notification.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(attachmentsRepositoryProvider);
    return StreamBuilder<List<NoteAttachment>>(
      stream: repo.watch(noteId),
      builder: (context, snap) {
        final items = snap.data ?? const [];
        if (items.isEmpty) return const SizedBox.shrink();
        final audio = [
          for (final a in items)
            if (a.kind == 'audio') a,
        ];
        final images = [
          for (final a in items)
            if (a.kind == 'image') a,
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final a in audio)
                _AudioTile(attachment: a, repo: repo, title: title),
              if (images.isNotEmpty)
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) =>
                        _ImageThumb(attachment: images[i], repo: repo),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<bool> _confirmRemove(BuildContext context, String what) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$what silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: AppTokens.danger)),
          ),
        ],
      ),
    ) ==
    true;

class _AudioTile extends StatefulWidget {
  const _AudioTile({
    required this.attachment,
    required this.repo,
    required this.title,
  });

  final NoteAttachment attachment;
  final AttachmentsRepository repo;
  final String title;

  @override
  State<_AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<_AudioTile> {
  String? _path;
  Timer? _poll;
  VoicePlayerState _state = const VoicePlayerState();

  bool get _mine => _path != null && _state.path == _path;
  bool get _playing => _mine && _state.playing;

  @override
  void initState() {
    super.initState();
    widget.repo.fileOf(widget.attachment).then((f) {
      if (!mounted) return;
      setState(() => _path = f.path);
      _refresh(); // already playing from the notification?
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final s = await VoicePlayer.state();
    if (!mounted) return;
    setState(() => _state = s);
    if (_mine && s.playing) {
      _poll ??= Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => _refresh(),
      );
    } else {
      _poll?.cancel();
      _poll = null;
    }
  }

  Future<void> _toggle() async {
    final path = _path;
    if (path == null) return;
    if (_playing) {
      await VoicePlayer.stop();
    } else {
      await VoicePlayer.play(path, title: widget.title);
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final total = _mine && _state.duration > Duration.zero
        ? _state.duration
        : Duration(milliseconds: widget.attachment.durationMs ?? 0);
    final at = _mine ? _state.position : Duration.zero;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: _toggle,
        onLongPress: () async {
          if (await _confirmRemove(context, 'Ses kaydı')) {
            if (_playing) await VoicePlayer.stop();
            await widget.repo.remove(widget.attachment);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTokens.accentGradient,
                ),
                child: Icon(
                  _playing ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: total.inMilliseconds == 0
                            ? 0
                            : (at.inMilliseconds / total.inMilliseconds).clamp(
                                0,
                                1,
                              ),
                        minHeight: 5,
                        backgroundColor: AppTokens.surfaceCardBorder,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _mine
                          ? '${formatDuration(at)} / ${formatDuration(total)}'
                          : 'Sesli not · ${formatDuration(total)}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.attachment, required this.repo});

  final NoteAttachment attachment;
  final AttachmentsRepository repo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: repo.fileOf(attachment),
      builder: (context, snap) {
        final file = snap.data;
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: file == null
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ImageViewer(
                        file: file,
                        onDelete: () => repo.remove(attachment),
                      ),
                    ),
                  ),
            child: file == null
                ? const SizedBox(width: 96, height: 96)
                : Image.file(
                    file,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    cacheWidth: 288,
                  ),
          ),
        );
      },
    );
  }
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.file, required this.onDelete});

  final File file;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Görseli sil',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (await _confirmRemove(context, 'Görsel')) {
                await onDelete();
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(child: Image.file(file)),
      ),
    );
  }
}
