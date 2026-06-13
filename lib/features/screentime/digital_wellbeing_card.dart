import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/screen_time_repository.dart';
import '../../theme/app_tokens.dart';
import 'screentime_providers.dart';

/// Health → Digital Wellbeing (CR-4 §3.1): daily total (approx) + top-5
/// apps with proportional bars. Shows an onboarding card without Usage
/// Access; re-checks permission and pulls on resume.
class DigitalWellbeingCard extends ConsumerStatefulWidget {
  const DigitalWellbeingCard({super.key});

  @override
  ConsumerState<DigitalWellbeingCard> createState() =>
      _DigitalWellbeingCardState();
}

class _DigitalWellbeingCardState extends ConsumerState<DigitalWellbeingCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning from the system Usage Access page → re-check + pull (§2.4).
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(screenTimePermissionProvider);
      ref.read(screenTimeRepositoryProvider).sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final granted = ref.watch(screenTimePermissionProvider).value ?? false;
    final data = ref.watch(todayScreenTimeProvider).value;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Digital Wellbeing',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (!granted)
              _Onboarding(
                onConnect: () async {
                  await ref
                      .read(screenTimeRepositoryProvider)
                      .openPermissionSettings();
                },
              )
            else if (data == null || data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No screen-time data yet for today.'),
              )
            else
              _Usage(data: data),
          ],
        ),
      ),
    );
  }
}

class _Onboarding extends StatelessWidget {
  const _Onboarding({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Usage Access is required to show screen time.'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const ValueKey('screentime-connect'),
          onPressed: onConnect,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Grant Usage Access'),
        ),
      ],
    );
  }
}

class _Usage extends StatelessWidget {
  const _Usage({required this.data});

  final ScreenTimeDayData data;

  @override
  Widget build(BuildContext context) {
    final top = data.topApps.isEmpty ? 1 : data.topApps.first.foregroundMinutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.phone_android, size: 20),
            const SizedBox(width: 8),
            Text(
              'Screen time ${formatMinutes(data.totalMinutes)} (~)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const Divider(),
        for (final app in data.topApps)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(app.label, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: app.foregroundMinutes / top,
                      minHeight: 8,
                      backgroundColor: AppTokens.surfaceCard,
                      valueColor: const AlwaysStoppedAnimation(
                        AppTokens.accentEnd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatMinutes(app.foregroundMinutes),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
