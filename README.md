# local_harness_note — Not

A minimal second-brain Android app: quick notes, hierarchical `#tags`, on-device Gemma,
a sequential reminder list, a floating quick-note bubble, and Claude access through an
MCP relay. Notes stay on the phone.

## Download

**[⬇ Not 1.0.0 — APK (Android 11+, arm64)](https://github.com/DenizTanisman/local_harness_note/releases/latest/download/not-1.0.0-arm64.apk)**
· [all releases](https://github.com/DenizTanisman/local_harness_note/releases)

Install it on the phone (allow "install unknown apps" for your browser or file manager
when Android asks). The on-device Gemma model (~2.6 GB) downloads once from
*Ayarlar › Gemma*. The Claude connection needs your own Cloudflare + Firebase setup —
see [`worker/setup.sh`](worker/setup.sh).

## What's inside

- **Notlar** — plain-text notes, `#tags` with sub-tags (`#question-llm`), Turkish-aware
  search, categories menu with pixel icons, sorting, merge with undo, versions,
  private notes, tappable links that open in their own app (YouTube, Instagram, X …).
- **✨ Gemma** — runs on the phone: *Toparla*, *Hizala* (layout only, same words) or
  your own prompt; the answer is editable before it replaces the note.
- **Hatırlatmalar** — an ordered list delivered at 07:30 · 14:00 · 20:00, looping.
- **Capture** — share sheet, home-screen widget, floating quick-note bubble.
- **Claude (MCP)** — a Cloudflare Worker wakes the phone over FCM; tools run on the
  phone's own database (private notes are never sent, there is no delete tool).

Details: [HARNESS.md](HARNESS.md) · spec: [docs/second-brain-spec.md](docs/second-brain-spec.md)
· hub contract: [docs/HUB_CONTRACT.md](docs/HUB_CONTRACT.md).

## Build

```sh
flutter pub get
flutter build apk --release --target-platform android-arm64
(cd worker && npm install && npm test)   # relay end-to-end tests
```

Pixel category icons: [Streamline "Pixel"](https://www.streamlinehq.com/icons/pixel),
CC BY 4.0 — see [assets/icons/pixel/LICENSE.md](assets/icons/pixel/LICENSE.md).
