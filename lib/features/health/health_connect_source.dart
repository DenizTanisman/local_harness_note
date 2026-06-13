import 'package:health/health.dart';

import '../../data/repositories/health_repository.dart';

/// Health Connect implementation of [HealthSource] (CR-3 §9 / P4). On-device
/// only — no backend, local-first preserved. Every call is defensive: if
/// Health Connect is absent or denied, the methods return false/null and
/// the UI falls back to the onboarding/placeholder state.
class HealthConnectSource implements HealthSource {
  HealthConnectSource();

  final Health _health = Health();
  bool _configured = false;

  static const _types = [
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<bool> isAvailable() async {
    try {
      await _ensureConfigured();
      return _health.isHealthConnectAvailable();
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      await _ensureConfigured();
      return (await _health.hasPermissions(_types)) ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await _ensureConfigured();
      return _health.requestAuthorization(_types);
    } on Object {
      return false;
    }
  }

  @override
  Future<Map<String, double>?> fetchDay(DateTime day) async {
    try {
      await _ensureConfigured();
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: end,
      );
      return aggregateHealthPoints(points);
    } on Object {
      return null;
    }
  }
}

/// Pure aggregation of Health Connect points into our sample kinds. Kept
/// separate so the mapping is unit-testable without a device.
/// [readings] is a list of (type, value, minutes) tuples.
Map<String, double> aggregateReadings(
  List<({HealthDataType type, double value, double minutes})> readings,
) {
  double avg(HealthDataType t) {
    final v = readings.where((r) => r.type == t).map((r) => r.value).toList();
    if (v.isEmpty) return double.nan;
    return v.reduce((a, b) => a + b) / v.length;
  }

  double sum(HealthDataType t) =>
      readings.where((r) => r.type == t).fold(0.0, (a, r) => a + r.value);

  double sleepMinutes() => readings
      .where((r) => r.type == HealthDataType.SLEEP_ASLEEP)
      .fold(0.0, (a, r) => a + r.minutes);

  final out = <String, double>{};
  final rhr = avg(HealthDataType.RESTING_HEART_RATE);
  if (!rhr.isNaN) out['rhr'] = rhr;
  final hr = avg(HealthDataType.HEART_RATE);
  if (!hr.isNaN) out['hr_day'] = hr;
  final sleep = sleepMinutes();
  if (sleep > 0) out['sleep_min'] = sleep;
  final steps = sum(HealthDataType.STEPS);
  if (steps > 0) out['steps'] = steps;
  final kcal = sum(HealthDataType.ACTIVE_ENERGY_BURNED);
  if (kcal > 0) out['active_kcal'] = kcal;
  return out;
}

/// Adapts package [HealthDataPoint]s to [aggregateReadings].
Map<String, double> aggregateHealthPoints(List<HealthDataPoint> points) {
  final readings = [
    for (final p in points)
      if (p.value is NumericHealthValue)
        (
          type: p.type,
          value: (p.value as NumericHealthValue).numericValue.toDouble(),
          minutes: p.dateTo.difference(p.dateFrom).inMinutes.toDouble(),
        ),
  ];
  return aggregateReadings(readings);
}
