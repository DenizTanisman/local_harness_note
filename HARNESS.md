# local_harness_not — "Not"

Feature app of the Local Harness split (contract: [docs/HUB_CONTRACT.md](docs/HUB_CONTRACT.md)).
Split from `Takip Uygulaması Android/daily_tracker` on 2026-10-04.

| | |
|---|---|
| Role | feature |
| Label | Not |
| applicationId | `dev.deniz.local_harness_not` |
| Hub authority | `dev.deniz.local_harness_not.hub` (`HubProvider`, signature permission `dev.deniz.local_harness.permission.HUB`) |
| Snapshot schema | 1 |
| Reads peers | `program` (screen time → Instagram auto-fill) |

## What it does

- **Main — Daily Check-in** (spec §6.2): metric tree cards (int / text / int+text /
  checkbox / composite), notes, drag-to-group, ADD sheet, past-day entry via the date bar.
- **Analysis**: monthly heatmap, daily breakdown tree, calendar row, metric detail page
  with the continuous sparkline.
- **Notifications**: morning quote (TR/EN pools, editable) and the evening
  "Time to fill in your day" reminder with the missing-card count.
- **Settings**: notification times, quotes, FLAG_SECURE, Instagram auto-fill toggle,
  heatmap bucket editor, CSV/Excel export + entries import, encrypted weekly backup
  (`local_harness_not_*.dtbak`: entries + metrics + settings).

## Database

Encrypted SQLite (sqlite3mc), file `local_harness_not.db`, schema v1 (fresh install):
`metrics`, `metric_options`, `entries` (with `value_source` manual/auto), `entry_options`,
`app_settings`. Money, Health, Sport and screen-time tables live in the Para / Program apps.

## Hub snapshot (`not.data`)

- `checkin`: `{filled, total, missing[]}` over top-level cards (a composite is filled
  when any child is).
- `today`: every metric with an entry today, tree order:
  `{key, title, unit, value, text, options[]}`.

Built by `buildHubSnapshot(db)` in `lib/core/hub_snapshot_publisher.dart`; published at
startup, ~1.5 s after DB writes, and on `AppLifecycleState.paused`.

## Instagram auto-fill

On startup and on resume, `InstagramAutofill` (`lib/features/home/instagram_autofill.dart`)
reads the Program snapshot (`HubBridge.readPeerSnapshot('program')`), takes
`data.screenTime.days[].apps[]` rows with `package == com.instagram.android` and writes
those minutes with `value_source = 'auto'`. Manual edits always win; the setting
`autofill_instagram = false` disables it; a missing Program app is a silent no-op.

## Dev

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after tables.dart changes
flutter analyze && flutter test
```
