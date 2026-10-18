import 'package:flutter/services.dart';

/// What [VoicePlayer.state] reports.
class VoicePlayerState {
  const VoicePlayerState({
    this.path,
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final String? path;
  final bool playing;
  final Duration position;
  final Duration duration;
}

/// Plays one audio file at a time in a foreground media service (with a
/// "Durdur" notification). Works from background engines too, e.g. a
/// notification action handler.
class VoicePlayer {
  VoicePlayer._();

  static const _channel = MethodChannel('voice_player');

  /// Starts [path], replacing whatever plays. [title] names the clip in the
  /// "Çalınıyor" notification and [image] (a picture file) is shown in it.
  static Future<bool> play(
    String path, {
    String title = '',
    String? image,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('play', {
            'path': path,
            'title': title,
            'image': ?image,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Tests / non-Android hosts.
    }
  }

  static Future<VoicePlayerState> state() async {
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>('state');
      if (raw == null) return const VoicePlayerState();
      return VoicePlayerState(
        path: raw['path'] as String?,
        playing: raw['playing'] == true,
        position: Duration(
          milliseconds: (raw['position'] as num?)?.toInt() ?? 0,
        ),
        duration: Duration(
          milliseconds: (raw['duration'] as num?)?.toInt() ?? 0,
        ),
      );
    } on MissingPluginException {
      return const VoicePlayerState();
    }
  }

  /// Length of the clip at [path], if it can be read.
  static Future<Duration?> duration(String path) async {
    try {
      final ms = await _channel.invokeMethod<int>('duration', path);
      return ms == null ? null : Duration(milliseconds: ms);
    } on MissingPluginException {
      return null;
    }
  }
}
