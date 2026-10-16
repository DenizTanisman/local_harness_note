import 'package:flutter/services.dart';

/// FLAG_SECURE wrapper (spec §11.6): blocks screenshots/recents preview
/// app-wide when the setting is enabled.
class SecureWindow {
  static const _channel = MethodChannel('local_harness_not/secure_window');

  static Future<void> enable() => _invoke('enable');

  static Future<void> disable() => _invoke('disable');

  static Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Tests / non-Android hosts: no-op.
    }
  }
}
