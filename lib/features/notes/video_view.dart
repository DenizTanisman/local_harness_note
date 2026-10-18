import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/attachments_repository.dart';
import '../../theme/app_tokens.dart';
import 'attachment_importer.dart';

String _clock(Duration d) {
  final s = d.inSeconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// A note's video: its poster with ▶; a tap plays it right in the note,
/// ⛶ goes full screen, a long press offers to delete it.
class VideoAttachmentTile extends StatefulWidget {
  const VideoAttachmentTile({
    super.key,
    required this.attachment,
    required this.repo,
    required this.onDelete,
  });

  final NoteAttachment attachment;
  final AttachmentsRepository repo;
  final Future<void> Function() onDelete;

  @override
  State<VideoAttachmentTile> createState() => _VideoAttachmentTileState();
}

class _VideoAttachmentTileState extends State<VideoAttachmentTile> {
  File? _file;
  File? _poster;

  /// Width / height of the video, read from its poster before it plays.
  double? _aspect;

  /// Tallest a portrait video may get inside a note.
  static const _maxHeight = 460.0;
  VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final file = await widget.repo.fileOf(widget.attachment);
    final poster = await ensurePoster(widget.repo, widget.attachment);
    double? aspect;
    if (poster != null) {
      try {
        final image = await decodeImageFromList(await poster.readAsBytes());
        aspect = image.width / image.height;
        image.dispose();
      } catch (_) {
        // No size: the 16:9 box is used.
      }
    }
    if (!mounted) return;
    setState(() {
      _file = file;
      _poster = poster;
      _aspect = aspect;
    });
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    final file = _file;
    if (file == null) return;
    final video = _video;
    if (video == null) {
      final created = VideoPlayerController.file(file);
      setState(() => _video = created);
      await created.initialize();
      created.addListener(() {
        if (mounted) setState(() {});
      });
      if (mounted) await created.play();
    } else if (video.value.isPlaying) {
      await video.pause();
    } else {
      if (video.value.position >= video.value.duration) {
        await video.seekTo(Duration.zero);
      }
      await video.play();
    }
  }

  Future<void> _fullScreen() async {
    final file = _file;
    if (file == null) return;
    final at = _video?.value.position ?? Duration.zero;
    await _video?.pause();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(file: file, startAt: at),
      ),
    );
  }

  Future<void> _delete() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video silinsin mi?'),
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
    );
    if (sure == true) {
      await _video?.pause();
      await widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    final ready = video != null && video.value.isInitialized;
    final playing = ready && video.value.isPlaying;
    final length = ready
        ? video.value.duration
        : Duration(milliseconds: widget.attachment.durationMs ?? 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: GestureDetector(
          onTap: _tap,
          onLongPress: _delete,
          child: LayoutBuilder(
            builder: (context, box) {
              // Its own shape: landscape fills the width, portrait stands
              // up to _maxHeight tall.
              final aspect = ready && video.value.aspectRatio > 0
                  ? video.value.aspectRatio
                  : (_aspect ?? 16 / 9);
              final height = (box.maxWidth / aspect).clamp(0.0, _maxHeight);
              return ColoredBox(
                color: Colors.black,
                child: SizedBox(
                  height: height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: aspect,
                          child: ready
                              ? VideoPlayer(video)
                              : _poster != null
                              ? Image.file(_poster!, fit: BoxFit.cover)
                              : const SizedBox.shrink(),
                        ),
                      ),
                      if (!playing)
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTokens.accentGradient,
                            ),
                            child: video != null && !ready
                                ? const Padding(
                                    padding: EdgeInsets.all(18),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                          ),
                        ),
                      Positioned(
                        left: 10,
                        bottom: 8,
                        child: _Badge(
                          ready
                              ? '${_clock(video.value.position)} / ${_clock(length)}'
                              : '🎬 ${_clock(length)}',
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          tooltip: 'Tam ekran',
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: _fullScreen,
                        ),
                      ),
                      if (ready)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: VideoProgressIndicator(
                            video,
                            allowScrubbing: true,
                            padding: EdgeInsets.zero,
                            colors: const VideoProgressColors(
                              playedColor: AppTokens.accentEnd,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

/// Full-screen player: tap to pause/play, drag the bar to seek. Opened from
/// a note's ⛶ or straight from a reminder's "🎬 İzle".
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.file,
    this.startAt = Duration.zero,
    this.title,
  });

  final File file;
  final Duration startAt;
  final String? title;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final VideoPlayerController _video = VideoPlayerController.file(
    widget.file,
  );
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await _video.initialize();
    } catch (_) {
      if (mounted) setState(() => _error = 'Video açılamadı.');
      return;
    }
    _video.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.startAt > Duration.zero) await _video.seekTo(widget.startAt);
    await _video.play();
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _video.value;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: widget.title == null
            ? null
            : Text(widget.title!, overflow: TextOverflow.ellipsis),
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : !value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => value.isPlaying ? _video.pause() : _video.play(),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: value.aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            VideoPlayer(_video),
                            if (!value.isPlaying)
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 72,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Text(
                            _clock(value.position),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: VideoProgressIndicator(
                              _video,
                              allowScrubbing: true,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              colors: const VideoProgressColors(
                                playedColor: AppTokens.accentEnd,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _clock(value.duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
