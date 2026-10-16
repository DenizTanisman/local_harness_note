import 'package:flutter/material.dart';

import 'settings_page.dart';

/// Gear action in the shell's app bar. Opens Settings.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('settings-button'),
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Ayarlar',
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
    );
  }
}
