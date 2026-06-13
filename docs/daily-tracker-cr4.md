# Daily Tracker — Change Request 4 (CR-4)
## Ekran Süresi (Digital Wellbeing) Entegrasyonu

> **Tarih:** 2026-06-12
> **Tip:** Feature — yeni bir fetch kaynağı + yerleşim.
> **Bağımlılıklar:** spec, cr1, cr2, cr3 (özellikle CR-3'teki Health/Main yapısı ve
> `HealthRepository` deseni). Bunlar okunmadan uygulanmaz.
> **Dağıtım bağlamı:** Uygulama YALNIZCA kişisel kullanım için, hiçbir mağazaya
> konmayacak (sideload). → Google Play izin politikaları, beyan formları ve inceleme
> süreçleri GEÇERSİZ. İzinler serbestçe kullanılır; tek gereksinim bir defalık manuel onay.

---

## 0. Ne Ekleniyor

| Alan | Durum |
|---|---|
| `ScreenTimeRepository` | YENİ — `HealthRepository`'nin ikizi soyutlama |
| Health sayfası | "Digital Wellbeing" bölümü EKLENİR (toplam + top-5) |
| Main "Bugün" kartı | Tek satır ekran süresi özeti EKLENİR (→ Health'e deep link) |
| Daily Check-in / Instagram | Otomatik-doldurma opsiyonu (ölçülen veriden) EKLENİR |
| DB | `screen_time_day`, `screen_time_app` tabloları EKLENİR |
| İzinler | `PACKAGE_USAGE_STATS` + `QUERY_ALL_PACKAGES` |

---

## 1. Temel: Bu Veri Nereden Geliyor

Android'in "Dijital Sağlık" rakamlarının kaynağı sistem servisi `UsageStatsManager`'dır.
Her uygulamanın ön planda kaldığı süreyi (`totalTimeInForeground`) verir. "En çok kullanılan
5 uygulama" = günün tüm uygulamalarını bu süreye göre sıralayıp ilk 5'i almak.

**Granülerlik:** İstatistikler güvenilir biçimde **günlük** çözünürlüktedir (Google'ın
implementasyon sınırı). "Bugün Instagram 47 dk" alınır; saatlik/dakikalık dağılım hedef değil.
Bizim ihtiyacımız (günlük top-5 + toplam) için yeterli.

**Önemli uyarı (dürüstlük):** `totalTimeInForeground`, Digital Wellbeing'in gösterdiği
"ekran süresi" ile birebir AYNI olmayabilir — DW kendi içinde biraz daha rafine bir hesap
kullanır. Fark küçüktür; trend ve top-5 sıralaması için fazlasıyla isabetli. UI'da değeri
"ekran süresi (yaklaşık)" olarak sunmak dürüst olur.

**Platform:** Yalnızca Android. (Zaten uygulama Android-only.)

---

## 2. İzinler ve Onboarding

İki izin:
```xml
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
    tools:ignore="ProtectedPermissions" />
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

- **`PACKAGE_USAGE_STATS`** — kullanım verisini okumak için. Bu izin runtime pop-up ile
  istenemez (özel/sistem seviyesi). Kullanıcı yalnızca sistem ayar sayfasından elle açar.
- **`QUERY_ALL_PACKAGES`** — Android 11+ (API 30) paket görünürlüğü filtrelemesi nedeniyle,
  top-5'in paket adlarını insan-okunur etikete/ikona çevirmek için gerekir. (Kişisel uygulama
  → Play kısıtı yok.) Alternatif: yalnızca bilinen birkaç paketi `<queries>` ile beyan etmek;
  ama top-5 dinamik olduğu için `QUERY_ALL_PACKAGES` daha pratik.

**Onboarding akışı (Health sayfası ilk açılış / "Bağla" CTA):**
1. `AppOpsManager` ile izin durumu kontrol edilir (`OPSTR_GET_USAGE_STATS`).
2. Yoksa açıklayıcı bir kart: "Ekran süresini görmek için Kullanım Erişimi gerekir."
3. Buton → `Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)` ile sistem ayarına yönlendir.
4. Uygulama öne geldiğinde (`resumed`) izin tekrar kontrol edilir; verildiyse ilk fetch
   tetiklenir, kart dolar.
- Bir defalık. Verilince bir daha sorulmaz.

---

## 3. Yerleşim (uygulamada nerede, nasıl)

Üç nokta — mevcut adım/nabız/uyku deseniyle tutarlı (Main'de özet, Health'te detay).

### 3.1 Health → "Digital Wellbeing" bölümü (birincil, tam döküm)

CR-3 §5'teki Health sayfasının "Çekilen (sensör)" bloğunun ALTINA eklenir.

```
┌─ HEALTH ────────────────────┐
│  ... (Profil / Vücut / Sensör) │
│ ┌─ Digital Wellbeing ──────┐ │
│ │ Ekran süresi  3s 12d (~) │ │ ← günlük toplam (yaklaşık)
│ │ ───────────────────────  │ │
│ │ Instagram   ▓▓▓▓▓░ 1s05d │ │ ← top-5, çubuk = orana göre
│ │ WhatsApp    ▓▓▓░░░ 38d   │ │
│ │ Chrome      ▓▓░░░░ 22d   │ │
│ │ YouTube     ▓▓░░░░ 19d   │ │
│ │ X           ▓░░░░░ 11d   │ │
│ │ [↻ son sync 00:08]       │ │
│ └──────────────────────────┘ │
└─────────────────────────────┘
```

- Top-5 uygulama, süreye göre azalan; çubuk genişliği = (uygulama süresi / top değer).
- İkon opsiyonel (PackageManager'dan); yoksa baş harf rozeti.
- İzin yoksa bu kart yerine onboarding kartı (§2) görünür.
- Tarih çipi (CR1-D) Health'te de geçerliyse seçili güne göre gösterilir; değilse "bugün".

### 3.2 Main "Bugün" kartı → tek satır özet (glanceable)

CR-3 §3'teki Main "Bugün" kartına bir satır eklenir:

```
│ │ Ekran  📱 3s12d (~)      │→Health│
```

- Dokununca Health'e atlar (Digital Wellbeing bölümüne — PageController.jumpToPage + scroll).

### 3.3 Instagram metriği → otomatik doldurma (opsiyonel)

Daily Check-in'deki `instagram` metriği (int_text: dakika + neden) zaten elle giriliyor.
Ekran süresi geldiğinde Instagram'ın ölçülen dakikası, o günün `entries.num_value`'sine
**otomatik yazılır** — kullanıcı yalnızca "neden"i (text_value) yazar.

- Settings'te anahtar: "Auto-fill Instagram from screen time" (varsayılan: AÇIK).
- Çakışma kuralı: kullanıcı o gün Instagram dakikasını ELLE değiştirdiyse, otomatik fetch
  ARTIK o günü ezmez (manuel kazanır). Bunu izlemek için entry'ye kaynak işareti:
  `entries`'e ek kolon `value_source TEXT DEFAULT 'manual'` ('manual' | 'auto').
  - Auto fetch yazarken: o gün entry yok ya da `value_source='auto'` ise yaz, `='auto'` damgala.
  - Kullanıcı elle değiştirince: `value_source='manual'`, fetch bir daha dokunmaz.
- Instagram'ın paket adı sabit map'te: `com.instagram.android`.

---

## 4. Kod: ScreenTimeRepository

`HealthRepository` ile aynı desen — UI kaynağı bilmez.

```dart
class AppUsage {            // tek bir uygulamanın günlük süresi
  final String packageName;
  final String label;       // PackageManager'dan çözülür
  final int foregroundMinutes;
}
class ScreenTimeDay {
  final DateTime date;
  final int totalMinutes;
  final List<AppUsage> topApps;   // ilk 5
}
abstract class ScreenTimeRepository {
  Future<bool> hasPermission();
  Future<void> openPermissionSettings();      // ACTION_USAGE_ACCESS_SETTINGS
  Future<ScreenTimeDay?> usageFor(DateTime day);
  Future<void> sync({DateTime? since});
}
```

**Paket önerisi:** `usage_stats` (birincil) — izin kontrol/yönlendirme yardımcıları +
`queryUsageStats(start, end)` içeriyor. Basit alternatif: `app_usage`.

**Top-5 üretimi:**
```
gün d için:
  list = queryUsageStats(d 00:00, d 23:59)
  filtre: foregroundMs > 0, kendi paketimizi ve launcher/sistem UI'ı ele
  total = Σ foregroundMs
  sort desc by foregroundMs → ilk 5
  her paket için label = PackageManager.getApplicationLabel (yoksa packageName)
```

---

## 5. DB Tabloları (mevcut şemaya EK)

```sql
CREATE TABLE screen_time_day (
  date TEXT PRIMARY KEY,             -- 'YYYY-MM-DD'
  total_min INTEGER NOT NULL DEFAULT 0,
  captured_at INTEGER NOT NULL
);
CREATE TABLE screen_time_app (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL REFERENCES screen_time_day(date) ON DELETE CASCADE,
  package_name TEXT NOT NULL,
  app_label TEXT,                    -- çözülemezse NULL → UI packageName gösterir
  foreground_min INTEGER NOT NULL,
  rank INTEGER NOT NULL,             -- 1..5
  UNIQUE(date, package_name)
);
-- entries tablosuna ek (Instagram auto-fill için):
ALTER TABLE entries ADD COLUMN value_source TEXT NOT NULL DEFAULT 'manual';  -- 'manual'|'auto'
```

- Yalnızca top-5 satır saklanır (veri minimizasyonu); toplam `screen_time_day.total_min`
  tüm uygulamalar üzerinden hesaplanır ama tek tek saklanmaz.

---

## 6. Senkron / Pull Stratejisi

- CR-3 §15'teki `workmanager` pull döngüsüne eklenir: açılışta + günde birkaç kez.
- Her sync seçili/bugünün gününü çeker → `screen_time_day` + `screen_time_app` upsert →
  Instagram auto-fill kuralını (§3.3) uygular → `sync_state`'e 'screen_time' damgası.
- İzin yoksa sync sessizce atlanır (kullanıcıya tekrar tekrar pop-up yok; sadece Health'te
  onboarding kartı durur).

---

## 7. Güvenlik (davranışsal veri — hassas)

Hangi uygulamayı ne kadar kullandığın bir davranış profilidir; sağlık/finans verisi kadar korunur.

1. `screen_time_*` tabloları SQLCipher'lı DB'de (spec §11) — at-rest şifreli.
2. **Log/analytics YASAK:** paket adı (`com.instagram.android`), süreler, sıralama —
   `log()`, `print()`, crash-reporter, hiçbir event'e DÜŞMEZ. Yalnızca olay türü
   ("screen_time_synced"), değer yok.
3. Buluta gönderme yok (zaten local-first; bu veri özellikle hassas).
4. `QUERY_ALL_PACKAGES` ile elde edilen yüklü uygulama bilgisi yalnızca top-5 etiketini
   çözmek için kullanılır; tüm uygulama envanteri DB'ye yazılmaz.
5. Parametreli sorgular (paket adı serbest metin gibi davranılır, interpolation yok).

---

## 8. Build Fazı + Branch

| Faz | Branch | İçerik |
|---|---|---|
| CR4-P0 | `cr4-p0-screentime-bridge` | İzin kontrol/onboarding, `ScreenTimeRepository` + `usage_stats`, fetch + top-5, DB tabloları, workmanager pull |
| CR4-P1 | `cr4-p1-screentime-ui` | Health "Digital Wellbeing" bölümü, Main "Bugün" özet satırı + deep link |
| CR4-P2 | `cr4-p2-instagram-autofill` | `value_source` kolonu + Instagram auto-fill kuralı + Settings anahtarı |

Bağımlılık: CR-3 P3/P4 (Health + bridge deseni) önce. Tema CR1-B token'ları kullanılır.

---

## 9. Kabul Kriterleri

- [ ] İzin yokken Health'te onboarding kartı; "Bağla" → sistem ayar sayfası açılıyor.
- [ ] İzin verilip uygulama öne gelince fetch tetikleniyor, kart doluyor.
- [ ] Top-5 süreye göre azalan; çubuk genişlikleri orantılı; etiket çözülemezse packageName.
- [ ] Toplam ekran süresi Main "Bugün" satırında; dokununca Health Digital Wellbeing'e atlıyor.
- [ ] Instagram auto-fill AÇIKken o günün num_value'si ölçülenle doluyor; kullanıcı elle
      değiştirince `value_source='manual'` ve sonraki fetch ezmiyor (birim test).
- [ ] Log/analytics taramasında paket adı veya süre değeri YOK (güvenlik testi).
- [ ] İzin sonradan iptal edilirse sync sessiz atlanıyor, crash yok.

---

## 10. Açık Noktalar

| # | Konu | Varsayılan | Onay |
|---|---|---|---|
| 1 | Top-5 kartı yerleşimi | Health (tam) + Main (özet satır) | **Onayını istiyorum** |
| 2 | Instagram auto-fill | Açık, manuel override kazanır | Onaylandı varsay |
| 3 | İkon gösterimi | Opsiyonel; yoksa baş harf rozeti | Düşük öncelik |
| 4 | Sistem/launcher uygulamalarını ele | Evet (kendi paketimiz + launcher + sistem UI filtreli) | Düşük öncelik |

---

## 11. Claude Code Promptu

```
/docs/daily-tracker-spec.md, cr1.md, cr2.md, cr3.md, cr4.md dosyalarını oku.
Uygulama kişisel/sideload — Play izin politikası UYGULANMAZ.
CR4-P0'dan başla, her faz kendi branch'inde (Bölüm 8). ScreenTimeRepository'yi
HealthRepository desenine paralel kur (usage_stats paketi). İzin runtime pop-up
ile istenemez → ACTION_USAGE_ACCESS_SETTINGS yönlendirmesi + AppOps kontrolü.
Paket adı/süre değerlerini ASLA log/analytics'e yazma (Bölüm 7). value_source
kolonuyla manuel-override-kazanır kuralını uygula. flutter analyze sıfır uyarı.
```

---
*CR-4, 2026-06-12. Kişisel kullanım; mağaza kısıtı yok. Açık Nokta #1 (yerleşim) onayı beklenir.*
