import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import '../../data/db/app_database.dart';
import '../../data/db/open_connection.dart';
import '../../data/repositories/notes_repository.dart';
import 'relay_client.dart';

FirebaseOptions _options(RelayConfig config) => FirebaseOptions(
  apiKey: config.firebase['apiKey']!,
  appId: config.firebase['appId']!,
  messagingSenderId: config.firebase['messagingSenderId']!,
  projectId: config.firebase['projectId']!,
);

Future<void> _ensureFirebase(RelayConfig config) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: _options(config));
  }
}

/// Wake-up push while the app is not in the foreground: runs in its own
/// isolate, opens its own DB connection, answers the waiting calls.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await RelayConfig.load();
  if (config == null) return;
  await _ensureFirebase(config);
  final db = AppDatabase(openEncryptedConnection());
  try {
    await RelayClient(config).processWork(db);
    await NotesRepository(db).purgeArchived();
  } catch (e) {
    debugPrint('relay background failed: ${e.runtimeType}');
  } finally {
    await db.close();
  }
}

/// Foreground side of the Claude connection.
class Push {
  Push(this.db);

  final AppDatabase db;
  StreamSubscription<RemoteMessage>? _onMessage;
  StreamSubscription<String>? _onToken;

  /// Last status line for the settings screen.
  final status = ValueNotifier<String>('Bağlı değil');

  /// Starts listening with the stored pairing (no-op when unpaired).
  Future<void> start() async {
    final config = await RelayConfig.load();
    if (config == null) {
      status.value = 'Bağlı değil';
      return;
    }
    try {
      await _ensureFirebase(config);
      FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
      final messaging = FirebaseMessaging.instance;
      final client = RelayClient(config);
      final token = await messaging.getToken();
      if (token == null) throw StateError('FCM token alınamadı');
      await client.register(token);
      _onToken ??= messaging.onTokenRefresh.listen(client.register);
      _onMessage ??= FirebaseMessaging.onMessage.listen((_) => processWork());
      status.value = 'Bağlı';
      await processWork();
    } catch (e) {
      status.value = 'Hata: $e';
    }
  }

  /// Pairs with a new code, then starts.
  Future<void> pair(String code) async {
    final config = RelayConfig.parse(code);
    await config.save();
    await start();
  }

  Future<void> unpair() async {
    await RelayConfig.clear();
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Firebase never started.
    }
    status.value = 'Bağlı değil';
  }

  /// Pulls and answers anything waiting (app open / resume / push).
  Future<void> processWork() async {
    final config = await RelayConfig.load();
    if (config == null) return;
    try {
      await RelayClient(config).processWork(db);
    } catch (e) {
      debugPrint('relay foreground failed: ${e.runtimeType}');
    }
  }

  Future<int> selfTest() async {
    final config = await RelayConfig.load();
    if (config == null) throw StateError('Önce eşleştir');
    return RelayClient(config).selfTest();
  }
}
