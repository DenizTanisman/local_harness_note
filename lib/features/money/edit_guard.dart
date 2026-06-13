import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure-storage key for the edit password (separate from the backup
/// password). Editing existing data asks for it; entering new data never does
/// — so a guest can add entries but not silently rewrite history.
const editPasswordKey = 'edit_password';

/// Gate an edit behind the edit password. On first use (no password set) it
/// asks the owner to create one; afterwards it asks to confirm. Returns true
/// only when the password matches (or was just set). Never logs the value.
Future<bool> requireEditPassword(BuildContext context) async {
  const storage = FlutterSecureStorage();
  final existing = await storage.read(key: editPasswordKey);
  if (!context.mounted) return false;

  if (existing == null) {
    final created = await showDialog<String>(
      context: context,
      builder: (_) => const _SetPasswordDialog(),
    );
    if (created == null || created.isEmpty) return false;
    await storage.write(key: editPasswordKey, value: created);
    return true;
  }

  final entered = await showDialog<String>(
    context: context,
    builder: (_) => const _EnterPasswordDialog(),
  );
  if (entered == null) return false;
  if (entered == existing) return true;
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yanlış şifre.')),
    );
  }
  return false;
}

class _SetPasswordDialog extends StatefulWidget {
  const _SetPasswordDialog();

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Düzenleme şifresi belirle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Verileri düzenlemek için bir şifre belirleyin. Yeni veri '
            'girişinde şifre sorulmaz.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pass,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Şifre'),
          ),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Şifre (tekrar)',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            if (_pass.text.isEmpty) {
              setState(() => _error = 'Boş olamaz');
              return;
            }
            if (_pass.text != _confirm.text) {
              setState(() => _error = 'Şifreler uyuşmuyor');
              return;
            }
            Navigator.pop(context, _pass.text);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

class _EnterPasswordDialog extends StatefulWidget {
  const _EnterPasswordDialog();

  @override
  State<_EnterPasswordDialog> createState() => _EnterPasswordDialogState();
}

class _EnterPasswordDialogState extends State<_EnterPasswordDialog> {
  final _pass = TextEditingController();

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Şifre gerekli'),
      content: TextField(
        controller: _pass,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Düzenleme şifresi'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _pass.text),
          child: const Text('Onayla'),
        ),
      ],
    );
  }
}
