import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/features/gemma/gemma_prompts.dart';
import 'package:local_harness_not/features/gemma/gemma_service.dart';

void main() {
  test('two ready-made prompts by default: Toparla and Hizala', () {
    final list = GemmaPrompts.load(const {});
    expect(list.map((p) => p.name), ['Toparla', 'Hizala']);
    expect(list[1].prompt, contains('DEĞİŞTİRME'));
    expect(list[1].prompt, contains(GemmaService.noteSlot));
  });

  test('an older custom single prompt becomes Toparla', () {
    final list = GemmaPrompts.load({GemmaService.promptKey: 'Kısalt: {{not}}'});
    expect(list.first.name, 'Toparla');
    expect(list.first.prompt, 'Kısalt: {{not}}');
    expect(list.last.name, 'Hizala');
  });

  test('saved list wins; corrupt falls back to defaults', () {
    final saved = jsonEncode([
      {'name': 'Özetle', 'prompt': '3 maddede özetle'},
    ]);
    expect(GemmaPrompts.load({GemmaPrompts.key: saved}).single.name, 'Özetle');
    expect(GemmaPrompts.load({GemmaPrompts.key: 'bozuk'}), hasLength(2));
  });
}
