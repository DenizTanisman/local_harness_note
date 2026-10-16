import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/secure_window.dart';
import '../../core/system_channel.dart';
import '../../data/io/backup_service.dart';
import '../../data/repositories/notes_repository.dart';
import '../../theme/glow_background.dart';
import '../backup/backup_worker.dart';
import '../gemma/gemma_service.dart';
import '../notes/notes_providers.dart';
import '../notifications/notification_service.dart';
import 'settings_providers.dart';

const _backupPasswordKey = 'backup_password';
const bubbleEnabledKey = 'bubble_enabled';

/// Settings (spec §3.4): reminders, Gemma, the Claude connection, privacy
/// and backup.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const {};
    final repo = ref.read(settingsRepositoryProvider);
    final times =
        (settings[NotesRepository.reminderTimesKey] ??
                NotesRepository.defaultReminderTimes.join(','))
            .split(',');

    Future<void> setTimes(List<String> next) async {
      next.sort();
      await repo.set(NotesRepository.reminderTimesKey, next.join(','));
    }

    Future<String?> pickTime(String? current) async {
      final parts = (current ?? '12:00').split(':');
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        ),
      );
      if (picked == null) return null;
      return '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: GlowBackground(
        child: ListView(
          children: [
            const _SectionHeader('Hatırlatmalar'),
            SwitchListTile(
              title: const Text('Hatırlatma bildirimleri'),
              subtitle: const Text('Listeden sıradaki not, her gün'),
              value:
                  settings[NotificationService.remindersEnabledKey] != 'false',
              onChanged: (on) => repo.set(
                NotificationService.remindersEnabledKey,
                on.toString(),
              ),
            ),
            for (var i = 0; i < times.length; i++)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(times[i]),
                onTap: () async {
                  final t = await pickTime(times[i]);
                  if (t != null) await setTimes([...times]..[i] = t);
                },
                trailing: times.length <= 1
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setTimes([...times]..removeAt(i)),
                      ),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Saat ekle'),
              onTap: () async {
                final t = await pickTime(null);
                if (t != null && !times.contains(t)) {
                  await setTimes([...times, t]);
                }
              },
            ),
            const Divider(),
            const _SectionHeader('Hızlı not baloncuğu'),
            const _BubbleSection(),
            const Divider(),
            const _SectionHeader('Gemma (cihazda)'),
            const _GemmaTile(),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Gemma komutu (prompt)'),
              subtitle: Text(
                (settings[GemmaService.promptKey] ?? GemmaService.defaultPrompt)
                    .split('\n')
                    .first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                final value = await showDialog<String>(
                  context: context,
                  builder: (_) => _PromptDialog(
                    initial:
                        settings[GemmaService.promptKey] ??
                        GemmaService.defaultPrompt,
                  ),
                );
                if (value == null) return;
                value == GemmaService.defaultPrompt
                    ? await repo.remove(GemmaService.promptKey)
                    : await repo.set(GemmaService.promptKey, value);
              },
            ),
            const Divider(),
            const _SectionHeader('Claude bağlantısı'),
            const _ClaudeSection(),
            const Divider(),
            const _SectionHeader('Gizlilik'),
            SwitchListTile(
              title: const Text('Ekran görüntüsünü engelle'),
              subtitle: const Text('Son uygulamalar önizlemesi de gizlenir'),
              value: settings['flag_secure'] == 'true',
              onChanged: (on) async {
                await repo.set('flag_secure', on.toString());
                on ? await SecureWindow.enable() : await SecureWindow.disable();
              },
            ),
            const Divider(),
            const _SectionHeader('Yedek'),
            ListTile(
              title: const Text('Yedek klasörü'),
              subtitle: Text(settings['backup_dir_uri'] ?? 'Seçilmedi'),
              trailing: const Icon(Icons.folder_open),
              onTap: () async {
                final dir = await FilePicker.platform.getDirectoryPath();
                if (dir != null) await repo.set('backup_dir_uri', dir);
              },
            ),
            SwitchListTile(
              title: const Text('Haftalık otomatik yedek'),
              subtitle: const Text('Pazar 03:00, şifreli'),
              value: settings['backup_enabled'] == 'true',
              onChanged: (on) async {
                if (on && !await _ensurePassword(context)) return;
                await repo.set('backup_enabled', on.toString());
                on
                    ? await BackupScheduler.register()
                    : await BackupScheduler.cancel();
              },
            ),
            ListTile(
              title: const Text('Şimdi yedekle'),
              trailing: const Icon(Icons.backup),
              onTap: () => _backupNow(context, ref, settings),
            ),
            ListTile(
              title: const Text('Yedek şifresini değiştir'),
              subtitle: const Text('Sonraki yedekler yeni şifreyle alınır'),
              trailing: const Icon(Icons.password),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final password = await showDialog<String>(
                  context: context,
                  builder: (context) => const _PasswordDialog(
                    title: 'Yeni yedek şifresi',
                    warning:
                        'Eski yedekler eski şifreyle açılır. Bu şifreyi '
                        'kaybedersen yeni yedekler AÇILAMAZ.',
                  ),
                );
                if (password == null || password.isEmpty) return;
                await const FlutterSecureStorage().write(
                  key: _backupPasswordKey,
                  value: password,
                );
                messenger.showSnackBar(
                  const SnackBar(content: Text('Yedek şifresi değişti')),
                );
              },
            ),
            ListTile(
              title: const Text('Yedekten geri yükle'),
              subtitle: const Text('.dtbak dosyası + yedek şifresi'),
              trailing: const Icon(Icons.restore),
              onTap: () => _restore(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _ensurePassword(BuildContext context) async {
    const storage = FlutterSecureStorage();
    if (await storage.read(key: _backupPasswordKey) != null) return true;
    if (!context.mounted) return false;
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _PasswordDialog(
        title: 'Yedek şifresi',
        warning: 'Bu şifreyi kaybedersen yedekler AÇILAMAZ.',
      ),
    );
    if (password == null || password.isEmpty) return false;
    await storage.write(key: _backupPasswordKey, value: password);
    return true;
  }

  Future<void> _backupNow(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> settings,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final dir = settings['backup_dir_uri'];
    if (dir == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Önce yedek klasörü seç.')),
      );
      return;
    }
    if (!await _ensurePassword(context)) return;
    final password = await const FlutterSecureStorage().read(
      key: _backupPasswordKey,
    );
    if (password == null) return;
    try {
      final file = await ref
          .read(backupServiceProvider)
          .backupTo(Directory(dir), password);
      messenger.showSnackBar(
        SnackBar(content: Text('Yedeklendi: ${file.path}')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Yedek başarısız: $e')));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.platform.pickFiles();
    final path = picked?.files.single.path;
    if (path == null || !context.mounted) return;
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _PasswordDialog(title: 'Yedek şifresi'),
    );
    if (password == null || password.isEmpty) return;
    try {
      final zip = await BackupService.decryptBackup(
        await File(path).readAsBytes(),
        password,
      );
      final count = await ref.read(backupServiceProvider).restoreZip(zip);
      messenger.showSnackBar(
        SnackBar(content: Text('$count not geri yüklendi')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Açılamadı: dosya ya da şifre yanlış')),
      );
    }
  }
}

class _GemmaTile extends ConsumerWidget {
  const _GemmaTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gemma = ref.watch(gemmaServiceProvider);
    if (gemma.status.value is GemmaUnknown) gemma.refresh();
    return ValueListenableBuilder<GemmaStatus>(
      valueListenable: gemma.status,
      builder: (context, status, _) => switch (status) {
        GemmaReady() => ListTile(
          leading: const Icon(Icons.auto_awesome),
          title: const Text('Gemma 4 E2B hazır'),
          subtitle: const Text('İnternetsiz çalışır'),
          trailing: TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Model silinsin mi?'),
                  content: Text(
                    '${GemmaService.modelSizeLabel} yer açılır; ✨ için '
                    'yeniden indirmen gerekir.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Vazgeç'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );
              if (ok == true) await gemma.deleteModel();
            },
            child: const Text('Sil'),
          ),
        ),
        GemmaDownloading(:final percent) => ListTile(
          leading: const Icon(Icons.downloading),
          title: Text('İndiriliyor… %$percent'),
          subtitle: LinearProgressIndicator(value: percent / 100),
          trailing: TextButton(
            onPressed: gemma.cancelDownload,
            child: const Text('İptal'),
          ),
        ),
        GemmaUnknown() => const ListTile(title: Text('Kontrol ediliyor…')),
        GemmaNotInstalled() || GemmaFailed() => ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Gemma modelini indir'),
          subtitle: Text(
            status is GemmaFailed
                ? status.message
                : '${GemmaService.modelSizeLabel} · bir kez, Wi-Fi önerilir',
          ),
          onTap: gemma.download,
        ),
      },
    );
  }
}

/// Floating quick-note bubble: on/off, and what Android still needs.
class _BubbleSection extends ConsumerStatefulWidget {
  const _BubbleSection();

  @override
  ConsumerState<_BubbleSection> createState() => _BubbleSectionState();
}

class _BubbleSectionState extends ConsumerState<_BubbleSection>
    with WidgetsBindingObserver {
  BubbleStatus? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Android's bubble settings: re-check and show it.
    if (state == AppLifecycleState.resumed) _refresh(reshow: true);
  }

  Future<void> _refresh({bool reshow = false}) async {
    final settings = await ref.read(settingsRepositoryProvider).loadAll();
    var status = await SystemChannel.bubbleStatus();
    if (reshow &&
        settings[bubbleEnabledKey] == 'true' &&
        status != null &&
        status.allowed &&
        !status.showing) {
      status = await SystemChannel.showBubble();
    }
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? const {};
    final on = settings[bubbleEnabledKey] == 'true';
    final status = _status;
    return Column(
      children: [
        SwitchListTile(
          key: const Key('bubble-switch'),
          title: const Text('Baloncukla not al'),
          subtitle: const Text(
            'Her uygulamanın üstünde yüzen baloncuk; dokun, yaz, kaydet',
          ),
          value: on,
          onChanged: (value) async {
            await ref
                .read(settingsRepositoryProvider)
                .set(bubbleEnabledKey, value.toString());
            if (!value) await SystemChannel.hideBubble();
            final next = value
                ? await SystemChannel.showBubble()
                : await SystemChannel.bubbleStatus();
            if (mounted) setState(() => _status = next);
          },
        ),
        if (on && status != null && !status.allowed)
          ListTile(
            leading: const Icon(Icons.bubble_chart_outlined),
            title: const Text('Baloncuk iznini ver'),
            subtitle: Text(
              status.globalOn
                  ? 'Android ayarında "Tüm görüşmeler baloncuk olabilir"i seç'
                  : 'Telefonun ayarı: Bildirimler › Gelişmiş › Yüzen '
                        'bildirimler › Baloncuklar',
            ),
            onTap: SystemChannel.openBubbleSettings,
          ),
        if (on && status != null && status.allowed && !status.showing)
          ListTile(
            leading: const Icon(Icons.bubble_chart),
            title: const Text('Baloncuğu yeniden göster'),
            onTap: () async {
              final next = await SystemChannel.showBubble();
              if (mounted) setState(() => _status = next);
            },
          ),
      ],
    );
  }
}

class _ClaudeSection extends ConsumerStatefulWidget {
  const _ClaudeSection();

  @override
  ConsumerState<_ClaudeSection> createState() => _ClaudeSectionState();
}

class _ClaudeSectionState extends ConsumerState<_ClaudeSection> {
  bool? _batteryOk;
  String? _test;

  @override
  void initState() {
    super.initState();
    _checkBattery();
  }

  Future<void> _checkBattery() async {
    final ok = await SystemChannel.isIgnoringBatteryOptimizations();
    if (mounted) setState(() => _batteryOk = ok);
  }

  @override
  Widget build(BuildContext context) {
    final push = ref.watch(pushProvider);
    return ValueListenableBuilder<String>(
      valueListenable: push.status,
      builder: (context, status, _) {
        final paired = status == 'Bağlı';
        return Column(
          children: [
            ListTile(
              leading: Icon(paired ? Icons.link : Icons.link_off),
              title: Text(status),
              subtitle: const Text(
                'Claude notlarını telefondan okur; özel notlar hariç',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: Text(
                paired
                    ? 'Bağlantı kodunu değiştir'
                    : 'Bağlantı kodunu yapıştır',
              ),
              subtitle: const Text('worker/setup.sh çıktısı'),
              onTap: () async {
                final clip = await Clipboard.getData('text/plain');
                if (!context.mounted) return;
                final code = await showDialog<String>(
                  context: context,
                  builder: (_) => _PasteDialog(initial: clip?.text ?? ''),
                );
                if (code == null) return;
                try {
                  await push.pair(code);
                } on FormatException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kod geçersiz: ${e.message}')),
                    );
                  }
                }
              },
            ),
            if (paired)
              ListTile(
                leading: const Icon(Icons.network_check),
                title: const Text('Bağlantıyı test et'),
                subtitle: _test == null ? null : Text(_test!),
                onTap: () async {
                  setState(() => _test = 'Test ediliyor…');
                  try {
                    final ms = await push.selfTest();
                    setState(() => _test = 'Çalışıyor · $ms ms');
                  } catch (e) {
                    setState(() => _test = 'Başarısız: $e');
                  }
                },
              ),
            if (_batteryOk == false)
              ListTile(
                leading: const Icon(Icons.battery_alert),
                title: const Text('Pil optimizasyonunu kapat'),
                subtitle: const Text(
                  'Telefon uykudayken de Claude’a cevap verebilmek için',
                ),
                onTap: () async {
                  await SystemChannel.requestIgnoreBatteryOptimizations();
                  await Future<void>.delayed(const Duration(seconds: 1));
                  _checkBattery();
                },
              ),
            // Also when pairing failed, so a bad code can be removed.
            if (status != 'Bağlı değil')
              ListTile(
                leading: const Icon(Icons.link_off),
                title: const Text('Bağlantıyı kaldır'),
                onTap: push.unpair,
              ),
          ],
        );
      },
    );
  }
}

class _PasteDialog extends StatefulWidget {
  const _PasteDialog({required this.initial});

  final String initial;

  @override
  State<_PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends State<_PasteDialog> {
  late final _controller = TextEditingController(
    text: widget.initial.trim().startsWith('{') ? widget.initial : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Bağlantı kodu'),
    content: TextField(
      key: const Key('pair-code'),
      controller: _controller,
      maxLines: 6,
      // A machine code: no autocorrect ("url" → "URL" breaks it).
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      decoration: const InputDecoration(hintText: '{"url": …}'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Bağlan'),
      ),
    ],
  );
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({required this.initial});

  final String initial;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Gemma komutu'),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${GemmaService.noteSlot} yerine notun metni konur.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextField(controller: _controller, maxLines: 10, minLines: 6),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => _controller.text = GemmaService.defaultPrompt,
        child: const Text('Varsayılan'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Kaydet'),
      ),
    ],
  );
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.title, this.warning});

  final String title;
  final String? warning;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.warning != null) Text(widget.warning!),
        TextField(
          controller: _controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Şifre'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Tamam'),
      ),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
