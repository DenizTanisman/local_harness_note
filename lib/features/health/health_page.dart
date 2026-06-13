import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/repositories/health_repository.dart';
import '../../theme/glow_background.dart';
import 'health_calc.dart';
import 'health_providers.dart';

/// Health tab (CR-3 §5): manual profile + body (which feed the live
/// BMI/BMR/TDEE), then a read-only fetched-vitals block (placeholder
/// until a HealthSource is wired in P4).
class HealthPage extends ConsumerWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health')),
      body: GlowBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: const [_ProfileCard(), _BodyCard(), _VitalsCard()],
        ),
      ),
    );
  }
}

String _fmt(double? v, {String suffix = '', int digits = 0}) =>
    v == null ? '—' : '${v.toStringAsFixed(digits)}$suffix';

// ------------------------------------------------------------------ Profile

class _ProfileCard extends ConsumerStatefulWidget {
  const _ProfileCard();

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  final _height = TextEditingController();
  String? _sex;
  String? _activity;
  DateTime? _birth;
  bool _seeded = false;

  @override
  void dispose() {
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(healthProfileProvider).value;
    if (!_seeded && profile != null) {
      _seeded = true;
      _height.text = profile.heightCm?.toStringAsFixed(0) ?? '';
      _sex = profile.sex;
      _activity = profile.activityLevel;
      _birth = profile.birthDate == null
          ? null
          : parseDateKey(profile.birthDate!);
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Profile', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickBirth,
                    child: Text(
                      _birth == null ? 'Birth date' : dateKey(_birth!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sex,
                    decoration: const InputDecoration(labelText: 'Sex'),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Male')),
                      DropdownMenuItem(value: 'F', child: Text('Female')),
                    ],
                    onChanged: (v) => setState(() => _sex = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _height,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      suffixText: 'cm',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _activity,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Activity'),
                    items: [
                      for (final a in activityLevels)
                        DropdownMenuItem(value: a, child: Text(a)),
                    ],
                    onChanged: (v) => setState(() => _activity = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _save, child: const Text('Save profile')),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birth = picked);
  }

  Future<void> _save() async {
    await ref
        .read(healthRepositoryProvider)
        .saveProfile(
          birthDate: _birth == null ? null : dateKey(_birth!),
          sex: _sex,
          heightCm: double.tryParse(_height.text),
          activityLevel: _activity,
        );
  }
}

// --------------------------------------------------------------------- Body

class _BodyCard extends ConsumerStatefulWidget {
  const _BodyCard();

  @override
  ConsumerState<_BodyCard> createState() => _BodyCardState();
}

class _BodyCardState extends ConsumerState<_BodyCard> {
  final _weight = TextEditingController();
  final _fat = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _weight.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = ref.watch(latestBodyProvider).value;
    if (!_seeded && body != null) {
      _seeded = true;
      _weight.text = body.weightKg?.toStringAsFixed(1) ?? '';
      _fat.text = body.bodyFatPct?.toStringAsFixed(1) ?? '';
    }
    final stats = ref.watch(bodyStatsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Body', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      suffixText: 'kg',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fat,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Body fat',
                      suffixText: '%',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _save, child: const Text('Save body')),
            const SizedBox(height: 8),
            // Recomputed on every save (CR-3 §10).
            Text(
              'BMI ${_fmt(stats.bmi, digits: 1)}   '
              'BMR ${_fmt(stats.bmr)}   '
              'TDEE ${_fmt(stats.tdeeStatic)}',
            ),
            if (stats.tdeeStatic == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Fill profile + weight to compute your calorie target.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(healthRepositoryProvider)
        .saveBody(
          date: dateKey(DateTime.now()),
          weightKg: double.tryParse(_weight.text),
          bodyFatPct: double.tryParse(_fat.text),
        );
  }
}

// ------------------------------------------------------------------ Vitals

class _VitalsCard extends ConsumerWidget {
  const _VitalsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals = ref.watch(todayVitalsProvider).value ?? const DailyVitals();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fetched (sensors)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            _vital('Resting HR', _fmt(vitals.restingHr, suffix: ' bpm')),
            _vital('Daytime HR', _fmt(vitals.hrDay, suffix: ' bpm')),
            _vital(
              'Sleep',
              vitals.sleepMin == null
                  ? '—'
                  : '${(vitals.sleepMin! / 60).floor()}h '
                        '${(vitals.sleepMin! % 60).round()}m',
            ),
            _vital('VO2max', _fmt(vitals.vo2max, digits: 1)),
            _vital('Steps', _fmt(vitals.steps)),
            if (vitals.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  // Health Connect wiring lands in CR3-P4.
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sensor sync arrives in a later update.'),
                    ),
                  ),
                  icon: const Icon(Icons.sync),
                  label: const Text('Connect a data source'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _vital(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    ),
  );
}
