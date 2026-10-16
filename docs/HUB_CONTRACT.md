# Local Harness — Hub Contract v1

The Daily Tracker monolith was split into four independent Android apps under
`/Users/ismaildeniz/Projects/`:

| Folder | Dart package | applicationId | Label | Owns |
|---|---|---|---|---|
| local_harness_para | local_harness_para | dev.deniz.local_harness_para | Para | Money: transactions, categories, recurring, reports, search, upcoming, expense reminders |
| local_harness_not | local_harness_not | dev.deniz.local_harness_not | Not | Second brain: notes (search, tags, merge, versions), on-device Gemma, sequential reminder list, Claude access via MCP relay |
| local_harness_program | local_harness_program | dev.deniz.local_harness_program | Program | Sport (workout programs, program log, calories, saved foods/exercises), Health (profile, body log, Health Connect samples), Screen time (usage stats) |
| local_harness_hub | local_harness_hub | dev.deniz.local_harness_hub | Hub | No DB of its own. Reads the other three apps' snapshots, shows a combined dashboard, launches them. |

Every app is a fresh install with its own encrypted SQLite DB (sqlite3mc, key in
flutter_secure_storage). No app ever opens another app's DB. All apps are signed
with the same key (`~/.android/debug.keystore`), which is what makes the
signature-level permission below work.

## 1. Shared permission (ALL four manifests)

```xml
<permission
    android:name="dev.deniz.local_harness.permission.HUB"
    android:protectionLevel="signature"
    android:label="Local Harness hub access" />
<uses-permission android:name="dev.deniz.local_harness.permission.HUB" />
```

## 2. Feature apps (para, not, program): HubProvider

Kotlin class `dev.deniz.local_harness_<app>.HubProvider : ContentProvider`, declared as:

```xml
<provider
    android:name=".HubProvider"
    android:authorities="dev.deniz.local_harness_<app>.hub"
    android:exported="true"
    android:permission="dev.deniz.local_harness.permission.HUB" />
```

- `call(method = "ping")` → Bundle { "app": "<app>", "schema": 1 }
- `call(method = "snapshot")` → Bundle { "json": <contents of filesDir/hub_snapshot.json, or absent if never written> }
- `call()` must check the caller holds the permission:
  `context.checkCallingPermission(PERM) == PERMISSION_GRANTED`; otherwise throw SecurityException.
  (`android:permission` does not guard `call()` on all API levels, so this check is required.)
- query/insert/update/delete/getType return null / 0. onCreate returns true.

## 3. MethodChannel `local_harness/hub` (MainActivity, every app)

| method | args | result | who |
|---|---|---|---|
| publishSnapshot | String json | null. Writes filesDir/hub_snapshot.json atomically (tmp file + rename) | feature apps |
| readPeerSnapshot | String app ("para"/"not"/"program") | String? json. `contentResolver.call(Uri.parse("content://dev.deniz.local_harness_$app.hub"), "snapshot", null, null)?.getString("json")`; return null on any exception (not installed, SecurityException) | hub |
| isInstalled | String app | bool | hub |
| launchApp | String app, String? route | bool. `packageManager.getLaunchIntentForPackage(pkg)` + extra `lh_route`, FLAG_ACTIVITY_NEW_TASK | hub |

Package visibility (Android 11+): every app that reads peers declares
`<queries><package android:name="dev.deniz.local_harness_<peer>" /></queries>` for each peer it reads.

Dart side lives in `lib/core/hub_bridge.dart` (copied per app, same API):

```dart
class HubBridge {
  static const channel = MethodChannel('local_harness/hub');
  static Future<void> publishSnapshot(Map<String, Object?> snapshot);
  static Future<Map<String, Object?>?> readPeerSnapshot(String app); // null-safe, swallows MissingPluginException/PlatformException
  static Future<bool> isInstalled(String app);
  static Future<bool> launchApp(String app, {String? route});
}
```

All bridge calls must be no-ops / return null in widget tests (catch MissingPluginException).

## 4. Snapshot JSON (schema 1)

```json
{
  "app": "para" | "not" | "program",
  "schema": 1,
  "generatedAt": "2026-10-04T12:30:00.000",
  "date": "2026-10-04",
  "headline": "one short human-readable line for the hub card",
  "data": { ...app specific, below... }
}
```

All numbers are plain JSON numbers; missing values are `null`; dates are `YYYY-MM-DD`.

**para.data**
```json
{
  "currency": "TL",
  "month": "2026-10",
  "monthIncome": 0, "monthOutcome": 0, "monthBalance": 0,
  "allTimeBalance": 0,
  "todayIncome": 0, "todayOutcome": 0,
  "recent": [ {"date": "...", "direction": "income|outcome", "amount": 0, "category": "...", "note": null} ],
  "upcoming": [ {"date": "...", "category": "...", "amount": 0, "direction": "outcome"} ]
}
```
`recent` = last 5 transactions; `upcoming` = next items from recurring rules within 30 days (empty list if not readily available).

**not.data** — schema **2** since 2026-10-16 (second brain, docs/second-brain-spec.md §10)
```json
{
  "notes": { "total": 0, "inbox": 0 },
  "nextReminder": { "title": "first line of the next reminder note", "at": "2026-10-16T14:00:00" }
}
```
`nextReminder` is `null` when the reminder list is empty; a private note's title is sent as `"🔒"`.
Schema 1 (`checkin`, `today`) is gone — the hub must read schema 2 for `not`.

**program.data**
```json
{
  "calories": { "intake": 0, "target": null, "color": "green|yellow|red|null" },
  "health": { "steps": null, "rhr": null, "sleepMin": null, "sleepScore": null, "activeKcal": null, "weightKg": null },
  "programs": [ {"id": 1, "name": "Push day"} ],
  "todayPrograms": [ {"name": "Push day", "volume": 0} ],
  "screenTime": {
    "todayTotalMin": null,
    "top": [ {"package": "com.instagram.android", "label": "Instagram", "min": 47} ],
    "days": [ {"date": "...", "totalMin": 0, "apps": [ {"package": "...", "label": "...", "min": 0} ]} ]
  }
}
```
`screenTime.days` = last 14 days (newest first).

## 5. When feature apps publish

`lib/core/hub_snapshot_publisher.dart` per app:
- once at startup (after the startup syncs in main.dart),
- debounced (~1.5 s) on `db.tableUpdates()` stream,
- on `AppLifecycleState.paused`.
Building the snapshot is a pure function of the DB (`Future<Map<String,Object?>> buildHubSnapshot(AppDatabase db, {DateTime? now})`) so it is unit-testable with an in-memory DB.

## 6. Per-folder harness manifest

Each folder root has `harness.json` (machine-readable, for the local agent harness) and
`HARNESS.md` (human-readable):

```json
{
  "name": "local_harness_para",
  "role": "feature" | "hub",
  "label": "Para",
  "applicationId": "dev.deniz.local_harness_para",
  "hubAuthority": "dev.deniz.local_harness_para.hub",
  "snapshotSchema": 1,
  "features": ["transactions", "..."],
  "dbTables": ["transactions", "..."],
  "readsPeers": [],
  "origin": "split from Takip Uygulaması Android/daily_tracker on 2026-10-04"
}
```
