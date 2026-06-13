import 'package:flutter/material.dart';

import 'settings_page.dart';

/// Fixed gear action for every tab's AppBar (CR-3 follow-up): replaces the
/// hard-to-find hamburger drawer. Opens Settings (which links to
/// Export / Import).
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('settings-button'),
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Settings',
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
    );
  }
}
