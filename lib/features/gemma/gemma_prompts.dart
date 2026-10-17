import 'dart:convert';

import '../../data/repositories/settings_repository.dart';
import 'gemma_service.dart';

/// A saved Gemma instruction the ✨ button offers. `{{not}}` is replaced by
/// the note (appended when missing).
class GemmaPrompt {
  const GemmaPrompt(this.name, this.prompt);

  final String name;
  final String prompt;

  Map<String, String> toJson() => {'name': name, 'prompt': prompt};

  static GemmaPrompt fromJson(Map<String, dynamic> j) =>
      GemmaPrompt('${j['name']}', '${j['prompt']}');
}

class GemmaPrompts {
  GemmaPrompts._();

  static const key = 'gemma_prompts';

  static const tidy = GemmaPrompt('Toparla', GemmaService.defaultPrompt);

  /// Layout only: same words, same order — just "Konu / - madde" or
  /// paragraphs.
  static const align = GemmaPrompt(
    'Hizala',
    'Aşağıdaki notun metnini DEĞİŞTİRME: kelimeleri, cümleleri ve sıralarını '
        'aynen koru; hiçbir şey ekleme, çıkarma, özetleme ya da düzeltme. '
        'Yalnızca düzenini hizala:\n'
        '- Bir konu ve ona ait maddeler varsa şöyle yaz:\n'
        'Konu\n'
        '- madde\n'
        '- madde\n'
        '- Düz anlatım varsa paragraflara ayır, paragraflar arasında bir '
        'boş satır bırak.\n'
        '- Markdown kullanma (**, ## yok); madde için "- " kullan.\n'
        '- Linkleri, [kısa ad](link) yazımlarını ve #etiketleri aynen koru.\n'
        'Sadece hizalanmış notu yaz, açıklama ekleme.\n\n'
        'NOT:\n${GemmaService.noteSlot}',
  );

  static const defaults = [tidy, align];

  /// Saved prompts, or the two defaults. An older single custom prompt
  /// (`gemma_prompt`) becomes "Toparla".
  static List<GemmaPrompt> load(Map<String, String> settings) {
    final raw = settings[key];
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => GemmaPrompt.fromJson(e as Map<String, dynamic>))
            .where(
              (p) => p.name.trim().isNotEmpty && p.prompt.trim().isNotEmpty,
            )
            .toList();
        if (list.isNotEmpty) return list;
      } catch (_) {
        // Corrupt → defaults.
      }
    }
    final legacy = settings[GemmaService.promptKey];
    return [
      if (legacy != null && legacy.trim().isNotEmpty)
        GemmaPrompt(tidy.name, legacy)
      else
        tidy,
      align,
    ];
  }

  static Future<void> save(SettingsRepository repo, List<GemmaPrompt> list) =>
      repo.set(key, jsonEncode([for (final p in list) p.toJson()]));
}
