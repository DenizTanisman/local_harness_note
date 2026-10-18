# Ders formatı (active recall)

Bir ders tek bir HTML eğiticidir. Not uygulaması onu **Dersler** sekmesinde açar,
her bölümün başlığının altına bir **▶ Recall** düğmesi ekler ve soruları kendi
ekranında sorar. Dosyanın kendisinde düğme yoktur; tarayıcıda açılınca eğitici
olduğu gibi okunur.

## Soru paketi

Soru paketi, HTML'in içine görünmeyen bir blok olarak gömülür (konumu fark etmez,
genelde `</body>` öncesine konur):

```html
<script type="application/json" id="not-recall">
{
  "title": "İstatistik Fabrikası",
  "sections": [{"id": "c2", "title": "Veriyi özetlemek"}],
  "questions": [
    {
      "id": "c2-01", "section": "c2", "stage": 1, "anchor": "k-median",
      "q": "Medyan hangisidir?",
      "options": ["…", "…", "…", "…"],
      "answer": 2,
      "why": "Sıralanmış verinin ortasındaki değer."
    }
  ]
}
</script>
```

| alan | anlamı |
|---|---|
| `title` | Dersin adı. Aynı adla yeniden eklenen ders güncellenir; ilerleme korunur. |
| `sections[].id` | Bölümün HTML'deki `id`'si. Recall düğmesi bu elemanın içine, ilk başlığın altına konur. |
| `questions[].stage` | `1` okuduktan hemen sonra, `2` bir gün sonra, `3` üç gün sonra. Bölümün ilk recall'u yapıldığı günden sayılır. Beşinci gün bölümün bütün soruları bir kez daha sorulur (genel tekrar). |
| `questions[].anchor` | Sorunun konusunu anlatan elemanın `id`'si (kavram kartı). Yanlış cevaplarda bu kart işaretlenir; "Yanlışlar ◀ ▶" çubuğu buraya atlar. |
| `answer` | Doğru şıkkın `options` içindeki sırası (0'dan başlar). |
| `why` | Sonuç ekranında gösterilen kısa açıklama. |

JSON içinde `</` geçiyorsa `<\/` yazılır.

## Kurallar

- Bir bölümün recall'u başlatılınca o günün soruları sabitlenir. Doğru ya da
  yanlış o an gösterilmez. Hepsi cevaplanınca (ya da gün bitince) değerlendirilir.
- Yanlış cevaplanan soru sonraki günlerde yeniden sorulur. Doğru cevaplanınca
  kartın işareti söner.
- Bir bölümün ilk recall'u yapılınca 1, 3 ve 5 gün sonrasına, ilk recall'un
  saatinde bildirim kurulur. Bildirime dokununca o bölümün testi açılır.
- Eklenen her dersin bir kopyası `Documents/Not/Dersler/` klasörüne yazılır.
  Dosya yöneticisinde bir `.html` dosyasına dokunup "Not" seçilirse ders eklenir.
- Dersler sekmesindeki + önce nereden ekleneceğini sorar (İndirilenler,
  WhatsApp, Not › Dersler, başka bir yer); sistem seçicisi o klasörde, yalnızca
  HTML dosyalarıyla açılır.
