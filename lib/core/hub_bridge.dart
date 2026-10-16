import 'dart:convert';

import 'package:flutter/services.dart';

/// Dart side of the Local Harness hub channel (docs/HUB_CONTRACT.md §3).
/// Same API in every app of the split. Every call is best-effort: a missing
/// platform side (widget tests, non-Android hosts), an absent peer app or a
/// denied permission degrade to a no-op / null / false — never a throw.
class HubBridge {
  HubBridge._();

  static const channel = MethodChannel('local_harness/hub');

  /// Writes [snapshot] (schema 1, §4) to filesDir/hub_snapshot.json, where
  /// this app's HubProvider serves it to the hub.
  static Future<void> publishSnapshot(Map<String, Object?> snapshot) async {
    try {
      await channel.invokeMethod<void>('publishSnapshot', jsonEncode(snapshot));
    } on MissingPluginException {
      // Tests / non-Android hosts: no-op.
    } on PlatformException {
      // Disk full etc. — the next publish retries.
    }
  }

  /// A peer app's latest snapshot ('para' | 'not' | 'program'), or null when
  /// it is not installed, never published, or unreadable.
  static Future<Map<String, Object?>?> readPeerSnapshot(String app) async {
    try {
      final raw = await channel.invokeMethod<String>('readPeerSnapshot', app);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } on FormatException {
      return null;
    }
  }

  static Future<bool> isInstalled(String app) async {
    try {
      return await channel.invokeMethod<bool>('isInstalled', app) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens a peer app, optionally on [route] (passed as the `lh_route`
  /// intent extra).
  static Future<bool> launchApp(String app, {String? route}) async {
    try {
      return await channel.invokeMethod<bool>('launchApp', {
            'app': app,
            'route': route,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
