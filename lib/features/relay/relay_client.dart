import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/attachments_repository.dart';
import '../notes/attachment_importer.dart';
import 'mcp_tools.dart';

/// What the pairing code carries (spec §8): the relay Worker and the
/// Firebase project used only for the wake-up push.
class RelayConfig {
  const RelayConfig({
    required this.url,
    required this.secret,
    required this.firebase,
  });

  final String url;
  final String secret;

  /// apiKey, appId, messagingSenderId, projectId
  final Map<String, String> firebase;

  static const _storageKey = 'relay_config';

  /// Parses the pairing code (JSON) shown by `worker/setup.sh`.
  static RelayConfig parse(String code) {
    final json = jsonDecode(code.trim());
    if (json is! Map) throw const FormatException('Bağlantı kodu JSON değil');
    final url = '${json['url'] ?? ''}'.replaceAll(RegExp(r'/+$'), '');
    final secret = '${json['secret'] ?? ''}';
    final fb = json['firebase'];
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      throw const FormatException('url eksik');
    }
    if (secret.length < 16) throw const FormatException('secret eksik');
    if (fb is! Map) throw const FormatException('firebase eksik');
    final firebase = {
      for (final k in ['apiKey', 'appId', 'messagingSenderId', 'projectId'])
        k: '${fb[k] ?? ''}',
    };
    if (firebase.values.any((v) => v.isEmpty)) {
      throw const FormatException('firebase alanları eksik');
    }
    return RelayConfig(url: url, secret: secret, firebase: firebase);
  }

  String encode() =>
      jsonEncode({'url': url, 'secret': secret, 'firebase': firebase});

  static const _storage = FlutterSecureStorage();

  static Future<RelayConfig?> load() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      return raw == null ? null : parse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save() => _storage.write(key: _storageKey, value: encode());

  static Future<void> clear() => _storage.delete(key: _storageKey);
}

/// Talks to the relay Worker: registers the push token, pulls the waiting
/// tool calls, runs them on the local DB and posts the answers back.
class RelayClient {
  RelayClient(this.config, {HttpClient? http}) : _http = http ?? HttpClient();

  final RelayConfig config;
  final HttpClient _http;

  static bool _busy = false;
  static bool _again = false;

  Future<Object?> _call(String method, String path, [Object? body]) async {
    final request = await _http
        .openUrl(method, Uri.parse('${config.url}$path'))
        .timeout(const Duration(seconds: 15));
    request.headers.set('authorization', 'Bearer ${config.secret}');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(body)));
    }
    final response = await request.close().timeout(const Duration(seconds: 40));
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 300) {
      throw HttpException('relay $path → ${response.statusCode}: $text');
    }
    return text.isEmpty ? null : jsonDecode(text);
  }

  /// A queued clip, sent as base64 text.
  Future<List<int>> _blob(String id) async {
    final request = await _http
        .getUrl(
          Uri.parse('${config.url}/phone/blob/${Uri.encodeComponent(id)}'),
        )
        .timeout(const Duration(seconds: 15));
    request.headers.set('authorization', 'Bearer ${config.secret}');
    final response = await request.close().timeout(const Duration(seconds: 60));
    final text = await response.transform(utf8.decoder).join();
    // Gone (already handed over): the note still comes, without the clip.
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 200) {
      throw HttpException('blob → ${response.statusCode}');
    }
    return base64Decode(text);
  }

  Future<void> register(String fcmToken) =>
      _call('POST', '/phone/register', {'token': fcmToken});

  /// Round trip through Claude's path: the Worker pushes this phone and
  /// waits for the answer. Returns the measured milliseconds.
  Future<int> selfTest() async {
    final result = await _call('POST', '/phone/selftest') as Map;
    if (result['ok'] != true) throw HttpException('${result['error']}');
    return (result['ms'] as num).toInt();
  }

  /// Runs every waiting call (live requests and queued writes). Safe to
  /// call from several triggers at once — overlapping calls coalesce.
  Future<int> processWork(AppDatabase db) async {
    if (_busy) {
      _again = true;
      return 0;
    }
    _busy = true;
    var handled = 0;
    try {
      do {
        _again = false;
        final work = await _call('GET', '/phone/work') as Map;
        final items = [
          ...(work['inflight'] as List? ?? const []),
          ...(work['queued'] as List? ?? const []),
        ].cast<Map>();
        final tools = McpTools(
          db,
          fetchBlob: _blob,
          attachments: AttachmentsRepository(
            db,
            importer: deviceAttachmentImporter,
          ),
        );
        for (final item in items) {
          final reqId = '${item['reqId']}';
          Map<String, Object?> payload;
          try {
            final args = (item['args'] as Map?)?.cast<String, Object?>();
            final result = await tools.execute(
              '${item['tool']}',
              args ?? const {},
              reqId: reqId,
            );
            payload = {'reqId': reqId, 'ok': true, 'result': result};
          } on RetryLater {
            continue; // stays queued on the relay
          } on ToolError catch (e) {
            payload = {'reqId': reqId, 'ok': false, 'error': e.message};
          } catch (e) {
            payload = {'reqId': reqId, 'ok': false, 'error': 'Telefon hatası'};
            debugPrint('relay tool failed: ${e.runtimeType}');
          }
          await _call('POST', '/phone/result', payload);
          handled++;
        }
      } while (_again);
    } finally {
      _busy = false;
    }
    return handled;
  }
}
