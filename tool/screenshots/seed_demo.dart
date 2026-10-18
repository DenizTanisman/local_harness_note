// Fills a fresh install with demo notes, reminders, media and a lesson, for
// the README screenshots (tool/screenshots/README.md). Not part of the app:
//
//   flutter run --release -t tool/screenshots/seed_demo.dart
//
// Media and the lesson are fetched from a folder served on the Mac, which
// an emulator reaches at 10.0.2.2:
//   (cd demo-media && python3 -m http.server 8899)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/open_connection.dart';
import 'package:local_harness_not/data/repositories/attachments_repository.dart';
import 'package:local_harness_not/data/repositories/lessons_repository.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:local_harness_not/features/notes/attachment_importer.dart';

const _server = String.fromEnvironment(
  'DEMO_SERVER',
  defaultValue: 'http://10.0.2.2:8899',
);

const _notes = <(String, bool)>[
  (
    'Haftalık alışveriş\n- Yumurta\n- Yulaf\n- Muz\n- Zeytinyağı\n#alışveriş',
    false,
  ),
  (
    'Mercimek çorbası\n- 1 su bardağı kırmızı mercimek\n- 1 soğan, 1 havuç\n'
        '- 6 su bardağı su\nTereyağında pul biberle servis et.\n#yemek',
    false,
  ),
  (
    'Riverpod ile test\nProvider\'ları testte override ederek gerçek '
        'veritabanı yerine bellekte çalış.\n'
        '[Riverpod belgeleri](https://riverpod.dev)\n#yazılım-flutter',
    false,
  ),
  (
    'Okuma listesi\n- Alışkanlıklar üzerine bir kitap\n- Odaklanma üzerine '
        'bir kitap\n- Karar verme üzerine bir kitap\n#kitap',
    false,
  ),
  (
    'Şut çalışması\n50 serbest atış, 30 üçlük. Dirsek içeride, bilek '
        'bükülü.\n#basketbol',
    false,
  ),
  (
    'Uygulama fikri: sesli hatırlatma\nHatırlatma bildiriminde konuşanın '
        'sesini yeniden dinleyebilmek.\n#fikir-uygulama',
    false,
  ),
  ('Özel not\nBu not Claude\'a hiç gösterilmez.', true),
  (
    'Sohbet: hafta sonu planı\nCumartesi sabah koşu, öğleden sonra müze.'
        '\n#sohbet',
    false,
  ),
  ('Sohbet: kitap kulübü\nBu ay bir deneme kitabı seçelim.\n#sohbet', false),
  (
    'Sohbet: yeni proje\nÖnce küçük bir prototip, sonra kullanıcı '
        'görüşmesi.\n#sohbet-iş',
    false,
  ),
];

/// (text, media file in the demo folder, MIME) — all go to the reminders.
const _reminders = <(String, String?, String?)>[
  (
    'Güne kısa bir hedefle başla\nBugün tek bir işi bitir; gerisi bonus.'
        '\n\nÖzet: Sabahları küçük ve net bir hedef seç.',
    'sabah.mp4',
    'video/mp4',
  ),
  (
    'Bir kez aksatmak hata\nİki kez aksatmak yeni bir alışkanlık.'
        '\n\nÖzet: Zinciri en fazla bir gün kır.',
    'ogle.mp4',
    'video/mp4',
  ),
  (
    'Akşam semineri: hedef koymak\nHedef seni dönüştürecek kadar büyük '
        'olsun.\n\nÖzet: Hedefin değeri, seni ne hale getirdiğindedir.',
    'aksam.m4a',
    'audio/mp4',
  ),
  ('Küçük adımlar\nHer gün yüzde bir daha iyi.', null, null),
  (
    'Çalışma masası düzeni\nIşık solda, ekran göz hizasında.\n#tasarım',
    'masa.jpg',
    'image/jpeg',
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Status('Demo verisi yükleniyor…'));
  final db = AppDatabase(openEncryptedConnection());
  final notes = NotesRepository(db);
  final files = AttachmentsRepository(db, importer: deviceAttachmentImporter);
  final demo = await Directory(
    p.join((await getTemporaryDirectory()).path, 'demo'),
  ).create(recursive: true);
  final http = HttpClient();
  Future<File?> fetch(String name) async {
    try {
      final res = await (await http.getUrl(
        Uri.parse('$_server/$name'),
      )).close();
      if (res.statusCode != 200) return null;
      final file = File(p.join(demo.path, name));
      await res.pipe(file.openWrite());
      return file;
    } on IOException {
      return null;
    }
  }

  for (final (body, private) in _notes) {
    await notes.create(body, isPrivate: private);
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  for (final (body, file, mime) in _reminders) {
    final id = await notes.create(body);
    if (file != null) {
      final local = await fetch(file);
      if (local != null) await files.add(id, local.path, mime!);
    }
    await notes.addToReminders(id);
  }
  final lesson = await fetch('ders.html');
  if (lesson != null) {
    await LessonsRepository(db).import(await lesson.readAsString());
  }
  http.close();
  await db.close();
  runApp(const _Status('Demo hazır. Şimdi uygulamanın kendisini kur.'));
}

class _Status extends StatelessWidget {
  const _Status(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(body: Center(child: Text(text))),
  );
}
