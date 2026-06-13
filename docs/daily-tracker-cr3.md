# Daily Tracker — Change Request 3 (CR-3)
## Büyük Yeniden Yapılandırma: 5-Sekme Navigasyon + Health & Sport

> **Tarih:** 2026-06-12
> **Tip:** STRUCTURAL — uygulama iskeletini değiştirir. En geniş kapsamlı CR.
> **Bağımlılıklar:** `/docs/daily-tracker-spec.md` (ana spec), `/docs/daily-tracker-cr1.md`,
> `/docs/daily-tracker-cr2.md`. Bunlar okunmadan uygulanmaz.
> **Korunan:** Analysis sayfası ESKİ HALİYLE kalır (spec §6.3 + CR1-A). Hiç dokunulmaz.

---

## 0. Ne Değişiyor, Ne Kalıyor

| Alan | Durum |
|---|---|
| Navigasyon | **DEĞİŞİYOR** — 2 sayfa (giriş+analiz) → 5 sekme (Money/Analiz/Main/Health/Sport) |
| Main | **DEĞİŞİYOR** — dashboard + hızlı para + (eski kart listesi buraya taşınır → Daily Check-in) |
| Money | **GENİŞLİYOR** — kendi sekmesi: Overview/İşlemler/Categories iç navigasyon |
| Health | **YENİ** — profil, vücut, hesaplamalar, sensör verisi |
| Sport | **YENİ** — programlar, süperset, kalori takibi |
| Analysis | **DEĞİŞMEZ** — eski ısı haritası + özyinelemeli toggle döküm (spec §6.3 + CR1-A) |
| Tema | CR1-B token'ları tüm yeni sekmelerde KULLANILIR (önce token, sonra ekran) |
| Sparkline | CR1-C sürekli-çizgi motoru Sport sparkline'larında KULLANILIR |
| Geçmiş giriş | CR1-D tarih çipi Main → Daily Check-in'de KULLANILIR |
| Silme koruması | CR2 — çekirdek metrikler Daily Check-in'de silinemez kalır |

---

## 1. BLOKLAYAN KARAR (onay gerekli)

### 1.1 Eski 9 metriğin giriş yüzeyi → Main "Daily Check-in"
**Problem:** Analysis ısı haritası 9 sabit satır gösterir (Software, Development, Money,
Extra, Instagram, Sport, Brushing, Waste, Water). Yeni yapıda Money (transactions'tan)
beslenir ama Software, Development, Extra, Instagram, Brushing, Waste, Water'ın girişi
hiçbir yeni sekmede yok.

**Karar (varsayılan — override edilebilir):** Eski kart listesi (spec §6.2) Main sayfasında
**"Daily Check-in"** bölümü olarak yaşar. Dashboard özetinin altında, dikey kaydırmada.
Tüm CR1-D (geçmiş tarih) + CR2 (silme koruması) + CR1-A davranışları korunur.
- Avantaj: Analysis HİÇ değişmeden çalışır; Main hem dashboard hem giriş; açılış sayfası
  olarak mantıklı (her gün dokunduğun yer).

### 1.2 Sport ikilemi
Eski "Sport: 35 min" günlük metriği ≠ yeni Sport sekmesinin program/kalori takibi.
**Karar:** İkisi AYRI.
- Heatmap'in `sport` satırı: Daily Check-in'deki basit "bugün kaç dk hareket" metriği (eski davranış).
- Sport sekmesi: detaylı antrenman + kalori (yeni).
- Opsiyon (sonra): heatmap sport dakikasını Sport sekmesindeki program sürelerinden türet.
  Şimdilik AYRI — sadeleştirme için.

> Bu iki karar yanlışsa tek bölüm değişir; gerisi bağımsız.

---

## 2. Global Navigasyon

```
┌─────────────────────────────┐
│                             │
│     [aktif sekme içeriği]   │
│        ↕ dikey scroll        │
│        ← global swipe →      │
│                             │
├─────────────────────────────┤
│  💰     📊    🏠    ❤️    🏋️  │ ← sabit
│ Money Analiz Main Health Sport│
│  0      1     2     3     4  │
└─────────────────────────────┘
```

- `PageView` (yatay swipe) + `BottomNavigationBar` senkron; `PageController(initialPage: 2)`
  → uygulama her açılışta **Main**'de.
- Swipe HER ZAMAN global sayfa değiştirir.
- **Money iç navigasyonu (Overview/İşlemler/Categories) yalnızca TAP** — `SegmentedButton`/
  `TabBar`, global `PageView` swipe'ını EZMEZ.
- Money içinde yatay kaydırılan grafik (donut/bar) konursa, gesture arena çakışmasını önle:
  grafiği `NotificationListener` / özel `RawGestureDetector` ile sarmala ki yatay sürüklemeyi
  global swipe'tan çalmasın. (Aksi halde grafiğe dokununca sekme kayar — kötü UX.)
- Açılış ve 22:00 bildirimi DAİMA Main'e + bugüne (CR1-D).

### Kabul Kriterleri (CR3-P0)
- [ ] Açılışta Main (index 2) aktif.
- [ ] 5 sekme swipe + tap ile geçiyor, senkron (swipe sonrası alt bar doğru sekmeyi vurguluyor).
- [ ] Money iç sekmeleri tap ile değişiyor, swipe global kalıyor.
- [ ] Eski Analysis sekme 1'de birebir eski haliyle (golden/widget test: heatmap satırları + döküm).

---

## 3. Main (açılış sayfası)

Sıra: hızlı para → bugün özeti → bakiye → **Daily Check-in** (eski kartlar).

```
┌─ MAIN ──────────────────────┐
│ ☰      Daily Tracker  [2026-06-12 ▾]│ ← tarih çipi (CR1-D)
│ ┌─ Hızlı Para Girişi ──────┐ │
│ │ ( + Income )( − Outcome )│ │
│ │ Tutar:[______] Cat:[▼]   │ │
│ │                   [ADD]  │ │
│ └──────────────────────────┘ │
│ ┌─ Bugün ──────────────────┐ │
│ │ Kalori ▓▓▓░░ 2100/2600   │→Sport│
│ │ Adım   7.420             │→Health│
│ │ Nabız  ♥ 62 (RHR)        │→Health│
│ │ Uyku   7s20d ●●●○ skor80 │→Health│
│ └──────────────────────────┘ │
│ ┌─ Bakiye ─────────────────┐ │
│ │ Bu ay: +12.400 ₺         │→Money│
│ └──────────────────────────┘ │
│ ── Daily Check-in ──         │ ← eski kart listesi (spec §6.2)
│ ┌ ⭐ Software        [Del?] ┐ │   CR1-D tarih, CR1-A döküm,
│ │ [value] + [not]          │ │   CR2 çekirdek silinemez
│ └──────────────────────────┘ │
│ ┌ ⭐ Development     ...    ┐ │
│ │ Marketing/Leadership/Social│ │
│ └──────────────────────────┘ │
│  ... (Extra, Instagram, Sport,│
│   Brushing, Waste, Water, +ADD)│
└─────────────────────────────┘
```

- Özet kartları dokununca ilgili sekmeye gider (kalori→Sport, nabız/uyku/adım→Health,
  bakiye→Money). Bu "deep link" sekme index'ini değiştirir (PageController.jumpToPage).
- Hızlı Para Girişi = Money sekmesindeki giriş formunun aynısı (paylaşılan widget),
  yazdığı yer aynı `transactions` tablosu, `date = aktif tarih çipi`.
- Daily Check-in = spec §6.2'nin tamamı, sadece konumu Main'e taşındı.
- Money özet kartı = o ayın gelir−gider bakiyesi (transactions'tan).

### Kabul Kriterleri (CR3-P1)
- [ ] Özet kartına dokunmak doğru sekmeye atlıyor.
- [ ] Main'deki hızlı para girişi ile Money sekmesindeki giriş aynı veriyi yazıyor (paylaşılan widget testi).
- [ ] Daily Check-in tüm eski davranışları koruyor (CR1-A/CR1-D/CR2 testleri Main altında geçiyor).
- [ ] Sensör özetleri veri yoksa "—" gösteriyor, crash yok.

---

## 4. Money (sekme 0)

İç navigasyon (tap-only) + üstte paylaşılan giriş formu.

```
┌─ MONEY ─────────────────────┐
│ [ Overview | İşlemler | Cat ]│ ← TAB (tap), swipe global
│ ┌─ Giriş ──────────────────┐ │
│ │ ( + Income )( − Outcome )│ │
│ │ Tutar:[______] Cat:[▼]   │ │
│ │  (Outcome → hatırlatma?) │ │  ← spec §6.2 reminder akışı
│ │                   [ADD]  │ │
│ └──────────────────────────┘ │
│ ── Overview ──              │
│ Bakiye: +12.400 ₺           │
│ [ donut: kategori dağılımı ] │  ← gesture-safe sarmalama
│ ── İşlemler ──              │
│  − Market        −350 ₺  ⋮  │  ← uzun bas: düzenle/sil
│  + Maaş       +20.000 ₺  ⋮  │
│ ── Categories ──            │
│  Outcome: Rent*, Bill*, Food°│  *essential °heatmap
│  Income:  Scholarship        │
│  [ +kategori ] [essential ⇄] │
└─────────────────────────────┘
```

- **Overview:** aylık bakiye + kategori donut (CustomPainter; harici chart yok).
  Income/Outcome kırılımı CR1-A özyinelemeli toggle ile (`Bill` → `Bill (home)`).
- **İşlemler:** seçili ayın işlem listesi, en yeni üstte; uzun bas → düzenle/sil.
- **Categories:** `money_categories` yönetimi — essential ve counts_in_heatmap anahtarları
  (spec §9). Buradaki bayraklar kırmızı/yeşil formülünü ve heatmap toplamını besler.
- Money'nin detaylı General/Monthly sayfaları (spec §6.5) Overview'ın alt görünümleri
  olarak KORUNUR — Monthly tablosu "İşlemler" sekmesinin tam-tablo modu olabilir.
  (Spec §6.5 ile çakışma yok; bu CR onu Money sekmesi içine yerleştirir.)
- **Analysis → Money geçişi YOK** (kaynak doküman kuralı). Money'ye yalnızca Money sekmesi
  ve Main özet kartından gidilir. Ama Analysis dökümünde `Money: <toplam>` satırı GÖRÜNMEYE
  devam eder (spec §6.3) — sadece dokununca Money sekmesine ATMAZ; salt-okunur kalır.

### Kabul Kriterleri (CR3-P2)
- [ ] 3 iç sekme tap ile değişiyor; swipe global.
- [ ] Donut'a yatay dokunuş global swipe'ı tetiklemiyor (gesture arena testi).
- [ ] Categories'te essential işaretlemek kırmızı/yeşil formülünü etkiliyor.
- [ ] Analysis döküm Money satırı salt-okunur (Money sekmesine atlamıyor).

---

## 5. Health (sekme 3)

Manuel girişler üstte (hesapları besler), çekilen veriler altta.

```
┌─ HEALTH ────────────────────┐
│ ┌─ Profil (manuel, 1 kez) ─┐ │
│ │ Yaş:[__] Cinsiyet:[▼]    │ │
│ │ Boy:[___]cm Aktivite:[▼] │ │
│ └──────────────────────────┘ │
│ ┌─ Vücut (manuel, tekrar) ─┐ │
│ │ Kilo:[___]kg Yağ:[__]%   │ │
│ │ → BMI 22.4  BMR 1730     │ │
│ │ → TDEE 2680 (=kalori hedefi)│ │
│ └──────────────────────────┘ │
│ ┌─ Çekilen (sensör) ───────┐ │
│ │ Nabız ♥ gün74 / uyku58   │ │
│ │ Uyku  7s20d ●●●○ düzen:iyi│ │
│ │ VO2max 48 (iyi)          │ │
│ │ Adım  7.420   [↻ son sync]│ │
│ └──────────────────────────┘ │
└─────────────────────────────┘
```

- Profil tek seferlik (değiştirilebilir), `health_profile` singleton'a yazar.
- Vücut tekrarlayan (`body_log`); her kilo girişinde BMI→BMR→TDEE zinciri YENİDEN hesaplanır.
- **TDEE = günlük kalori hedefi** → Sport kalori sparkline rengini besler (snapshot, §11).
- Çekilen blok salt-okunur; `HealthRepository`'den (§9). Veri yoksa "—" + "Bağla" CTA.

### Kabul Kriterleri (CR3-P3, fetch hariç)
- [ ] Kilo değişince BMI/BMR/TDEE anında güncelleniyor (formül birim testleri §10).
- [ ] Profil eksikse hesaplar "—" ve uyarı; crash yok.
- [ ] Sensör bloğu fetch yokken placeholder gösteriyor.

---

## 6. Sport (sekme 4)

İki bölüm: programlar + kalori takibi. Sıra: Programs → Programs sparkline → Kalori sparkline → kalori girişi.

```
┌─ SPORT ─────────────────────┐
│ ▼ My Programs               │
│   • Program 1               │
│   • Program 2        [ ADD ]│
│ ┌ Sparkline: Programs ─────┐ │
│ │ ▁▃▅▂▇▁▄ (CR1-C sürekli)  │ │ ← yüksekliğe dokun → o günün program_id'si
│ └──────────────────────────┘ │
│ ┌ Sparkline: Kalori ───────┐ │
│ │ neon yeşil çizgi + renk   │ │ ← gün rengi: yeşil/sarı/kırmızı (§11)
│ └──────────────────────────┘ │
│ ┌─ Kalori girişi ──────────┐ │
│ │ Öğün:[Breakfast ▼]       │ │
│ │ Kalori:[_____] Type:[▼]  │ │
│ │  Food/FastFood/Drink/    │ │
│ │  Veg&Fruit  [+new type]  │ │
│ │                   [ ADD ]│ │
│ └──────────────────────────┘ │
└─────────────────────────────┘
```

### 6.1 New Program akışı

```
┌─ NEW PROGRAM ───────────────┐
│ Program adı:[____________]  │
│ ┌─ Hareket bloğu ──────────┐ │
│ │ Name:[______] ▼kayıtlı   │ │ ← basınca dropdown: saved_exercise_titles
│ │   ▼ Bench Press / Squat… │ │   (yoksa boş + "+yeni")
│ │ Set:[15x3] Duration:[__] │ │
│ └──────────────────────────┘ │
│        [ + blok ekle ]      │
│  --- Rest ---               │
│ (uzun dokun → çoklu seçim)  │
│ [✓] Squat 15x3              │
│ [✓] Lunge 12x3 → (3 times)  │ ← süperset: birlikte kaç tekrar
│                  [ SAVE ]   │
└─────────────────────────────┘
```

### 6.2 Giriş davranış kuralları

**Hareket validasyonu:**
- `Name` ZORUNLU.
- `Set` ve `Duration`'dan **EN AZ BİRİ** dolu olmalı; girilmeyen `NULL`.
- Name kutusuna basınca alan açılır, `saved_exercise_titles`'tan dropdown gelir.
- Her yeni name `INSERT OR IGNORE` ile kaydedilir → bir daha aratmadan çıkar.

**Çoklu hareket / süperset:**
- Bir maddeye uzun dokun → seçim modu → birkaç hareket seç → "kaç kez beraber tekrar"
  sorusu (örn. 3 times) → grup `superset_group` ile işaretlenip kaydedilir.

**Kalori girişi:**
- Öğün dropdown (Breakfast/Lunch/Dinner) → kalori input → Type dropdown
  (`saved_food_types`: Food/FastFood/Drink/Veg&Fruit + kullanıcı eklediği).
- Her kayıt ve her yeni type `INSERT OR IGNORE` → sonraki sefer dropdown'da.

### Kabul Kriterleri (CR3-P5)
- [ ] Name boşken SAVE engellenir; Set+Duration ikisi de boşken blok eklenmez.
- [ ] Yeni exercise title bir sonraki açılışta dropdown'da.
- [ ] Süperset: 2 hareket seç + "3 times" → tek grup olarak kayıt, geri okunabiliyor.
- [ ] Yeni food type kaydediliyor ve tekrar çıkıyor.

---

## 7. Analysis (sekme 1) — DEĞİŞMEZ

Bu sekme spec §6.3 + CR1-A'nın BİREBİR aynısıdır. **Kod dokunulmaz**, yalnızca:
- Eski `PageView` index'inden yeni 5-sekme yapısında index 1'e taşınır (sarmalayıcı değişir,
  içerik aynı).
- Tema (CR1-B) token'ları zaten tüm uygulamada ortak; Analysis görünümü token'lara uyum
  sağlar ama ısı haritası bucket renkleri DEĞİŞMEZ (spec §5.2, CR1-B kuralı).
- Döküm: özyinelemeli toggle (CR1-A) — Money satırı salt-okunur (Money sekmesine atlamaz, §4).

### Kabul Kriterleri
- [ ] Analysis içeriği golden/widget testte CR-3 öncesi ile aynı (heatmap + döküm).

---

# [Technic]

## 8. Veri Kaynağı Haritası

| Veri | Kaynak | Yöntem |
|---|---|---|
| Yaş, cinsiyet, boy, aktivite | Manuel (profil, 1 kez) | Form → `health_profile` |
| Kilo, vücut yağı % | Manuel (tekrar) | Form → `body_log` |
| BMI, BMR, TDEE | Hesap | §10 formülleri |
| Alınan kalori | Manuel | Form → `calorie_entries` |
| Para işlemleri | Manuel | Form → `transactions` |
| Program / hareketler | Manuel | Form → `programs`, `program_exercises` |
| Daily Check-in (9 metrik) | Manuel | Form → `entries` (mevcut) |
| Nabız (gün+uyku) | Fetch | GT5 → sağlık köprüsü |
| Uyku (süre+evre+düzen) | Fetch | GT5 → sağlık köprüsü |
| VO2max | Fetch (yedek: hesap) | GT5; yoksa §10 formülü |
| Adım, aktif kalori | Fetch | S24 → Health Connect |

## 9. Sağlık Köprüsü (HealthRepository)

UI kaynağı BİLMEZ — her şey tek `HealthRepository` arkasında soyutlanır.

**Üç olası kaynak, öncelik sırası:**
1. **Health Connect** (`health` Flutter paketi) — S24 adımı/kalori native buradadır.
   On-device API; backend GEREKTİRMEZ → local-first korunur. **Prototip için birincil yol.**
2. **GT5 (Huawei) → Health Connect köprüsü** — "Health Sync" gibi bir tüketici uygulaması
   GT5 verisini Health Connect'e yazar; biz oradan okuruz. Yine on-device.
3. **Huawei Health Kit (doğrudan)** — OAuth + Huawei bulut + geliştirici onayı; token exchange
   için potansiyel sunucu ihtiyacı → local-first'ü bozar. **Şimdilik KAPSAM DIŞI**, sadece
   arayüz `HealthSource` enum'unda yer tutar.
4. **Aggregator (Spike/Terra/Rook)** — tek API ama sağlık verisini ÜÇÜNCÜ TARAFA gönderir
   (gizlilik bedeli, §14). Sadece kullanıcı açıkça seçerse.

**Pull modeli:** açılışta + günde birkaç kez arka planda (`workmanager`) `last_sync`
damgasından sonrasını çek → `health_samples`'a yaz. Manuel veri ağ beklemez.

```dart
abstract class HealthRepository {
  Future<DailyVitals?> vitalsFor(DateTime day); // rhr, hrDay, sleepMin, sleepScore, steps, vo2max
  Future<void> sync({DateTime? since});
  Stream<SyncStatus> get status;
}
// İlk implementasyon: HealthConnectRepository (paket: health)
```

## 10. Hesaplamalar

```
BMI  = kilo / (boy_m)^2
BMR (Mifflin-St Jeor):
  E: 10*kilo + 6.25*boy_cm - 5*yas + 5
  K: 10*kilo + 6.25*boy_cm - 5*yas - 161
TDEE_static  = BMR * aktivite_katsayisi        ← RENKLENDİRME HEDEFİ (snapshot, §11)
TDEE_dynamic = BMR + aktif_kalori(GT5)         ← "canlı harcama" göstergesi (ayrı)
VO2max (yedek) = 15.3 * (208 - 0.7*yas) / RHR
```

Aktivite katsayıları: sedentary 1.2, light 1.375, moderate 1.55, active 1.725, very 1.9.
Kilo değişince zincir yeniden hesaplanır.

> **Düzeltme (kaynak dokümandaki mantık hatası):** kaynak `TDEE = BMR + aktif + 0.10*alınan_kalori`
> diyordu. Bu, renklendirme hedefini ALINAN kaloriye bağlar → döngüsel: çok yiyince hedef
> yükselir, kırmızıya hiç düşmezsin. Renklendirme için **TDEE_static** kullanılır (alınan
> kaloriden bağımsız). `0.10*alınan` terimi yalnızca "canlı harcama" göstergesinde kalabilir,
> renklendirmeye GİRMEZ.

## 11. Kalori Sparkline — Hedef Versiyonlama (kritik)

Hedef zamanla değişir; **eski barlar yeniden renklenmemeli.** Çözüm: her güne o gün
geçerli hedefin SNAPSHOT'unu yaz.

```
Günün ilk kalori girişinde:
  target_snapshot[d] = o an aktif TDEE_static   ← BİR KEZ yazılır, donar
Her girişte:
  intake[d] += kalori
Renk (yalnızca intake vs DONMUŞ snapshot, aynı gün):
  intake < snapshot - 100 → SARI
  intake > snapshot + 100 → KIRMIZI
  aksi               → YEŞİL
Gün dönünce snapshot dokunulmaz. Hedef 2600→3000 olursa sadece YENİ günler 3000'e göre.
```

Veri modeli: `calorie_day { date PK, intake, target_snapshot, color }`.
- O gün hiç giriş yoksa snapshot YOK → bar nötr/taban (renksiz).
- `color` hesaplanır ve saklanır; sonradan TEKRAR hesaplanmaz.

Programs sparkline ayrı: `program_log { date, program_id, volume }`; yüksekliğe dokun → program_id.

## 12. Autocomplete Tabloları

- `saved_exercise_titles { name PK }` — hareket isimleri; `INSERT OR IGNORE`.
- `saved_food_types { name PK, is_builtin }` — seed: Food, FastFood, Drink, Veg&Fruit;
  kullanıcı ekler; `INSERT OR IGNORE`.
Name/Type kutusuna basınca bu tablodan dropdown doldurulur.

## 13. Yeni DB Tabloları (mevcut şemaya EK)

```sql
CREATE TABLE health_profile (            -- singleton (id=1)
  id INTEGER PRIMARY KEY CHECK (id=1),
  birth_date TEXT, sex TEXT,             -- 'M'|'F'
  height_cm REAL, activity_level TEXT,   -- 'sedentary'..'very'
  updated_at INTEGER NOT NULL
);
CREATE TABLE body_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL, weight_kg REAL, body_fat_pct REAL,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
  UNIQUE(date)
);
CREATE TABLE calorie_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL, meal TEXT,         -- 'breakfast'|'lunch'|'dinner'
  kcal REAL NOT NULL CHECK (kcal>=0),
  type TEXT NOT NULL,                    -- saved_food_types.name
  created_at INTEGER NOT NULL
);
CREATE TABLE calorie_day (               -- türetilmiş + donmuş renk
  date TEXT PRIMARY KEY,
  intake REAL NOT NULL DEFAULT 0,
  target_snapshot REAL,                  -- ilk girişte donar
  color TEXT                             -- 'green'|'yellow'|'red'|NULL
);
CREATE TABLE saved_food_types ( name TEXT PRIMARY KEY, is_builtin INTEGER NOT NULL DEFAULT 0 );
CREATE TABLE programs (
  id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
  created_at INTEGER NOT NULL, sort_order INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE program_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  program_id INTEGER NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  name TEXT NOT NULL,                    -- saved_exercise_titles.name
  sets TEXT, duration TEXT,              -- en az biri NOT NULL (uygulama katmanı zorlar)
  rest_after INTEGER NOT NULL DEFAULT 0, -- 1 → bu bloktan sonra Rest
  superset_group INTEGER,               -- aynı grup = süperset; NULL = tekil
  superset_rounds INTEGER,              -- "3 times"
  sort_order INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE saved_exercise_titles ( name TEXT PRIMARY KEY );
CREATE TABLE program_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL, program_id INTEGER NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  volume REAL NOT NULL DEFAULT 0
);
CREATE TABLE health_samples (            -- fetch edilen günlük özet
  date TEXT NOT NULL, kind TEXT NOT NULL,-- 'rhr'|'hr_day'|'sleep_min'|'sleep_score'|'steps'|'vo2max'|'active_kcal'
  value REAL, value_text TEXT,           -- value_text: sleep_stages JSON gibi
  source TEXT NOT NULL,                  -- 'health_connect'|'huawei'|'manual'
  fetched_at INTEGER NOT NULL,
  PRIMARY KEY (date, kind)
);
CREATE TABLE sync_state ( source TEXT PRIMARY KEY, last_sync INTEGER );
```

## 14. Güvenlik (zorunlu — sağlık+finans hassas veri)

1. **SQLCipher** (spec §11 devam) — sağlık ve para verisi at-rest şifreli.
2. **OAuth/Health token'ları** `flutter_secure_storage`/Keystore'da; ASLA SharedPreferences
   düz metinde, ASLA koda gömülü.
3. **EN SIK SIZINTI — log/analytics:** kalori, kilo, nabız, mood, harcama gibi değerleri
   `log()`, `print()`, crash-reporter veya analytics event'ine ASLA düşürme.
   - Kırılgan: `analytics.log("calorie", value)` / `print("weight=$kg")`
   - Güvenli: yalnızca olay TÜRÜ ("calorie_added"), değer YOK. Hata mesajlarında ham değer yok.
4. **Aggregator kullanılırsa** sağlık verisi üçüncü tarafa gider — kullanıcıya açık onay
   diyaloğu + Settings'te kalıcı uyarı. Varsayılan: Health Connect (on-device, paylaşım yok).
5. **FLAG_SECURE** opsiyonu Health ve Money sekmelerinde (Settings, varsayılan kapalı) —
   ekran görüntüsü/son uygulamalar önizlemesinde hassas veri sızmasın.
6. **Buluta senkron zorunlu DEĞİL** → yapma. İleride yapılırsa uçtan uca şifreli; ham sağlık
   verisi sunucuda düz tutulmaz.
7. **Parametreli sorgular** (spec §11/3) — yeni serbest metin alanları (exercise name, food
   type, note) da string-interpolation'sız yazılır.

## 15. Depolama + Senkron

- **Local-first** korunur: tüm manuel + türetilmiş veri anında yerel DB'ye; hesaplar
  (BMR/TDEE/renk) yazma anında türetilir, ağ beklemez.
- **Sensör verisi: periyodik pull** — açılışta + günde birkaç kez `workmanager` ile
  Health Connect'ten `last_sync` sonrasını çek → `health_samples` upsert → `sync_state` güncelle.
- Hesaplanan kalori rengi YAZMA anında donar (§11), okuma anında değil.

---

## 16. Build Fazları + Branch Planı

| Faz | Branch | İçerik | Bağımlılık |
|---|---|---|---|
| CR3-P0 | `cr3-p0-nav` | 5-sekme PageView+BottomNav, Main default, eski giriş→Main Daily Check-in, Analysis→index1 (içerik aynı), Health/Sport/Money stub | CR1-B token'ları önce |
| CR3-P1 | `cr3-p1-main` | Main dashboard özet kartları + hızlı para + bakiye + Daily Check-in entegrasyonu | P0 |
| CR3-P2 | `cr3-p2-money` | Money iç nav (Overview/İşlemler/Cat), donut, işlem listesi, kategori yönetimi, gesture-safe grafik | P0 |
| CR3-P3 | `cr3-p3-health-calc` | Health profil+vücut+hesap motoru (BMI/BMR/TDEE/VO2max), sensör placeholder | P0 |
| CR3-P4 | `cr3-p4-health-bridge` | HealthRepository + Health Connect (`health` pkg) + pull sync + last_sync | P3 |
| CR3-P5 | `cr3-p5-sport` | Programs, New Program (blok/süperset/validasyon), kalori girişi, autocomplete tabloları | P0 |
| CR3-P6 | `cr3-p6-sport-spark` | Programs + kalori sparkline (CR1-C motoru) + kalori hedef snapshot versiyonlama | P5, P3 |
| CR3-P7 | `cr3-p7-polish-sec` | Güvenlik denetimi (log sızıntısı taraması, FLAG_SECURE, secure storage), boş durumlar, perf | tümü |

**CR1-B (tema) bu CR'den ÖNCE veya P0 ile birlikte** — yeni sekmeler token'larla doğar.

## 17. Açık Noktalar

| # | Konu | Varsayılan | Onay |
|---|---|---|---|
| 1 | Daily Check-in Main'de mi (§1.1) | Evet, Main'de | **Kullanıcı onayı** |
| 2 | Sport-dk metriği vs Sport sekmesi ayrı mı (§1.2) | Ayrı | **Kullanıcı onayı** |
| 3 | TDEE renklendirme hedefi static mi (§10 düzeltme) | TDEE_static | Onaylandı varsay |
| 4 | Huawei Health Kit doğrudan entegrasyon | Şimdilik kapsam dışı, Health Connect köprüsü | Düşük öncelik |
| 5 | Sabah sözleri dili (önceki açık nokta) | TR varsayılan | Bekliyor |

## 18. Claude Code Promptu

```
/docs/daily-tracker-spec.md, cr1.md, cr2.md, cr3.md dosyalarını oku.
Analysis sayfasına DOKUNMA — yalnızca yeni 5-sekme yapısında index 1'e taşı, içerik aynı.
CR3-P0'dan başla, her faz kendi branch'inde (Bölüm 16), kabul kriterleri karşılanmadan merge yok.
CR1-B token'ları yoksa önce onu kur. Sağlık/finans değerlerini ASLA log/analytics'e yazma (Bölüm 14).
Kalori rengi yazma anında snapshot'la (Bölüm 11). flutter analyze sıfır uyarı.
```

---
*CR-3, 2026-06-12. Analysis korunur; geri kalan uygulanır. Açık Nokta #1 ve #2 onayı beklenir.*
