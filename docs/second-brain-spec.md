# Not — Second Brain Spesifikasyonu

> **Platform:** Yalnızca Android
> **Tarih:** 2026-10-16
> **Durum:** Uygulandı (2026-10-16). Açık: Firebase + Cloudflare hesapları (Bölüm 12)
> **Önceki hali:** Günlük check-in uygulaması (`daily-tracker-*.md`). Bu doküman onun yerini alır.

---

## 1. Genel Bakış

Not ve fikirleri **hızlı yakalamak** ve **unutmamak** için tek kullanıcılı, basit bir uygulama.
Hedef en kapsamlı değil, **en kullanışlı** uygulama.

### 1.1 İlkeler

1. **Her şey telefonda.** Notlar yalnızca cihazdaki şifreli SQLite'ta yaşar. Gemma cihazda çalışır.
   Claude bağlantısındaki aracı (Bölüm 8) not saklamaz, sadece mesaj taşır.
2. **Uygulama basit, zekâ Claude'da.** Bağlantı kurma, özetleme, "bununla ilgili ne yazmıştım"
   işleri Claude'a MCP üzerinden yaptırılır; uygulamaya bu özellikler eklenmez.
3. **Hiçbir şey sessizce kaybolmaz.** Birleştirme arşivler, Gemma onayı eski metni sürüm olarak saklar,
   Claude'un silme aracı yoktur.
4. **Özel notlar cihazdan çıkmaz.** `is_private` notlar MCP'den hiçbir koşulda dönmez.

### 1.2 Kaldırılanlar

Günlük check-in tamamen kalkar (gerekirse sonra eklenir):

- Metrik ağacı, kartlar, ADD sheet, drag-to-group, geçmiş gün girişi
- Analiz sekmesi (ısı haritası, breakdown, takvim satırı), metrik detay / sparkline
- Akşam "Time to fill in your day" bildirimi, sabah alıntı havuzu ve alıntı editörü
- Instagram auto-fill (`readsPeers: program` kalkar)
- CSV/Excel export/import, ısı haritası kural editörü
- Tablolar: `metrics`, `metric_options`, `entries`, `entry_options`

Kalanlar: şifreli SQLite (sqlite3mc), FLAG_SECURE, haftalık şifreli yedek, hub köprüsü.

### 1.3 Kapsam dışı (bilinçli olarak yok)

Klasör, zengin metin, graf görünümü, `[[bağlantı]]`, ek dosya, sesli not, embedding araması, iOS.

---

## 2. Veri Modeli (schema v2)

```
notes
  id            TEXT PK     -- uuid v4 (Claude'un oluşturduğu notlar için de aynı)
  body          TEXT        -- düz metin; ilk satır başlık gibi gösterilir
  status        TEXT        -- 'inbox' | 'archived'
  is_private    INTEGER     -- 0/1
  source        TEXT        -- 'phone' | 'claude' | 'share' | 'merge'
  merged_into   TEXT NULL   -- birleştirmede arşivlenen notun hedefi
  created_at    INTEGER     -- epoch ms
  updated_at    INTEGER

note_tags        (note_id, tag)        -- body içindeki #etiketlerden her kayıtta yeniden türetilir
note_versions    (id, note_id, body, reason, created_at)   -- reason: 'gemma' | 'merge'
reminders        (note_id PK, position INTEGER)            -- sıralı hatırlatma listesi
notes_fts        FTS5(body), external content = notes      -- tetikleyicilerle senkron
app_settings     (mevcut tablo; yeni anahtarlar Bölüm 9'da)
```

- Etiket: `#` + harf/rakam/`_`/`-`, Türkçe karakterler dahil, küçük harfe normalize.
- FTS5 tokenizer: `unicode61 remove_diacritics 2` (ı/i, ş/s eşleşsin).
- v1 → v2 migrasyonu eski check-in tablolarını düşürür. **Kurulumdan önce** eski sürümün
  export'u ile veriler alınmak istenirse alınır (F0).

---

## 3. Ekranlar

Alt gezinme: **Notlar** · **Hatırlatmalar**. Sağ üstte Ayarlar.

### 3.1 Notlar
- Üstte arama çubuğu (FTS). Filtre çipleri: `Gelen` (varsayılan) · `Arşiv` · etiketler.
- Liste: en yeni üstte; ilk satır kalın, devamı 2 satır önizleme, etiketler, 🔒 özel, 🔔 hatırlatmada.
- Her satırda **✨** butonu → Gemma akışı (Bölüm 5).
- **+** butonu → yeni not editörü, **klavye açık** gelir. Geri tuşu boş değilse kaydeder.
- Uzun basma → **seçim modu** → `Birleştir` · `Arşivle` · `Hatırlatmaya ekle` (Bölüm 4).

### 3.2 Not editörü
- Düz metin alanı, otomatik kayıt (debounce).
- Menü: ✨ Gemma · 🔔 Hatırlat (aç/kapa) · 🔒 Özel (aç/kapa) · Arşivle/Geri al · Sürümler.
- Sürümler: `note_versions` listesi; birine dokununca "Bu sürüme dön" (mevcut metin de sürüm olarak saklanır).

### 3.3 Hatırlatmalar
- `reminders.position` sırasıyla liste; sürükleyerek sıralama; kaydırarak listeden çıkarma (not silinmez).
- **Sıradaki** madde vurgulu gösterilir.
- **+** → yeni not oluşturur ve listenin sonuna ekler.

### 3.4 Ayarlar
- Gemma: model durumu / indir / sil, **prompt** (çok satırlı, varsayılanına dön).
- Hatırlatma saatleri (varsayılan 07:30 · 14:00 · 20:00), aç/kapa.
- Claude bağlantısı (Bölüm 8): durum, eşleştirme.
- FLAG_SECURE, yedek.

---

## 4. Birleştirme

1. Seçim modunda ≥2 not seçilir → `Birleştir`.
2. Yeni not: gövdeler **eskiden yeniye**, aralarına `— 12 Eki —` tarih satırı.
3. Etiketler: birleşim (zaten gövdeden türetilir).
4. Herhangi biri özelse → yeni not özel.
5. Herhangi biri hatırlatmadaysa → yeni not, **en küçük position**'ı alır; eskiler listeden çıkar.
6. Eski notlar silinmez: `status = archived`, `merged_into = yeni id`.
7. Snackbar: `Birleştirildi · Geri al` (geri al: yeni notu sil, eskileri ve hatırlatma pozisyonlarını geri yükle).
8. Snackbar'da ayrıca `✨ Toparla` → yeni not üzerinde Gemma akışı.

---

## 5. Gemma (cihaz içi)

- Paket: `flutter_gemma` + `flutter_gemma_litertlm`; model **Gemma 4 E2B** (`gemma-4-E2B-it.litertlm`,
  ~2,6 GB, Apache 2.0, token gerekmez), CPU arka ucu (GPU'da Gemma 4 rakam/tarih bozabiliyor).
- Model APK'ya gömülmez; Ayarlar'dan veya ilk ✨ basışında **bir kez indirilir** (ön plan
  `dataSync` servisi, bildirimde ilerleme). Sonrasında internet gerekmez.
- Varsayılan prompt (Ayarlar'dan değiştirilebilir):

  > Aşağıdaki notu Türkçe olarak toparla. Ana fikirleri koru, tekrarları çıkar, gerekiyorsa
  > maddeler halinde düzenle. Notta olmayan bilgi ekleme.
  > Kurallar: ilk satır kısa başlık; düz metin (Markdown yok, madde için "- "); en son satıra
  > yalnızca notta geçen #etiketler; sadece düzenlenmiş notu yaz.
  >
  > NOT:
  > {{not}}

### 5.1 Akış
1. ✨ → **Gemma ekranı** açılır: üstte orijinal (katlanabilir), altta çıktı akarak (streaming) gelir.
2. Çıktı bitince alan **düzenlenebilir** olur.
3. Butonlar: `Onayla` · `Yeniden üret` · `Vazgeç`.
4. `Onayla`: eski gövde `note_versions`'a (`reason = 'gemma'`) yazılır, sonra not gövdesi yeni metinle değişir.

### 5.2 Yanlışlıkla çıkış koruması
- Üretim sürerken **veya** çıktı onaylanmamışken geri tuşu / geri hareketi / `Vazgeç` →
  `Emin misin? Gemma çıktısı kaybolacak.` (`Kal` · `Çık`). `PopScope(canPop: false)` ile.
- Ana ekran tuşu / uygulama değiştirme engellenemez (Android izin vermez): üretim arka planda sürer,
  dönüldüğünde ekran aynı durumda bekler. Süreç OS tarafından öldürülürse çıktı kaybolur (kabul edilen risk).

---

## 6. Hatırlatmalar

- Günde 3 slot: **07:30 · 14:00 · 20:00** (Ayarlar'dan değiştirilebilir). Her slot listedeki **sıradaki** maddeyi gösterir.
- Liste bitince **baştan başlar**. Liste boşsa bildirim yok. Arşivlenen not listeden otomatik çıkar.
- Bildirim: başlık = notun ilk satırı, gövde = devamı (kısaltılmış). Dokununca not editörü açılır.
  Özel notlar da hatırlatılabilir (cihaz içi).

### 6.1 Sıra hesabı (saf fonksiyon, test edilebilir)
- `app_settings`: `reminder_anchor_slot` (slot zamanı), `reminder_anchor_note` (o slotta gösterilecek note_id).
- Slot `k` (anchor'dan sonraki k. slot) için madde = `liste[(index(anchor_note) + k) % len]`.
- Liste değişince (ekle/çıkar/sırala): bir sonraki slot için gösterilecek notu koruyacak şekilde anchor
  yeniden yazılır (o not listeden çıktıysa bir sonraki pozisyondaki not), ardından bildirimler yeniden planlanır.
- 21 günlük ufuk; uygulama açılışında, liste/not değişince ve açılışta (boot) yenilenir.
- **Tam zamanlı** alarmlar (`USE_EXACT_ALARM`, kurulumda verilir): esnek alarm 07:30'u 1 saate
  kadar kaydırabiliyordu. İzin yoksa esnek moda düşer.

---

## 7. Yakalama Kısayolları

- **Paylaş menüsü:** `ACTION_SEND text/plain` → yeni not editörü, metin önceden dolu, `source = 'share'`.
- **Ana ekran widget'ı:** tek dokunuşla yeni not editörü (klavye açık).

---

## 8. Claude Bağlantısı (MCP, telefonu uyandırarak)

```
Claude ──MCP──▶ Cloudflare Worker (uzak MCP sunucusu, not saklamaz)
                   │ FCM yüksek öncelikli data mesajı: yalnızca "uyan"
                   ▼
                Telefon: GET /phone/work → bekleyen tüm çağrılar + kuyruk,
                         kendi DB'sinde çalıştırır (arka plan isolate'i ya da uygulama)
                   │ HTTPS POST /phone/result {reqId, ok, result|error}
                   ▼
Claude ◀───────── Worker (Durable Object'te bekleyen isteği cevaplar)
```

- **Zaman aşımı:** 25 sn → Claude'a `Telefona ulaşılamadı` hatası.
- **Claude'un yazdığı notlar:** yazma araçları telefona ulaşamazsa Worker'da kuyruğa girer; telefon her
  uyanışta, uygulama açılışında ve öne gelişinde kuyruğu çeker; cevabı gönderince Worker kopyayı siler.
  Aynı istek iki kez gelirse (`reqId`) bir kez uygulanır.
- **Asgari kimlik doğrulama:** Telefon ↔ Worker arası paylaşılan gizli anahtar (eşleştirmede girilir);
  claude.ai custom connector'ı için gizli URL yolu. (Ayrıntılı güvenlik bu fazın kapsamı dışında.)
- Pil optimizasyonundan muafiyet eşleştirme ekranında istenir.

### 8.1 Araçlar

| Araç | Girdi | Not |
|---|---|---|
| `search_notes` | `query, tag?, since?, include_archived?, limit≤30` | FTS; kısa alıntı döner |
| `get_note` | `id` | tam metin + etiketler + tarihler |
| `list_recent` | `days, tag?, limit≤30, cursor?` | sayfalı |
| `create_note` | `text` | `source = 'claude'` |
| `append_to_note` | `id, text` | sona ekler |
| `archive_note` | `id` | |
| `add_to_reminders` | `id` | listenin sonuna |

- **Silme aracı yoktur.**
- Özel notlar tüm araçlarda filtrelenir: `get_note`/`append_to_note`/`archive_note`/`add_to_reminders`
  özel bir id için "bulunamadı" döner.

---

## 9. Ayarlar Anahtarları (`app_settings`)

`gemma_prompt`, `gemma_model`, `reminders_enabled`, `reminder_times` (JSON `["07:30","14:00","20:00"]`),
`reminder_anchor_slot`, `reminder_anchor_note`, `relay_url`, `relay_secret` (secure storage'da),
`flag_secure`. Eski `morning_time`, `evening_time`, `quotes_*`, `autofill_instagram` silinir.

---

## 10. Hub Sözleşmesi Değişikliği

`not.data` → **snapshot schema 2** (hub uygulaması da güncellenmeli):

```json
{
  "notes": { "total": 0, "inbox": 0 },
  "nextReminder": { "title": "notun ilk satırı", "at": "2026-10-16T14:00:00" }
}
```

Özel notların başlığı `nextReminder`'da `"🔒"` olarak gider. `harness.json` / `HARNESS.md` güncellenir;
`readsPeers` boşalır.

---

## 11. Fazlar ve Kabul Kriterleri

| Faz | İçerik | Kabul |
|---|---|---|
| **F0 Temizlik** | Check-in kodu, testleri, tablolar, alıntı/akşam bildirimi, Instagram auto-fill kalkar; schema v2; hub snapshot v2 | `flutter analyze` temiz, testler yeşil, uygulama boş Notlar ekranıyla açılır |
| **F1 Notlar** | Model, FTS, liste/arama/filtre, editör, etiket, arşiv, özel | Türkçe aramada `isik` → `ışık` bulunur; 10k notta arama < 100 ms (test) |
| **F2 Birleştirme + sürümler** | Bölüm 4, sürüm ekranı | Birleştir → geri al tüm durumu (hatırlatma pozisyonları dahil) birebir geri getirir |
| **F3 Hatırlatmalar** | Bölüm 6 | Saf planlayıcı testleri: döngü, ekleme/çıkarma/sıralama sonrası sıradaki madde korunur |
| **F4 Gemma** | Bölüm 5 | Çıkış koruması widget testi; onay sonrası eski metin sürümlerde |
| **F5 Claude bağlantısı** | Bölüm 8 (Worker + FCM + arka plan işleyici) | Telefon kilitliyken claude.ai'dan `search_notes` < 10 sn döner; özel not hiçbir araçtan dönmez |
| **F6 Kısayollar** | Bölüm 7 | Başka uygulamadan paylaşılan metin yeni not olarak açılır |

---

## 12. Açık Noktalar

1. ~~Gemma modeli~~ → Gemma 4 E2B (Galaxy S24 Ultra, 12 GB RAM).
2. **Hesaplar:** Firebase projesi (yalnızca FCM) ve Cloudflare hesabı — kullanıcı açar, sonra
   `worker/setup.sh <google-services.json> <service-account.json>`.
