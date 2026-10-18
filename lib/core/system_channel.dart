import 'package:flutter/services.dart';

/// Something Android asked the app to do: open a blank note (home-screen
/// widget), a note pre-filled with shared text (share sheet) or a lesson
/// (an HTML file opened with / shared to Not).
class AppIntent {
  const AppIntent.newNote()
    : sharedText = null,
      lessonHtml = null,
      mediaPath = null,
      mediaMime = null;
  const AppIntent.share(String text)
    : sharedText = text,
      lessonHtml = null,
      mediaPath = null,
      mediaMime = null;
  const AppIntent.lesson(String html)
    : sharedText = null,
      lessonHtml = html,
      mediaPath = null,
      mediaMime = null;

  /// A voice message / picture shared to Not (copied into the cache).
  const AppIntent.media(String path, String mime, {String? text})
    : sharedText = text,
      lessonHtml = null,
      mediaPath = path,
      mediaMime = mime;

  final String? sharedText;
  final String? lessonHtml;
  final String? mediaPath;
  final String? mediaMime;
}

/// Native glue (MainActivity, `local_harness_not/system`): share sheet and
/// widget intents, battery-optimization exemption for the wake-up push.
class SystemChannel {
  SystemChannel._();

  static const _channel = MethodChannel('local_harness_not/system');

  static AppIntent? _parse(Object? raw) {
    if (raw is! Map) return null;
    return switch (raw['action']) {
      'new_note' => const AppIntent.newNote(),
      'share'
          when raw['text'] is String && (raw['text'] as String).isNotEmpty =>
        AppIntent.share(raw['text'] as String),
      'share_media' when raw['path'] is String && raw['mime'] is String =>
        AppIntent.media(
          raw['path'] as String,
          raw['mime'] as String,
          text: raw['text'] as String?,
        ),
      'lesson' when raw['html'] is String => AppIntent.lesson(
        raw['html'] as String,
      ),
      _ => null,
    };
  }

  /// The intent that launched the app, consumed once.
  static Future<AppIntent?> takeLaunchIntent() async {
    try {
      return _parse(await _channel.invokeMethod<Object?>('takeLaunchIntent'));
    } on MissingPluginException {
      return null;
    }
  }

  /// Intents that arrive while the app is running.
  static void listen(void Function(AppIntent intent) onIntent) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onIntent') {
        final intent = _parse(call.arguments);
        if (intent != null) onIntent(intent);
      }
      return null;
    });
  }

  /// Opens [url] in its own app when one is installed (YouTube, Instagram,
  /// X …), else in the browser. False when nothing could open it.
  static Future<bool> openUrl(String url) async {
    try {
      return await _channel.invokeMethod<bool>('openUrl', url) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Copies a lesson to Documents/Not/Dersler/[name] (shared storage, so
  /// file managers and browsers can open it). Returns the path shown to
  /// the user, or null when it could not be written.
  static Future<String?> saveLessonFile(String name, String html) async {
    try {
      return await _channel.invokeMethod<String>('saveLessonFile', {
        'name': name,
        'html': html,
      });
    } on MissingPluginException {
      return null;
    }
  }

  /// Writes [src] as a JPEG of at most [max] px on its long side to [dst]
  /// (rotation from EXIF applied).
  static Future<bool> scaleImage(
    String src,
    String dst, {
    int max = 1600,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('scaleImage', {
            'src': src,
            'dst': dst,
            'max': max,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Opens the system picker in [place] ('download' | 'whatsapp' |
  /// 'lessons' | null: wherever it was last), HTML files only. Returns the
  /// file's text, '' when it could not be read, null when cancelled.
  static Future<String?> pickLesson(String? place) async {
    try {
      return await _channel.invokeMethod<String>('pickLesson', place);
    } on MissingPluginException {
      return null;
    }
  }

  /// Saves the copy, then lets the user open it in another app.
  static Future<bool> openLessonFile(String name, String html) async {
    try {
      return await _channel.invokeMethod<bool>('openLessonFile', {
            'name': name,
            'html': html,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Shows the quick-note bubble; returns [bubbleStatus].
  static Future<BubbleStatus?> showBubble() async {
    try {
      return BubbleStatus._(
        await _channel.invokeMethod<Map<Object?, Object?>>('showBubble'),
      );
    } on MissingPluginException {
      return null;
    }
  }

  static Future<void> hideBubble() async {
    try {
      await _channel.invokeMethod<void>('hideBubble');
    } on MissingPluginException {
      // Tests / non-Android hosts.
    }
  }

  static Future<BubbleStatus?> bubbleStatus() async {
    try {
      return BubbleStatus._(
        await _channel.invokeMethod<Map<Object?, Object?>>('bubbleStatus'),
      );
    } on MissingPluginException {
      return null;
    }
  }

  /// Android's per-app bubble settings ("Tüm görüşmeler baloncuk olabilir").
  static Future<void> openBubbleSettings() async {
    try {
      await _channel.invokeMethod<void>('openBubbleSettings');
    } on MissingPluginException {
      // Tests / non-Android hosts.
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
    } on MissingPluginException {
      // Tests / non-Android hosts.
    }
  }
}

/// Whether Android will float the quick-note bubble.
class BubbleStatus {
  BubbleStatus._(Map<Object?, Object?>? raw)
    : globalOn = raw?['globalOn'] == true,
      appPreference = '${raw?['appPreference'] ?? 'none'}',
      channelCanBubble = raw?['channelCanBubble'] == true,
      showing = raw?['showing'] == true;

  /// The phone-wide "floating notifications: bubbles" switch.
  final bool globalOn;

  /// 'all' | 'selected' | 'none' for this app.
  final String appPreference;
  final bool channelCanBubble;
  final bool showing;

  bool get allowed =>
      globalOn &&
      (appPreference == 'all' ||
          (appPreference == 'selected' && channelCanBubble));
}
