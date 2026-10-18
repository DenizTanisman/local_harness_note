import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:voice_player/voice_player.dart';

import '../../core/system_channel.dart';
import '../../data/repositories/attachments_repository.dart';

/// Pictures are shrunk natively (EXIF rotation applied) to a viewing copy
/// and a small one for notifications; audio and video are copied and
/// measured, and a video also gets a poster frame.
Future<({bool ok, int? durationMs})> deviceAttachmentImporter(
  String src,
  String kind,
  File target,
) async {
  if (kind == 'image') {
    if (!await SystemChannel.scaleImage(src, target.path)) {
      return (ok: false, durationMs: null);
    }
    await SystemChannel.scaleImage(
      src,
      p.join(
        target.parent.path,
        '${p.basenameWithoutExtension(target.path)}_n.jpg',
      ),
      max: AttachmentsRepository.notificationSide,
    );
    return (ok: true, durationMs: null);
  }
  await File(src).copy(target.path);
  if (kind == 'video') {
    // Poster for the note and the reminder notification.
    await SystemChannel.videoFrame(
      target.path,
      p.join(
        target.parent.path,
        '${p.basenameWithoutExtension(target.path)}_n.jpg',
      ),
      max: AttachmentsRepository.notificationSide,
    );
  }
  final length = await VoicePlayer.duration(target.path);
  return (ok: true, durationMs: length?.inMilliseconds);
}
