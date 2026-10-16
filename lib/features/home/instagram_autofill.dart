import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/hub_bridge.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../settings/settings_providers.dart';
import 'home_providers.dart';

/// Instagram's package — its measured minutes auto-fill the metric (§3.3).
const instagramPackage = 'com.instagram.android';

final _dateRe = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Pure mapping from the Program app's hub snapshot (contract §4,
/// `data.screenTime.days[]`) to day → Instagram foreground minutes. Days
/// without Instagram, with 0 minutes, or with malformed fields are left
/// out — the same "only measured usage" rule as the old on-device source.
/// Anything that is not a program snapshot maps to an empty result.
Map<String, double> instagramMinutesFromProgram(
  Map<String, Object?>? snapshot,
) {
  final result = <String, double>{};
  if (snapshot == null || snapshot['app'] != 'program') return result;
  final data = snapshot['data'];
  if (data is! Map) return result;
  final screenTime = data['screenTime'];
  if (screenTime is! Map) return result;
  final days = screenTime['days'];
  if (days is! List) return result;
  for (final day in days) {
    if (day is! Map) continue;
    final date = day['date'];
    final apps = day['apps'];
    if (date is! String || !_dateRe.hasMatch(date) || apps is! List) continue;
    for (final app in apps) {
      if (app is! Map || app['package'] != instagramPackage) continue;
      final minutes = app['min'];
      if (minutes is num && minutes > 0) result[date] = minutes.toDouble();
    }
  }
  return result;
}

/// CR-4 §3.3 auto-fill, now fed by the Program app (which owns usage
/// stats) instead of an on-device UsageStats source. Same rules as before:
/// the setting gates it (default on), a manual edit wins, written values
/// are stamped value_source = 'auto'. Silent no-op when Program is not
/// installed, has not published yet, or the platform side is missing.
class InstagramAutofill {
  InstagramAutofill(
    this.entries,
    this.settings, {
    Future<Map<String, Object?>?> Function(String app)? readPeer,
  }) : _readPeer = readPeer ?? HubBridge.readPeerSnapshot;

  final EntryRepository entries;
  final SettingsRepository settings;
  final Future<Map<String, Object?>?> Function(String app) _readPeer;

  /// Returns how many days were written.
  Future<int> run() async {
    final values = await settings.loadAll();
    if (values['autofill_instagram'] == 'false') return 0;
    final minutesByDay = instagramMinutesFromProgram(
      await _readPeer('program'),
    );
    var written = 0;
    for (final MapEntry(key: date, value: minutes) in minutesByDay.entries) {
      if (await entries.autofillInstagram(date: date, minutes: minutes)) {
        written++;
      }
    }
    return written;
  }
}

final instagramAutofillProvider = Provider<InstagramAutofill>(
  (ref) => InstagramAutofill(
    ref.watch(entryRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  ),
);
