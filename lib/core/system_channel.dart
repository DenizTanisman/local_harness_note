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
