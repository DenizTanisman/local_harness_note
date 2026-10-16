# local_harness_not — "Not"

Feature app of the Local Harness split (contract: [docs/HUB_CONTRACT.md](docs/HUB_CONTRACT.md)).
Since 2026-10-16 a minimal **second brain** — spec: [docs/second-brain-spec.md](docs/second-brain-spec.md).
The daily check-in it used to be is gone (`docs/daily-tracker-*.md` kept for reference).

| | |
|---|---|
| Role | feature |
| Label | Not |
| applicationId | `dev.deniz.local_harness_not` (minSdk 30) |
| Hub authority | `dev.deniz.local_harness_not.hub` (`HubProvider`, signature permission `dev.deniz.local_harness.permission.HUB`) |
| Snapshot schema | 2 |
| Reads peers | — |

## What it does

- **Notlar**: plain-text notes, `#tags`, search (FTS5 over Turkish-folded text: `isik` finds
  `ışık`), Gelen/Arşiv + tag chips, long-press multi-select → **merge** (undo) / remind /
  archive (auto-deleted 45 days after archiving), private 🔒 notes, versions.
- **✨ Gemma**: on-device Gemma 4 E2B (LiteRT-LM, `flutter_gemma`, CPU) runs the saved prompt
  on a note; the answer streams into an editable field; *Onayla* replaces the note and keeps
  the old text as a version. Leaving while it runs or before accepting asks "Emin misin?".
- **Hatırlatmalar**: an ordered list the notifications walk through (default 07:30 · 14:00 ·
  20:00, exact alarms via `USE_EXACT_ALARM`), looping at the end. Drag to reorder, swipe to
  remove.
- **Capture**: share sheet (`text/plain`) and the home-screen "+ Not" widget open a new note;
  the **quick-note bubble** (Android Bubbles API, `BubbleActivity` → Dart `bubbleMain`, own
  engine + DB connection) floats over every app: type, `#` suggestions, Kaydet; collapsing it
  saves what was typed; Kaydet saves, toasts and folds the bubble back to the app in use. Typing `#` anywhere suggests existing tags, most used first.
- **Claude (MCP)**: see below.
- **Settings**: reminder times, Gemma model + prompt, Claude pairing, FLAG_SECURE, encrypted
  weekly backup (`local_harness_not_*.dtbak`, notes + versions + reminders + settings) and
  restore.

## Database

Encrypted SQLite (sqlite3mc), file `local_harness_not.db`, schema v3 (`notes.archived_at`): `notes`, `note_tags`,
`note_versions`, `reminders`, `app_settings`, plus the FTS5 table `notes_fts`. The v1 → v2
upgrade drops the check-in tables.

## Claude connection

Notes never leave the phone. `worker/` is a Cloudflare Worker that is Claude's remote MCP
server: on a tool call it sends an FCM "wake" push, the app (`lib/features/relay/`) pulls
`GET /phone/work`, runs the tool on its DB (`McpTools`, private notes invisible, no delete)
and posts `POST /phone/result`. 25 s timeout; writes the phone missed are queued and applied
on the next wake / app open. Setup: `worker/setup.sh` (needs a Firebase project for FCM and a
Cloudflare login).

## Dev

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after tables.dart changes
flutter analyze && flutter test
flutter build apk --release --target-platform android-arm64
(cd worker && npm install && npm test)                     # relay e2e on wrangler dev
```
