import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import 'note_text.dart';

/// A kind of main #tag: its pixel icon (Streamline "Pixel", CC BY 4.0 —
/// assets/icons/pixel/LICENSE.md), colour, the tag we suggest for it, and
/// the words (Turkish and English, folded) that map an existing tag to it.
class TagCategory {
  const TagCategory(this.icon, this.tag, this.color, this.words);

  /// File name in assets/icons/pixel/.
  final String icon;

  /// Suggested hashtag (no `#`).
  final String tag;
  final Color color;
  final List<String> words;

  String get asset => 'assets/icons/pixel/$icon.svg';
}

class TagCategories {
  TagCategories._();

  static const _base = [
    TagCategory('yemek', 'yemek', AppTokens.catOrange, [
      'yemek', 'food', 'mutfak', 'tarif', 'recipe', 'beslenme', //
      'restoran', 'restaurant', 'cooking', 'yemekler',
    ]),
    TagCategory('yazilim', 'yazılım', AppTokens.catGreen, [
      'yazilim', 'software', 'kod', 'code', 'coding', 'development', //
      'dev', 'developer', 'programlama', 'programming', 'flutter', //
      'python', 'android', 'web', 'llm', 'ai', 'yapay', 'mcp',
    ]),
    TagCategory('dusunme', 'düşünme', AppTokens.catPurple, [
      'dusunme', 'dusunce', 'dusunceler', 'thinking', 'think', //
      'perspective', 'felsefe', 'philosophy', 'mindset', 'reflection',
    ]),
    TagCategory('fikir', 'fikir', AppTokens.catYellow, [
      'fikir', 'fikirler', 'idea', 'ideas', 'ilham', 'inspiration', //
      'innovation', 'yenilik', 'uygulama',
    ]),
    TagCategory('tasarim', 'tasarım', AppTokens.catPink, [
      'tasarim',
      'design',
      'ui',
      'ux',
      'figma',
      'sanat',
      'art',
    ]),
    TagCategory('business', 'business', AppTokens.catBlue, [
      'business', 'is', 'girisim', 'startup', 'kariyer', 'career', //
      'linkedin', 'pazarlama', 'marketing', 'sirket', 'company', 'satis',
    ]),
    TagCategory('beyin', 'beyin', AppTokens.catPink, [
      'beyin', 'brain', 'psikoloji', 'psychology', 'zihin', 'mind', //
      'hafiza', 'memory', 'noroloji',
    ]),
    TagCategory('basketbol', 'basketbol', AppTokens.catOrange, [
      'basketbol',
      'basketball',
      'nba',
    ]),
    TagCategory('alisveris', 'alışveriş', AppTokens.catTeal, [
      'alisveris',
      'shopping',
      'market',
      'alinacaklar',
      'satin',
    ]),
    TagCategory('gundelik', 'gündelik', AppTokens.catBlue, [
      'gundelik', 'gunluk', 'daily', 'hayat', 'life', 'ev', 'home', //
      'rutin', 'routine',
    ]),
    TagCategory('kitap', 'kitap', AppTokens.catYellow, [
      'kitap',
      'kitaplar',
      'book',
      'books',
      'okuma',
      'reading',
    ]),
    TagCategory('muzik', 'müzik', AppTokens.catPurple, [
      'muzik',
      'music',
      'sarki',
      'song',
      'playlist',
    ]),
    TagCategory('seyahat', 'seyahat', AppTokens.catTeal, [
      'seyahat',
      'travel',
      'gezi',
      'tatil',
      'trip',
      'vacation',
    ]),
    TagCategory('saglik', 'sağlık', AppTokens.catRed, [
      'saglik',
      'health',
      'wellness',
      'uyku',
      'sleep',
    ]),
    TagCategory('para', 'para', AppTokens.catGreen, [
      'para', 'money', 'finans', 'finance', 'yatirim', 'investment', //
      'butce', 'budget', 'ekonomi', 'economy', 'borsa',
    ]),
    TagCategory('egitim', 'eğitim', AppTokens.catBlue, [
      'egitim', 'education', 'okul', 'school', 'ders', 'course', //
      'ogrenme', 'learning', 'universite',
    ]),
    TagCategory('film', 'film', AppTokens.catRed, [
      'film', 'movie', 'movies', 'dizi', 'series', 'sinema', 'video', //
      'youtube',
    ]),
    TagCategory('oyun', 'oyun', AppTokens.catPurple, [
      'oyun',
      'game',
      'games',
      'gaming',
    ]),
    TagCategory('kahve', 'kahve', AppTokens.catOrange, [
      'kahve',
      'coffee',
      'cay',
      'tea',
    ]),
    TagCategory('doga', 'doğa', AppTokens.catGreen, [
      'doga',
      'nature',
      'bitki',
      'plant',
      'cevre',
    ]),
    TagCategory('spor', 'spor', AppTokens.catYellow, [
      'spor', 'sport', 'sports', 'fitness', 'gym', 'antrenman', 'kosu', //
      'running', 'futbol', 'football',
    ]),
    TagCategory('soru', 'soru', AppTokens.catTeal, [
      'soru',
      'sorular',
      'question',
      'questions',
      'merak',
    ]),
    TagCategory('hedef', 'hedef', AppTokens.catRed, [
      'hedef',
      'hedefler',
      'goal',
      'goals',
      'okr',
    ]),
    TagCategory('aile', 'aile', AppTokens.catPink, [
      'aile',
      'family',
      'arkadas',
      'friends',
      'sosyal',
      'social',
    ]),
    TagCategory('fotograf', 'fotoğraf', AppTokens.catBlue, [
      'fotograf',
      'photo',
      'photography',
      'kamera',
      'camera',
    ]),
  ];

  static const _more = [
    TagCategory('yazilar', 'yazılar', AppTokens.catYellow, [
      'yazilar',
      'yazi',
      'yazilarim',
      'writing',
      'hikayeler',
      'denemeler',
    ]),
    TagCategory('gelisim', 'gelişim', AppTokens.catGreen, [
      'gelisim',
      'growth',
      'kisiselgelisim',
      'selfimprovement',
    ]),
    TagCategory('iletisim', 'iletişim', AppTokens.catTeal, [
      'iletisim',
      'communication',
      'sohbet',
      'konusma',
    ]),
    TagCategory('iliskiler', 'ilişkiler', AppTokens.catPink, [
      'iliskiler', 'iliski', 'relationship', 'relationships', 'flort', //
      'sevgili',
    ]),
    TagCategory('projeler', 'projeler', AppTokens.catOrange, [
      'projeler',
      'proje',
      'project',
      'projects',
    ]),
    TagCategory('planlar', 'planlar', AppTokens.catBlue, [
      'planlar',
      'plan',
      'planning',
      'takvim',
      'ajanda',
    ]),
  ];

  static const all = [..._base, ..._more];

  /// For tags that match no category.
  static const other = TagCategory('etiket', '', AppTokens.catGrey, []);

  static final Map<String, TagCategory> _byWord = {
    for (final c in all)
      for (final w in c.words) w: c,
  };

  /// The category of a main tag ("question" → soru), [other] if none.
  static TagCategory of(String tag) =>
      _byWord[NoteText.fold(tag.split('-').first)] ?? other;
}
