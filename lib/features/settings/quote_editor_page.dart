import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart' show notificationServiceProvider;
import '../notifications/quote_service.dart';
import 'settings_providers.dart';

/// Full editor for the morning-notification phrases. The user can delete or
/// edit the auto-provided defaults and add their own — all in one place. The
/// edited pool is stored per language in app_settings and used as-is for the
/// daily morning quote.
class QuoteEditorPage extends ConsumerStatefulWidget {
  const QuoteEditorPage({super.key});

  @override
  ConsumerState<QuoteEditorPage> createState() => _QuoteEditorPageState();
}

class _QuoteEditorPageState extends ConsumerState<QuoteEditorPage> {
  List<String> _quotes = [];
  String _lang = 'tr';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final settings = await ref.read(settingsRepositoryProvider).loadAll();
    final lang = settings['quote_lang'] ?? 'tr';
    final list = await QuoteService.effective(lang, settings);
    if (!mounted) return;
    setState(() {
      _lang = lang;
      _quotes = [...list];
      _loaded = true;
    });
  }

  Future<void> _persist() async {
    await ref
        .read(settingsRepositoryProvider)
        .set(QuoteService.customKey(_lang), jsonEncode(_quotes));
    // Morning notifications pull from this pool — refresh the schedule.
    await ref.read(notificationServiceProvider).rescheduleAll();
  }

  Future<String?> _promptText({String initial = '', required String title}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'İfadeyi yazın',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final text = await _promptText(title: 'Yeni ifade');
    if (text == null || text.isEmpty) return;
    setState(() => _quotes.add(text));
    await _persist();
  }

  Future<void> _edit(int index) async {
    final text = await _promptText(
      title: 'İfadeyi düzenle',
      initial: _quotes[index],
    );
    if (text == null || text.isEmpty) return;
    setState(() => _quotes[index] = text);
    await _persist();
  }

  Future<void> _delete(int index) async {
    final removed = _quotes[index];
    setState(() => _quotes.removeAt(index));
    await _persist();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('İfade silindi'),
        action: SnackBarAction(
          label: 'Geri al',
          onPressed: () async {
            setState(() => _quotes.insert(index.clamp(0, _quotes.length), removed));
            await _persist();
          },
        ),
      ),
    );
  }

  Future<void> _resetDefaults() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılanlara dön'),
        content: const Text(
          'Tüm değişikliklerin silinip otomatik ifadeler geri yüklenecek. '
          'Devam edilsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Geri yükle'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final defaults = await QuoteService.load(_lang);
    if (!mounted) return;
    setState(() => _quotes = [...defaults]);
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sabah ifadeleri'),
        actions: [
          IconButton(
            tooltip: 'Varsayılanlara dön',
            icon: const Icon(Icons.restore),
            onPressed: _loaded ? _resetDefaults : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loaded ? _add : null,
        icon: const Icon(Icons.add),
        label: const Text('Ekle'),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Sabah bildiriminde her gün bu listeden bir ifade '
                    'gösterilir ($_lang). Otomatik gelenleri silip '
                    'düzenleyebilir, kendi cümlelerini ekleyebilirsin.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: _quotes.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Liste boş. Sabah bildirimi gösterilmez.\n'
                              '“Ekle” ile ifade ekleyebilirsin.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 88),
                          itemCount: _quotes.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, i) => Dismissible(
                            key: ValueKey('quote-$i-${_quotes[i].hashCode}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Theme.of(context).colorScheme.errorContainer,
                              child: const Icon(Icons.delete_outline),
                            ),
                            onDismissed: (_) => _delete(i),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              title: Text(_quotes[i]),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _edit(i),
                              ),
                              onTap: () => _edit(i),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
