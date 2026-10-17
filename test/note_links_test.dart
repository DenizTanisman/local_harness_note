import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/core/note_links.dart';

void main() {
  const yt = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

  test('finds bare and labelled links, trims trailing punctuation', () {
    const body =
        'İzle: $yt. Sonra [Profil](https://instagram.com/deniz) ve www.x.com/a!';
    final links = NoteLinks.find(body);
    expect(links.map((l) => l.url), [
      yt,
      'https://instagram.com/deniz',
      'https://www.x.com/a',
    ]);
    expect(links[0].label, isNull);
    expect(links[1].label, 'Profil');
    expect(body.substring(links[0].start, links[0].end), yt);
  });

  test('reading view shows labels and short URLs', () {
    const body = 'a [Konuşma](https://youtu.be/abc) b https://x.com/deniz/status/1';
    expect(NoteLinks.displayText(body), 'a Konuşma b x.com/deniz/status/1');
    expect(NoteLinks.shortUrl(yt), 'youtube.com/watch?v=dQw4w9WgXcQ');
    expect(NoteLinks.shortUrl('https://www.instagram.com/'), 'instagram.com');
  });

  test('labelling a link and clearing the label', () {
    const body = 'bak $yt şimdi';
    final link = NoteLinks.at(body, 8)!;
    final labelled = NoteLinks.setLabel(body, link, 'Şarkı');
    expect(labelled, 'bak [Şarkı]($yt) şimdi');
    final again = NoteLinks.at(labelled, 6)!;
    expect(again.label, 'Şarkı');
    expect(NoteLinks.setLabel(labelled, again, ''), body);
  });

  test('cursor on a link, including its edges', () {
    const body = 'x https://a.com y';
    expect(NoteLinks.at(body, 2), isNotNull);
    expect(NoteLinks.at(body, 15), isNotNull);
    expect(NoteLinks.at(body, 0), isNull);
  });

  test('maps a reading-view tap back to the raw text', () {
    const body = 'ab [L](https://a.com) cd';
    final segs = NoteLinks.segments(body);
    expect(NoteLinks.displayText(body), 'ab L cd');
    expect(NoteLinks.rawOffset(segs, 1), 1); // inside "ab"
    expect(NoteLinks.rawOffset(segs, 4), body.indexOf(' cd')); // after link
    expect(NoteLinks.rawOffset(segs, 6), body.length - 1); // inside "cd"
  });

  test('no links → one plain segment', () {
    expect(NoteLinks.segments('düz metin').single.link, isNull);
    expect(NoteLinks.find(''), isEmpty);
  });
}
