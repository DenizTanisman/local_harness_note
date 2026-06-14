import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/repositories/health_repository.dart';
import '../../theme/glow_background.dart';
import '../analysis/analysis_providers.dart';
import '../screentime/digital_wellbeing_card.dart';
import '../shared/calendar_row.dart';
import 'health_calc.dart';
import 'health_providers.dart';
import '../settings/settings_button.dart';

/// Health tab (CR-3 §5): a day calendar on top (shared with every page),
/// then manual profile + body (live BMI/BMR/TDEE), then the fetched vitals
/// and Screen Time for the selected day. Selecting a day pulls that day's
/// sensor data so the page stays current without a restart.
class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSelectedDay());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(healthPermissionProvider);
      _syncSelectedDay();
    }
  }

  /// Best-effort pull of the viewed day from Health Connect (silently no-ops
  /// without a source/permission). Screen time is pulled by its own card.
  Future<void> _syncSelectedDay() async {
    final date = ref.read(selectedDateProvider);
    try {
      await ref.read(healthRepositoryProvider).sync(day: parseDateKey(date));
    } on Object {
      // Best-effort; no source / no permission / no platform channel.
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);
    // Re-pull whenever the shared day changes.
    ref.listen<String>(selectedDateProvider, (_, _) => _syncSelectedDay());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health'),
        actions: const [SettingsButton()],
      ),
      body: GlowBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const CalendarRow(),
            const _ProfileCard(),
            const _BodyCard(),
            _VitalsCard(date: date),
            DigitalWellbeingCard(date: date),
          ],
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
  const _VitalsCard({required this.date});

  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals =
        ref.watch(vitalsForDayProvider(date)).value ?? const DailyVitals();
    // VO2max fallback from RHR + age when Health Connect doesn't supply it
    // (CR-3 §10).
    final profile = ref.watch(healthProfileProvider).value;
    final age = HealthCalc.ageOn(profile?.birthDate, DateTime.now());
    final vo2 =
        vitals.vo2max ??
        HealthCalc.vo2maxFallback(age: age, restingHr: vitals.restingHr);

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
            _vital('VO2max', _fmt(vo2, digits: 1)),
            _vital('Steps', _fmt(vitals.steps)),
            _vital('Active kcal', _fmt(vitals.activeKcal)),
            _HealthConnectArea(date: date, hasData: !vitals.isEmpty),
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

/// Connect / sync controls for the fetched-vitals block. Distinguishes
/// "Health Connect not installed" (offer install), "not connected" (request
/// access) and "connected but no data today" (offer a manual sync) so the
/// user isn't left with a single dead button (CR-3 §9 / P4).
class _HealthConnectArea extends ConsumerWidget {
  const _HealthConnectArea({required this.date, required this.hasData});

  final String date;
  final bool hasData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granted = ref.watch(healthPermissionProvider).value ?? false;
    if (granted) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hasData)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Health Connect bağlı ama bu gün için veri yok. '
                  'Saat/uygulamanın Health Connect ile eşitlendiğinden emin olun.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            OutlinedButton.icon(
              key: const ValueKey('health-sync'),
              onPressed: () => _syncNow(context, ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Şimdi senkronize et'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        key: const ValueKey('health-connect'),
        onPressed: () => _connect(context, ref),
        icon: const Icon(Icons.sync),
        label: const Text('Connect a data source'),
      ),
    );
  }

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(healthRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (await repo.sensorNeedsInstall()) {
      if (!context.mounted) return;
      final go = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Health Connect gerekli'),
          content: const Text(
            'Sensör verisini çekmek için Health Connect uygulamasının '
            'kurulu ve güncel olması gerekir. Mağazaya gidilsin mi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kur / Güncelle'),
            ),
          ],
        ),
      );
      if (go == true) await repo.installSensor();
      return;
    }

    final ok = await repo.requestAndSync(day: parseDateKey(date));
    ref.invalidate(healthPermissionProvider);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Erişim verilmedi. Health Connect ayarlarından bu uygulamaya '
            'izin verdiğinizden emin olun.',
          ),
        ),
      );
    }
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(healthRepositoryProvider).sync(day: parseDateKey(date));
    ref.invalidate(healthPermissionProvider);
    messenger.showSnackBar(
      const SnackBar(content: Text('Senkronize edildi.')),
    );
  }
}
