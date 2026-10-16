import 'package:flutter/services.dart';

/// Something Android asked the app to do: open a blank note (home-screen
/// widget) or a note pre-filled with shared text (share sheet).
class AppIntent {
  const AppIntent.newNote() : sharedText = null;
  const AppIntent.share(String text) : sharedText = text;

  final String? sharedText;
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
