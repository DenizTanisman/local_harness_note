import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:voice_player/voice_player.dart';

/// "▶ Oynat" on a reminder with a voice clip. The id carries the clip's
/// path and the reminder's title, so the background engine that runs the
/// action needs no database.
const playActionPrefix = 'play:';

String playActionId(String path, String title, {String? image}) =>
    '$playActionPrefix${jsonEncode({'p': path, 't': title, 'i': ?image})}';

/// "🎬 İzle" on a reminder with a video: Android plays it in a floating
/// picture-in-picture window over whatever is on screen (MainActivity
/// hands the intent to VideoPipActivity; the app itself stays closed).
const watchActionPrefix = 'watch:';

String watchActionId(String path, String title) =>
    '$watchActionPrefix${jsonEncode({'p': path, 't': title})}';

/// Handles a notification action; false when it is not one of ours.
Future<bool> handleNotificationAction(NotificationResponse response) async {
  final id = response.actionId;
  if (id == null || !id.startsWith(playActionPrefix)) return false;
  final Object? data;
  try {
    data = jsonDecode(id.substring(playActionPrefix.length));
  } on FormatException {
    return true;
  }
  if (data is Map && data['p'] is String) {
    await VoicePlayer.play(
      data['p'] as String,
      title: '${data['t'] ?? ''}',
      image: data['i'] as String?,
    );
  }
  return true;
}

/// Runs in a background engine when an action is tapped (the app may not
/// be running): plays the clip without opening the app.
@pragma('vm:entry-point')
Future<void> notificationActionBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  await handleNotificationAction(response);
}
