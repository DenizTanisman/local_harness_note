# Daily Tracker — Kapsamlı Proje Spesifikasyonu (AI-DLC)

> **Çalışma adı:** `daily-tracker` (yeniden adlandırılabilir)
> **Platform:** Yalnızca Android
> **Tarih:** 2026-06-11
> **Durum:** Mimari kilitli — build fazlarına hazır
> **Bu doküman:** Claude Code'a doğrudan verilebilir. Faz sırası ve kabul kriterleri Bölüm 12'de.

---

## 1. Genel Bakış

Tek kullanıcılı, **local-first**, Android'e özel bir kişisel günlük takip uygulaması. Kullanıcı her gün metrik kartlarına veri girer (yazılım süresi, gelişim alanları, harcama, Instagram süresi, spor, diş fırçalama, enerji israfı, su); sistem bu veriyi ısı haritası, sparkline grafikler ve dönemsel özetlerle görselleştirir. Money metriği tam teşekküllü bir gelir/gider takip alt-sistemine sahiptir.

### 1.1 Temel İlkeler

1. **Local-first, backend yok.** Tüm veri cihazda, internet bağlantısı gerekmez. Sunucu, hesap, senkron yok.
2. **Tek doğruluk kaynağı: cihazdaki şifreli SQLite.** Bildirimler dahil her şey yerel.
3. **Veri-güdümlü davranış.** Isı haritası renk kuralları, metrik tanımları, checkbox seçenekleri kodda değil veritabanında yaşar. Yeni metrik eklemek kod değişikliği gerektirmez.
4. **Her şey bir metrik ağacı düğümüdür.** Yaprak metrikler (Software), gruplar (Development), özel gruplar (Money) — hepsi tek `metrics` tablosunda `parent_id` ile.
5. **Alan başlıkları ve kullanıcı giriş dili: İngilizce.** UI metinleri İngilizce. Sabah motivasyon sözleri varsayılan Türkçe (Settings'ten değiştirilebilir).

### 1.2 Kapsam Dışı (bilinçli olarak yok)

- Backend / API / senkron / çoklu cihaz
- E-posta (Gmail), push (FCM), Notion entegrasyonu
- iOS / web / desktop
- Çoklu kullanıcı / hesap sistemi
- CRDT (tek cihaz → last-write gerekmiyor bile; tek yazar var)

---

## 2. Mimari Kararlar (ADR Özeti)

### ADR-1: Local-first, backend yok
**Karar:** Sunucu katmanı tamamen kaldırıldı.
**Gerekçe:** E-posta düştü → Gmail API gereksiz. Bildirim cihaz-içi → FCM gereksiz (FCM sunucudan-cihaza push içindir; cihazın kendi zamanladığı bildirim için `flutter_local_notifications` yeterli). Tek cihaz → senkron gereksiz. Geriye kalan tek sunucu işi (sabah sözü) gömülü yerel JSON havuzuyla çözülür.
**Bedel:** Veri yalnızca telefonda yaşar. **Mitigasyon:** haftalık otomatik şifreli yedek + manuel export (Bölüm 10).

### ADR-2: Tablo-başına-kart DEĞİL, tek metrik ağacı
**Karar:** Her kart için ayrı tablo YASAK. Tüm kartlar tek `metrics` tablosunda satır; hiyerarşi `parent_id` ile.
**Gerekçe:** Tablo-başına model, kullanıcı ADD'e her bastığında çalışma zamanında `CREATE TABLE` gerektirir → (a) migration imkânsızlaşır, (b) "günün tüm metriklerini getir" sorgusu N-tablo JOIN olur, (c) sürükle-bırak gruplama (kartı kartın üstüne bırak → Development/Marketing) iki tabloyu birleştiren şema ameliyatına döner. Ağaç modelinde aynı işlem tek `UPDATE metrics SET parent_id = ?`.
**Sonuç:** Sıfır runtime DDL. Tek mekanik, tek şema.

### ADR-3: Tanım/değer ayrımı
**Karar:** Metrik tanımları (`metrics`) ile günlük değerler (`entries`) ayrı tablolarda.
**Gerekçe:** Tanım nadiren değişir, değer her gün üretilir. Ayrım, geçmişi bozmadan metrik düzenlemeyi ve hızlı gün-bazlı sorguyu sağlar.

### ADR-4: Money ayrı akış
**Karar:** Money günlük tek-değer kuralından muaf; işlemler `transactions` tablosunda günde N satır.
**Gerekçe:** Bir günde birden çok gelir/gider olur. `entries` üzerindeki `UNIQUE(metric_id, date)` kısıtı Money için anlamsız. Analiz sayfasındaki `Money: <günlük toplam>` değeri `transactions`'tan türetilir, `entries`'e yazılmaz.

### ADR-5: Isı haritası kuralları veride
**Karar:** Renk eşikleri `metrics.heatmap_rule` JSON kolonunda; kodda `if` zinciri yok.
**Gerekçe:** Yeni yıldızlanan metrik kendi kuralıyla haritaya girer, kod değişmez.

---

## 3. Teknoloji Yığını

| Katman | Seçim | Not |
|---|---|---|
| UI | Flutter (yalnızca Android target) | Material 3, koyu tema desteği |
| Yerel DB | Drift (üzerinde SQLCipher) | `drift` + `sqlcipher_flutter_libs` |
| DB anahtarı | `flutter_secure_storage` | Android Keystore destekli — anahtar ASLA koda gömülmez |
| Bildirimler | `flutter_local_notifications` | inexact alarm varsayılan; bkz. Bölüm 8 |
| Grafikler | `CustomPainter` (sparkline, ısı haritası) | Harici chart kütüphanesi YOK — tam kontrol, hafiflik |
| Sürükle-bırak | Flutter `ReorderableListView` + özel `DragTarget` | Bölüm 7 |
| Export | `csv` paketi + `syncfusion_flutter_xlsio` ya da `excel` paketi | Bölüm 10 |
| Dosya erişimi | Storage Access Framework (SAF) — `file_picker` / `saf` | Yedek klasörü kullanıcı seçer |
| State | Riverpod (öneri) | Provider da kabul; Claude Code tutarlı kalsın |

**Minimum SDK:** Android 8.0 (API 26). **Target:** güncel stabil API.

---

## 4. Veri Modeli

### 4.1 Şema (Drift tablolarına çevrilecek referans SQL)

```sql
-- Metrik ağacı: her kart bir satır. Gruplar da, yapraklar da burada.
CREATE TABLE metrics (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    parent_id     INTEGER REFERENCES metrics(id) ON DELETE CASCADE,
    key           TEXT NOT NULL UNIQUE,        -- 'software', 'development', 'money'...
    title         TEXT NOT NULL,               -- UI'da görünen ad (İngilizce)
    input_type    TEXT NOT NULL,               -- 'int' | 'text' | 'int_text' | 'checkbox' | 'composite' | 'money'
    is_starred    INTEGER NOT NULL DEFAULT 0,  -- 1 → ısı haritasında görünür
    heatmap_label TEXT,                        -- yıldızlama anında sorulan ≤2 kelimelik etiket
    heatmap_rule  TEXT,                        -- JSON bucket kuralı (Bölüm 5)
    sort_order    INTEGER NOT NULL DEFAULT 0,  -- ana sayfa kart sırası
    unit          TEXT,                        -- 'min' | 'L' | 'TL' | NULL (gösterim için)
    is_deletable  INTEGER NOT NULL DEFAULT 1,  -- çekirdek 9 metrik için 0 yapılabilir (Açık Nokta #2)
    created_at    INTEGER NOT NULL,            -- epoch ms
    updated_at    INTEGER NOT NULL
);

-- Checkbox / çok-seçimli seçenekler (Brushing → morning/noon/evening; Development alt alanları seçimi)
CREATE TABLE metric_options (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    metric_id  INTEGER NOT NULL REFERENCES metrics(id) ON DELETE CASCADE,
    label      TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- Günlük değerler: metrik × gün başına TEK satır (Money hariç — o transactions kullanır)
CREATE TABLE entries (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    metric_id   INTEGER NOT NULL REFERENCES metrics(id) ON DELETE CASCADE,
    date        TEXT NOT NULL,                 -- 'YYYY-MM-DD' (yerel saat dilimi)
    num_value   REAL,                          -- int/float girişler (dk, L, adet)
    text_value  TEXT,                          -- açıklama / serbest metin
    created_at  INTEGER NOT NULL,
    updated_at  INTEGER NOT NULL,
    UNIQUE(metric_id, date)                    -- günde-tek-değer kuralının zorlayıcısı
);

-- O gün hangi checkbox'lar seçildi
CREATE TABLE entry_options (
    entry_id   INTEGER NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    option_id  INTEGER NOT NULL REFERENCES metric_options(id) ON DELETE CASCADE,
    PRIMARY KEY (entry_id, option_id)
);

-- Money alt-sistemi: günde N işlem
CREATE TABLE transactions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    date            TEXT NOT NULL,             -- 'YYYY-MM-DD'
    direction       TEXT NOT NULL,             -- 'income' | 'outcome'
    amount          REAL NOT NULL CHECK (amount >= 0),
    category        TEXT NOT NULL,             -- 'Bill', 'Scholarship', 'Rent'...
    subtype         TEXT,                      -- 'home', 'phone'... NULL ise düz kategori
    note            TEXT,
    created_at      INTEGER NOT NULL,
    updated_at      INTEGER NOT NULL
);

-- Kategori sözlüğü: dropdown kaynağı + zaruri bayrağı
CREATE TABLE money_categories (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    direction    TEXT NOT NULL,                -- 'income' | 'outcome'
    name         TEXT NOT NULL,
    is_essential INTEGER NOT NULL DEFAULT 0,   -- 1 → zaruri gider (kırmızı/yeşil formülünde düşülür)
    counts_in_heatmap INTEGER NOT NULL DEFAULT 0, -- 1 → Money ısı haritası toplamına girer (yemek+eğlence)
    sort_order   INTEGER NOT NULL DEFAULT 0,
    UNIQUE(direction, name)
);

-- Gider hatırlatmaları (yerel bildirim kuyruğu)
CREATE TABLE expense_reminders (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id  INTEGER NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    remind_date     TEXT NOT NULL,             -- işlem tarihinden offset gün önce
    fired           INTEGER NOT NULL DEFAULT 0
);

-- Uygulama ayarları (key-value)
CREATE TABLE app_settings (
    key   TEXT PRIMARY KEY,                    -- 'morning_time', 'evening_time', 'quote_lang',
    value TEXT NOT NULL                        -- 'quotes_enabled', 'backup_dir_uri', 'backup_enabled'
);

CREATE INDEX idx_entries_date ON entries(date);
CREATE INDEX idx_tx_date ON transactions(date);
CREATE INDEX idx_metrics_parent ON metrics(parent_id);
```

### 4.2 `input_type` Eşlemesi

| Tip | Davranış | Örnek |
|---|---|---|
| `int` | Tek sayı alanı | Water (L) |
| `text` | Tek metin alanı, boş bırakılabilir | Extra |
| `int_text` | Sayı + açıklama metni; sayı 0 ise metin alanı açılmaz (Sport kuralı) | Software, Instagram, Sport |
| `checkbox` | `metric_options`'tan çoklu seçim | Brushing, Waste (tek seçenekli) |
| `composite` | Grup: alt metrik seçimi + seçilen her alt için metin | Development |
| `money` | Özel kart: Income/Outcome butonları → `transactions` akışı | Money |

### 4.3 Çekirdek Seed Verisi (ilk kurulumda eklenir)

| key | title | input_type | unit | parent | not |
|---|---|---|---|---|---|
| `software` | Software | int_text | min | — | "How many minutes of manual code today?" + "What did you do?" |
| `development` | Development | composite | — | — | alt seçim: Marketing / Leadership / Social |
| `dev_marketing` | Marketing | text | — | development | |
| `dev_leadership` | Leadership | text | — | development | |
| `dev_social` | Social | text | — | development | |
| `money` | Money | money | TL | — | transactions akışı |
| `extra` | Extra | text | — | — | opsiyonel; "Any extra improvement?" |
| `instagram` | Instagram | int_text | min | — | dakika + neden |
| `sport` | Sport | int_text | min | — | 0 → metin alanı kapalı |
| `brushing` | Brushing | checkbox | — | — | options: Morning / Noon / Evening |
| `waste` | Waste | checkbox | — | — | tek seçenek: "Honest energy waste — yes"; işaretsiz = no |
| `water` | Water | int | L | — | ondalık kabul (REAL) |

Hepsi `is_starred = 1` + Bölüm 5'teki `heatmap_rule` JSON'ları ile seed edilir.
`money_categories` seed: Outcome → Rent (essential), Bill (essential), Food (counts_in_heatmap), Entertainment (counts_in_heatmap); Income → Scholarship. Kullanıcı sonradan ekler/düzenler.

---

## 5. Isı Haritası Kural Motoru

### 5.1 JSON Şeması (`metrics.heatmap_rule`)

```json
{
  "source": "num_value | option_count | text_exists | filled_subcount | tx_sum_heatmap",
  "buckets": [
    { "min": 0,  "max": 20,  "color": "black" },
    { "min": 20, "max": 40,  "color": "lightBlue" },
    { "min": 40, "max": 60,  "color": "blue" },
    { "min": 60, "max": null, "color": "darkBlue" }
  ]
}
```

- `min` dahil, `max` hariç; `max: null` → sonsuz üst sınır.
- `source` türleri:
  - `num_value` → entries.num_value
  - `option_count` → o günün seçili checkbox sayısı
  - `text_exists` → text_value dolu mu (0/1)
  - `filled_subcount` → composite grupta dolu alt-metrik sayısı
  - `tx_sum_heatmap` → o günün `counts_in_heatmap=1` kategorili outcome toplamı
- Renk paleti uygulamada sabit bir map: `black, white, lightBlue, blue, darkBlue, lightYellow, yellow, darkYellow, lightGreen, green, darkGreen, orange, lightPink, pink, darkPink, red` → hex değerleri tek bir `HeatColors` sınıfında.

### 5.2 Çekirdek 9 Metriğin Kuralları (spec'ten birebir)

| Metrik | source | Kural |
|---|---|---|
| Software | num_value | 0–20 black, 20–40 lightBlue, 40–60 blue, 60+ darkBlue |
| Development | filled_subcount | 0 black, 1 lightYellow, 2 yellow, 3 darkYellow |
| Money | tx_sum_heatmap | 0–300 darkGreen, 300–600 green, 600–750 lightGreen, 750+ black *(yalnızca yemek+eğlence kategorileri)* |
| Extra | text_exists | var → orange, yok → white |
| Instagram | num_value | 0–20 lightPink, 20–30 pink, 30–40 darkPink, 40+ black |
| Sport | num_value | 0 white, 0–60 blue, 60+ red |
| Brushing | option_count | 0–1 darkYellow, 2 yellow, 3 white |
| Waste | option_count | seçili (yes) → red, boş (no) → white |
| Water | num_value | 0 black, 1–2 lightBlue, 2–3 blue, 3+ darkBlue *(0–1 arası: lightBlue'ya dahil — Açık Nokta #3)* |

### 5.3 Görüntüleme Kuralları

- Sıra SABİT: Software, Development, Money, Extra, Instagram, Sport, Brushing, Waste, Water. Sonradan yıldızlanan metrikler bu listenin ALTINA, yıldızlanma sırasıyla eklenir.
- Satır = metrik (heatmap_label ile), sütun = gün. Görünür pencere: seçili günden geriye sığan kadar gün (yatay kaydırılabilir).
- Hücreye dokunmak takvim tarihini o güne çeker.
- Satır etiketine dokunmak metriğin detay sayfasını açar (Money → Money sayfası).
- Veri girilmemiş gün hücresi: tema arka planına uygun "boş" görünüm (white bucket'tan AYIRT EDİLEBİLİR olmalı — ince kesikli kenarlık).

---

## 6. Ekran Spesifikasyonları

### 6.1 Gezinme İskeleti

- İki ana sayfa yatay `PageView` içinde: **[0] Ana sayfa (giriş)** ↔ **[1] Analiz**. Sağa/sola kaydırma ile geçiş.
- Detay sayfaları (metrik detay, Money) analizden push edilir; geri tuşu analize döner.
- Hamburger menü ana sayfanın sol üstünden `Drawer` olarak açılır.
- Uygulama her zaman ana sayfada açılır (bildirimden gelince de).

### 6.2 Ana Sayfa (Giriş)

Yapı (yukarıdan aşağı):
1. AppBar: sol ☰, başlık, (opsiyonel) bugünün tarihi.
2. Dikey kaydırılabilir kart listesi. Her kart:
   - Sol üst: ⭐ yıldız ikonu (dolu = ısı haritasında).
   - Başlık (title).
   - Sağ üst, sağa yaslı: **Del** butonu → onay diyaloğu → metrik + tüm geçmişi silinir (CASCADE). Silme GERİ ALINAMAZ uyarısı zorunlu.
   - Gövde: input_type'a göre giriş alanı.
   - **Doldurulmamış gün göstergesi:** o gün için `entries` kaydı yoksa kart kenarlığı soluk/noktalı. Money'de: o gün hiç transaction yoksa.
3. En altta **(+ ADD)** butonu.

**Kayıt davranışı:** alan değişikliğinde debounce'lu otomatik upsert (`INSERT ... ON CONFLICT(metric_id, date) DO UPDATE`). Ayrı "kaydet" butonu yok. Gün içinde değer değiştirilebilir; satır çoğalmaz.

**ADD akışı (bottom sheet):**
1. Title gir (zorunlu, metrikler arasında benzersiz key'e slug'lanır).
2. Input type seç: int / text / checkbox.
3. checkbox seçilirse: seçenek satırları; her (+) yeni satır, her satıra etiket.
4. Kaydet → kart listenin sonuna eklenir (`sort_order = max + 1`), yıldızsız başlar.

**Yıldız akışı:**
- ⭐'a dokun → mini diyalog: "How should this appear in the heatmap? (max 2 words)" → heatmap_label kaydedilir, `is_starred = 1`.
- Yeni yıldızlanan metrik için varsayılan heatmap_rule: input_type'a göre makul bir şablon (int → 4'lü mavi bucket; text → text_exists; checkbox → option_count). Kullanıcı kuralı Settings'ten düzenleyebilir (Faz 7+).
- Yıldızı geri kapatmak: tekrar dokun → `is_starred = 0`, haritadan düşer (geçmiş veri silinmez).

**Money kartı (input_type = money):**
- Başlık altında yan yana iki buton: **Income | Outcome** (alanı yarı yarıya kaplar).
- Dokununca kart içinde aşağı açılır form: Amount → kategori dropdown (money_categories'ten, direction'a göre filtreli) → (+) ile yeni kategori → kategori seçilince opsiyonel "Subtype?" alanı (boş → düz `Bill`; dolu → `Bill (home)`).
- **Outcome kaydetmeden önce:** "Set a reminder?" → çoklu seçim: Same day / 1 day before / 2 days before / 3 days before. 0–4 arası seçilebilir. Seçilenler `expense_reminders`'a yazılır, yerel bildirim zamanlanır.
- Income'da hatırlatma sorusu YOK.

### 6.3 Analiz Sayfası

1. **Takvim satırı:** varsayılan dünün tarihi (`bugün − 1`). Dokun → takvim → herhangi bir güne git; tüm sayfa o güne döner. Gelecek tarihler seçilemez.
2. **Isı haritası** (Bölüm 5).
3. **Günlük döküm** (seçili gün):
   ```
   Software: 35 min
   > [text_value — dropdown, açılır/kapanır]

   Development: Marketing, Leadership      ← yalnızca DOLU alt başlıklar
   > Marketing
   >> [yapılan şey]
   > Leadership
   >> [yapılan şey]

   Money: 540 TL                            ← o günün toplam harcaması (tüm outcome)
   > Outcome (Month): 12.300
   >> Rent: 8.000
   >> Bill: 2.500
   > Income (Month): 15.000
   >> Scholarship: 15.000
   ```
4. Dökümdeki HER başlık dokunulabilir → metrik detay sayfası (Money → Money sayfası).

**Grup gösterim kuralı:** composite başlık (a) varsayılan: yalnızca dolu alt başlıkların adlarını listeler, ya da (b) kendi özel değerini gösterir — bu davranış metrik başına değiştirilebilir bir ayardır (`metrics` tablosuna `group_display` kolonu: 'sub_names' | 'own_value', varsayılan 'sub_names').

### 6.4 Metrik Detay Sayfası (şablon — her yaprak metrik için)

1. Takvim satırı (analizle aynı bileşen, dün varsayılan).
2. **Sparkline:** GitHub koyu neon yeşili (#39d353 ailesi), seçili tarihin AYI penceresi. Farklı aya gidilirse grafik o ayın penceresine döner. Noktaya dokun → tarih o güne atlar. CustomPainter ile çizilir.
3. Altında otomatik hesaplanan üç satır:
   - **Daily:** seçili günün değeri
   - **Weekly:** seçili günü içeren haftanın toplamı/ortalaması (sayısal metrikte toplam; Açık Nokta #4)
   - **Monthly:** ayın toplamı/ortalaması

### 6.5 Money Sayfası

Üstte takvim, altında **General / Monthly** anahtarı.

**General:**
- Sparkline, aylık pencere; renk kuralı:
  ```
  daily_budget = (ay_toplam_income − ay_zaruri_giderler) / aydaki_gün_sayısı
  gün_lüks = o günün is_essential=0 kategorili outcome toplamı
  gün_lüks > daily_budget → o günün noktası KIRMIZI, değilse YEŞİL
  ```
  (zaruri = `money_categories.is_essential = 1`)
- Noktaya dokun → tarih atlar.
- Altında iki dropdown blok:
  ```
  Income: 15.000            ← aylık toplam
  > Scholarship: 15.000
  Outcome: 12.300
  > Rent: 8.000
  > Bill: 2.500
  >> Bill (home): 2.000     ← subtype kırılımı (varsa)
  >> Bill (phone): 500
  ```

**Monthly:**
- Tablo: sol Income (Description / Amount), orta Date, sağ Outcome (Description / Amount).
- Satır sayısı dinamik: aynı tarihte bir taraftan N giriş varsa N satır; HİÇ girişi olmayan tarihler gösterilmez; maksimum satır kaynağı ayın gün sayısı × giriş yoğunluğu.
- Subtype gösterimi: `Bill (home)`; toplamalar her zaman `category` üzerinden (`GROUP BY category`).
- Tabloda satıra uzun bas → işlemi düzenle/sil.

### 6.6 Hamburger Menü → Settings / Export

**Settings:**
- Notification times: morning (varsayılan 08:00), evening (varsayılan 22:00) — time picker.
- Morning quotes: on/off + dil (TR/EN).
- Backup: klasör seç (SAF), haftalık otomatik yedek on/off, "Back up now".
- Heatmap rules editörü (Faz 7+): metrik seç → bucket'ları düzenle.
- Essential categories: money_categories listesi, is_essential ve counts_in_heatmap anahtarları.

**Export / Import:**
- Export CSV ve Export Excel (Bölüm 10 formatı).
- "Download sample CSV" → şablon dosya.
- Import CSV → şablon formatında dosya seç → doğrulama → toplu upsert.

---

## 7. Hareketler ve Etkileşimler

| Hareket | Yer | Sonuç |
|---|---|---|
| Yatay kaydırma | Ana ↔ Analiz | Sayfa geçişi |
| Dikey kaydırma | Ana sayfa | Kart listesi scroll |
| Karta uzun bas | Ana sayfa | **Sıralama modu**: kart hafif büyür/titrer |
| Sıralama modunda yukarı/aşağı sürükle-bırak | Ana sayfa | `sort_order` güncellenir |
| Sıralama modunda kartı BAŞKA KARTIN ÜSTÜNE bırak | Ana sayfa | Bırakılan kart hedefin ÇOCUĞU olur (`parent_id = hedef.id`); hedef otomatik `composite`'a yükselir (yaprak idiyse). Onay diyaloğu: "Make X a sub-item of Y?" |
| Çocuk kartı boşluğa/köke sürükle | Ana sayfa | `parent_id = NULL` — gruptan çıkar |
| ⭐ dokunuş | Kart başlığı | Yıldız akışı (6.2) |
| Isı haritası hücresine dokun | Analiz | Tarih o güne atlar |
| Isı haritası satır etiketi / döküm başlığına dokun | Analiz | Metrik detay / Money sayfası |
| Sparkline noktasına dokun | Detay sayfaları | Tarih atlar |
| Tablo satırına uzun bas | Money Monthly | İşlem düzenle/sil |

**Hiyerarşi sınırı:** maksimum 2 seviye (grup → yaprak). Bir grubu başka grubun içine bırakma engellenir (UI reddeder) — Money içi Income/Outcome/subtype zaten transactions'ta modellendiği için metrik ağacında 3. seviyeye gerek yok.

---

## 8. Bildirim Sistemi (tamamen yerel)

| Bildirim | Zaman | İçerik | Dokununca |
|---|---|---|---|
| Morning quote | 08:00 (ayarlanabilir) | Günün sözü (gömülü JSON havuzundan, tarihe göre deterministik seçim: `quotes[dayOfYear % quotes.length]`) | Ana sayfa |
| Evening reminder | 22:00 (ayarlanabilir) | "Time to fill in your day" — o gün eksik kart sayısı eklenebilir: "4 items left" | Ana sayfa (eksik kartlar işaretli) |
| Expense reminder | İşlem tarihinden offset gün önce, 10:00 | **Yalnızca kategori adı:** "Reminder: Bill" — TUTAR ASLA YAZILMAZ (kilit ekranı sızıntısı) | Money sayfası |

**Android gereksinimleri:**
- Android 13+ `POST_NOTIFICATIONS` runtime izni — ilk açılış onboarding'inde istenir; reddedilirse Settings'te uyarı banner'ı.
- Varsayılan **inexact alarm** (±dakikalar tolere edilir) → `SCHEDULE_EXACT_ALARM` izin çilesine girilmez. Settings'te "Exact timing" opsiyonel anahtarı (açılırsa izin akışı tetiklenir).
- Cihaz yeniden başlatınca alarmlar kaybolur → `BOOT_COMPLETED` receiver ile yeniden zamanlama.
- Söz havuzu: `assets/quotes_tr.json`, `assets/quotes_en.json` — her biri ≥120 söz (yıl boyu tekrar hissi az olsun).

---

## 9. Money Alt-Sistemi — Kurallar Özeti

1. **Günde N işlem** — `transactions`, entries'in UNIQUE kuralından muaf.
2. **Kategori/subtype iki kolon.** String parse YASAK ("Bill(home)" vs "Bill (home)" tutarsızlığı toplamları bozar). Toplama `GROUP BY category`; gösterim `subtype IS NOT NULL` ise `Category (subtype)`.
3. **Isı haritası toplamı** yalnızca `counts_in_heatmap = 1` kategorilerin (varsayılan: Food, Entertainment) günlük outcome toplamı — spec'teki "sadece yemek ve eğlence" kuralı.
4. **Kırmızı/yeşil eşiği** `is_essential = 1` kategoriler üzerinden (6.5'teki formül). Bayrak kategori düzeyinde — bir kez işaretlenir, sistem sürekli uygular.
5. **Analiz sayfası Money satırı:** günlük TÜM outcome toplamı (heatmap filtresi UYGULANMAZ — heatmap rengi ile döküm değeri farklı kaynaklı olabilir, bu bilinçli).
6. **Hatırlatma bildirimi tutar içermez** (Bölüm 8).

---

## 10. Export / Import / Yedekleme

### 10.1 Export (CSV ve Excel)

Üç sayfa/dosya:
1. **entries.csv** — `date,metric_key,num_value,text_value,selected_options`
   (`selected_options` = `;` ile ayrılmış option label'ları)
2. **transactions.csv** — `date,direction,category,subtype,amount,note`
3. **metrics.csv** — `key,title,parent_key,input_type,is_starred,heatmap_label,unit`

Excel'de aynı üç sheet tek `.xlsx` içinde. Export sırasında tek uyarı diyaloğu: "Exported files are NOT encrypted. Keep them safe."

### 10.2 Import (yalnızca CSV)

- Şablon: Export formatının birebir aynısı ("Download sample CSV" bu şablonu örnek 3 satırla verir).
- Doğrulama: bilinmeyen `metric_key` → satır atlanır + rapor; tarih format hatası → satır atlanır + rapor; mevcut `(metric_id, date)` → UPSERT (üzerine yazar, kullanıcıya çakışma sayısı gösterilir).
- İçe aktarma transaction (DB anlamında) içinde — yarıda hata olursa tamamı geri alınır.

### 10.3 Haftalık Otomatik Yedek

- Her Pazar 03:00 (WorkManager / `workmanager` paketi, cihaz şarjda+boşta tercihli).
- İçerik: DB'nin tamamının export'u (üç CSV) + `app_settings` → tek ZIP → **AES-256 parola ile şifreli** (parola ilk kurulumda kullanıcıdan alınır, `flutter_secure_storage`'da tutulur; kullanıcıya "bu parolayı kaybedersen yedek açılamaz" uyarısı).
- Hedef: kullanıcının SAF ile seçtiği klasör (Drive'ın senkronladığı bir klasör seçilirse buluta kendiliğinden gider — uygulama Drive API kullanmaz).
- Son 8 yedek tutulur, eskisi silinir.

---

## 11. Güvenlik Gereksinimleri (zorunlu)

1. **At-rest şifreleme:** Drift + SQLCipher. Düz `.db` dosyası YASAK.
2. **DB anahtarı:** ilk açılışta `Random.secure()` ile üretilir, `flutter_secure_storage`'a (Android Keystore) yazılır. Koda/SharedPreferences'a gömme YASAK — `apktool` ile açan herkes DB'yi çözer.
3. **Parametreli sorgular:** tüm SQL Drift'in tip-güvenli API'siyle ya da bound-param ile. String interpolation'lı SQL (`"...'$text'..."`) YASAK — `text_value` serbest kullanıcı metnidir, klasik injection yüzeyi. (Tek kullanıcı olması alışkanlığı bozmaz.)
4. **Bildirim içeriği:** tutar, kişisel metin, harcama detayı ASLA bildirime yazılmaz. Yalnızca kategori adı / genel hatırlatma.
5. **Export uyarısı:** şifresiz export öncesi diyalog (10.1). Otomatik yedek HER ZAMAN şifreli.
6. **Ekran görüntüsü:** Money sayfalarında `FLAG_SECURE` opsiyonel ayarı (Settings'te, varsayılan kapalı).
7. **Yedek parolası** hiçbir log'a, hata mesajına, export dosyasına yazılmaz.
8. **İleride LLM/rapor özelliği eklenirse:** ham `text_value` ve işlem kayıtları modele gönderilmez; yalnızca kimliksizleştirilmiş özet metrikler (Red Zone/Green Zone disiplini). Şimdilik kapsam dışı ama mimari not olarak kalıcı.

---

## 12. Build Fazları (branch sırası + kabul kriterleri)

Her faz ayrı branch: `phase-0-scaffold`, `phase-1-entry`, ... Her faz sonunda: çalışan uygulama, faz testleri yeşil, `main`'e merge.

### Faz 0 — İskelet ve Veri Katmanı (`phase-0-scaffold`)
- Flutter projesi (Android-only), Riverpod, Drift + SQLCipher kurulumu.
- Bölüm 4 şeması Drift tablolarına; migration altyapısı; seed verisi (çekirdek 12 metrik + options + heatmap_rule JSON'ları + money_categories).
- DB anahtarı üretimi + secure storage.
- **Kabul:** uygulama açılır, seed doğrulanır (test: 12 metrik, Brushing 3 option, tüm heatmap_rule'lar parse edilir), DB dosyası hex dump'ta düz metin İÇERMEZ.

### Faz 1 — Ana Sayfa: Giriş (`phase-1-entry`)
- Kart listesi, tüm input_type render'ları (money hariç), debounce'lu upsert, Del akışı, ADD bottom sheet, doldurulmamış kart göstergesi.
- **Kabul:** her tip için giriş→kapat→aç→değer korunur; aynı güne ikinci giriş satır ÇOĞALTMAZ (UNIQUE testi); ADD ile eklenen checkbox metriği çalışır.

### Faz 2 — Hareketler ve Ağaç (`phase-2-tree`)
- Uzun bas → sıralama; sürükle-bırak sort_order; kart-üstüne-bırak → parent_id + onay; gruptan çıkarma; 2-seviye sınırı; composite render (Development davranışı).
- Yıldız akışı + heatmap_label.
- **Kabul:** Marketing'i Development'a bırak → analiz dökümünde `Development: Marketing` görünür; grup grubun içine bırakılamaz.

### Faz 3 — Analiz Sayfası (`phase-3-analysis`)
- PageView geçişi, takvim (dün varsayılan, gelecek kapalı), ısı haritası motoru (JSON kural yorumlayıcı + CustomPainter), günlük döküm + dropdown'lar, group_display kuralı.
- **Kabul:** 9 çekirdek satır sabit sırada; spec'teki TÜM bucket kuralları birim testli (örn. Software 35 → blue? hayır: 20–40 lightBlue — test tablosu yazılır); hücre dokunuşu tarihi değiştirir; yeni yıldızlanan metrik haritanın altına eklenir.

### Faz 4 — Metrik Detay (`phase-4-detail`)
- Şablon sayfa: takvim + aylık sparkline (CustomPainter, #39d353) + Daily/Weekly/Monthly.
- Ay değişiminde grafik penceresi değişir; nokta dokunuşu tarih atlatır.
- **Kabul:** analizden her başlık kendi sayfasını açar; ay sınırında pencere doğru kayar (31→30 gün ayları test).

### Faz 5 — Money (`phase-5-money`)
- Money kartı (Income/Outcome formu, kategori+subtype, yeni kategori ekleme), General sayfası (kırmızı/yeşil sparkline + Income/Outcome dropdown blokları), Monthly tablosu (dinamik satır, boş tarih atlama), işlem düzenle/sil.
- **Kabul:** formül birim testli (income 15.000, essential 10.500, 30 gün → budget 150; gün lüks 200 → kırmızı); `Bill (home)` + `Bill (phone)` → dropdown'da `Bill: toplam` altında kırılım; Monthly tabloda girişsiz tarih görünmez.

### Faz 6 — Bildirimler (`phase-6-notifications`)
- flutter_local_notifications; 08:00 söz (quotes_tr.json ≥120 söz), 22:00 hatırlatma (+eksik sayısı), gider hatırlatmaları; POST_NOTIFICATIONS onboarding; BOOT_COMPLETED yeniden zamanlama; bildirim→ana sayfa yönlendirme.
- **Kabul:** bildirimde tutar ASLA görünmez (test: payload assert); yeniden başlatma sonrası alarmlar geri kurulur.

### Faz 7 — Settings, Export/Import, Yedek (`phase-7-data-io`)
- Drawer + Settings (saatler, dil, quotes on/off, essential/heatmap kategori anahtarları, heatmap kural editörü v1), CSV/Excel export, örnek CSV, CSV import (doğrulama+rapor+tek transaction), haftalık şifreli ZIP yedek (WorkManager + SAF), "Back up now".
- **Kabul:** export→temiz kuruluma import → veri birebir; bozuk satırlı CSV kısmî değil TAM geri alınır; yedek ZIP parolasız açılamaz.

### Faz 8 — Cila ve Sertleştirme (`phase-8-polish`)
- Koyu/açık tema kontrolü, boş-durum ekranları, FLAG_SECURE opsiyonu, performans (1 yıllık veriyle ısı haritası <16ms frame), widget testleri, hata yakalama.
- **Kabul:** 365 günlük sahte veriyle tüm sayfalar akıcı; norminette değil ama `flutter analyze` sıfır uyarı.

---

## 13. Açık Noktalar ve Varsayımlar

| # | Konu | Varsayılan karar | Onay gerekli mi |
|---|---|---|---|
| 1 | Sabah sözleri dili | TR varsayılan, Settings'ten EN | Kullanıcı teyidi bekleniyor |
| 2 | Çekirdek 9 metrik silinebilir mi | Evet, silinebilir (is_deletable=1) — kullanıcı tam kontrol istiyor | Hayır |
| 3 | Water 0–1 L aralığı spec'te tanımsız (0 black, 1–2 lightBlue) | 0 < x < 1 → lightBlue'ya dahil (min=0 hariç-üstü) | Düşük öncelik |
| 4 | Weekly/Monthly: toplam mı ortalama mı | Sayısal metriklerde TOPLAM (dk, L); istenirse metrik başına ayar eklenir | Düşük öncelik |
| 5 | "Sıralama modunda üst üste bırakma" yanlışlıkla tetiklenirse | Onay diyaloğu her zaman sorulur (7. bölüm) | Hayır |
| 6 | Geçmiş güne veri girişi | KAPANDI (CR-1): ana sayfadaki tarih çipiyle geçmiş güne giriş yapılır; gelecek kapalı; geçmiş outcome'a hatırlatma kurulmaz | Kapandı |

---

## 14. Claude Code Başlangıç Promptu (Faz 0 için)

```
Bu repo'da /docs/daily-tracker-spec.md dosyasını oku. Faz 0'ı uygula:
Android-only Flutter projesi kur (org: dev.deniz, name: daily_tracker).
Riverpod, drift, sqlcipher_flutter_libs, flutter_secure_storage ekle.
Spec Bölüm 4'teki şemayı Drift tablolarına çevir, Bölüm 4.3 + 5.2 seed
verisini migration'da ekle. DB anahtarını Random.secure() ile üret,
flutter_secure_storage'da sakla. Kabul kriterleri: spec Bölüm 12 / Faz 0.
Birim testleri yaz: seed sayıları, heatmap_rule JSON parse, UNIQUE kısıtı.
Branch: phase-0-scaffold. Norminette yok; flutter analyze sıfır uyarı hedefi.
```

Sonraki fazlar için aynı kalıp: "Faz N'i uygula, kabul kriterleri Bölüm 12 / Faz N."

---

*Bu spesifikasyon 2026-06-11 tarihli mimari tartışmasının çıktısıdır. Değişiklikler bu dosyada versiyonlanmalıdır (git).*


---

## CR-1 Güncellemeleri (2026-06-12, uygulandı)

- **6.2 Ana Sayfa:** AppBar tarih çipi + geçmiş gün modu (bugün-değilken vurgulu çip + 'Today' butonu); geçmiş güne outcome girildiğinde hatırlatma sorusu atlanır ve `remind_date < bugün` satırı yazılmaz (CR1-D).
- **6.3 Günlük Döküm:** Düz liste yerine özyinelemeli `ToggleRow` ağacı; tüm seviyeler varsayılan kapalı; ok = aç/kapa (32dp), başlık = detay sayfası; Money 3 seviye (yön → kategori → subtype) (CR1-A).
- **6.4 / 6.5 Sparkline:** Ayın tüm günlerini kapsayan sürekli çizgi; boş/0 günler taban çizgisinde (alt %12 sabit); nokta yok, seçili güne 1dp dikey işaret; ucuz glow + gradyan dolgu; Money aynı painter, eşik aşan günün segmenti kırmızı (CR1-C).
- **Yeni 6.7 Tema:** Tek koyu tema; tüm renkler `lib/theme/app_tokens.dart` token'larından (`Color(0x` ekranlarda yasak, testle zorlanır); BackdropFilter yasak; HeatColors bucket paleti ve sparkline yeşili (#39d353) temadan bağımsız veri renkleri (CR1-B).
