import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/core/tag_categories.dart';

void main() {
  test('main tags map to categories, Turkish- and case-insensitive', () {
    expect(TagCategories.of('development').icon, 'yazilim');
    expect(TagCategories.of('Yazılım').icon, 'yazilim');
    expect(TagCategories.of('question-llm').icon, 'soru');
    expect(TagCategories.of('İş').icon, 'business');
    expect(TagCategories.of('finance').icon, 'para');
    expect(TagCategories.of('thinking-beta').icon, 'dusunme');
    expect(TagCategories.of('basketbol').icon, 'basketbol');
    expect(TagCategories.of('gündelik').icon, 'gundelik');
    expect(TagCategories.of('xyz'), TagCategories.other);
    // Main tags of the imported Google Doc.
    for (final (tag, icon) in [
      ('yazılar', 'yazilar'),
      ('gelişim', 'gelisim'),
      ('iletişim', 'iletisim'),
      ('ilişkiler', 'iliskiler'),
      ('projeler', 'projeler'),
      ('yazılım', 'yazilim'),
      ('kariyer', 'business'),
      ('planlar', 'planlar'),
    ]) {
      expect(TagCategories.of(tag).icon, icon, reason: tag);
    }
  });

  test('every category has its icon file and a unique tag', () {
    for (final c in [...TagCategories.all, TagCategories.other]) {
      expect(File(c.asset).existsSync(), isTrue, reason: c.asset);
    }
    final tags = TagCategories.all.map((c) => c.tag).toList();
    expect(tags.toSet().length, tags.length);
    // Suggested tags must stay top-level: '-' would make them sub-tags.
    expect(tags.where((t) => t.contains('-')), isEmpty);
    expect(
      File('assets/icons/pixel/LICENSE.md').readAsStringSync(),
      contains('CC BY 4.0'),
    );
  });
}
