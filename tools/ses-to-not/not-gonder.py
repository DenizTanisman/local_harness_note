#!/usr/bin/env python3
"""Ses parçası + Whisper dökümü → telefondaki Not'a hatırlatma.

Her ses dosyası için (yanında aynı adlı .txt dökümü ile):
  1. Döküm düz metne çevrilir.
  2. Claude (Claude Code CLI, bu Mac'te) kilit ifadelerin önüne/arkasına boş
     satır koyar (duzenle-prompt.md), Türkçe kısa bir başlık ve özet yazar.
     Kelimeler değişirse düzenleme kullanılmaz, düz metin gider.
  3. Not şu düzende gider: başlık / ses / düzenlenmiş metin / "Özet: …",
     ses ekiyle birlikte, Hatırlatmalar listesinin sonuna (aktarıcı /inbox →
     telefon uyanır, sesi indirir).

Kullanım:
  not-gonder.py ses1.mp3 [ses2.mp3 …]   tek tek ya da toplu
  not-gonder.py --deneme ses.mp3        göndermeden notu yazdırır
  not-gonder.py --liste-disi ses.mp3    not olur ama Hatırlatmalar'a girmez

Ayarlar: ~/Library/Application Support/ses-bolucu/not-relay.json
  {"url": "https://….workers.dev", "secret": "…"}   (chmod 600)
Kayıt: ~/Library/Logs/ses-bolucu-not.log
"""

from __future__ import annotations

import base64
import json
import os
import re
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

HOME = Path.home()
CONFIG = HOME / "Library/Application Support/ses-bolucu/not-relay.json"
LOG = HOME / "Library/Logs/ses-bolucu-not.log"
CLAUDE = os.environ.get("NOT_CLAUDE", str(HOME / ".local/bin/claude"))
MODEL = os.environ.get("NOT_MODEL", "sonnet")
PROMPT_FILE = Path(__file__).resolve().with_name("duzenle-prompt.md")
MIME = {".mp3": "audio/mpeg", ".wav": "audio/wav", ".m4a": "audio/mp4",
        ".aac": "audio/aac", ".ogg": "audio/ogg", ".opus": "audio/ogg",
        ".flac": "audio/flac", ".webm": "audio/webm"}

SCHEMA = {
    "type": "object",
    "properties": {
        "baslik": {"type": "string"},
        "metin": {"type": "string"},
        "ozet": {"type": "string"},
    },
    "required": ["baslik", "metin", "ozet"],
}

EXTRA = """
Ayrıca:
- "baslik": konuşmanın ana fikrini veren, en fazla 6 kelimelik Türkçe başlık
  (tırnak ve nokta yok).
- "ozet": ana mesajın 1-2 cümlelik Türkçe özeti.
- "metin": yukarıdaki kurallarla düzenlenmiş döküm (kendi dilinde).
Yalnızca bu üç alanlı JSON'u ver.
"""


def log(msg: str) -> None:
    line = time.strftime("%Y-%m-%d %H:%M:%S ") + msg
    print(line, file=sys.stderr)
    try:
        with LOG.open("a", encoding="utf-8") as f:
            f.write(line + "\n")
    except OSError:
        pass


def notify(title: str, text: str) -> None:
    script = f"display notification {json.dumps(text)} with title {json.dumps(title)}"
    subprocess.run(["osascript", "-e", script], check=False, capture_output=True)


def flat(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def ask_claude(transcript: str, retry_note: str = "") -> dict:
    """Formats with Claude Code in a minimal, tool-less session."""
    template = PROMPT_FILE.read_text(encoding="utf-8").split("---", 1)[1]
    prompt = template.replace("{{metin}}", transcript) + EXTRA + retry_note
    out = subprocess.run(
        [CLAUDE, "-p", "--tools", "", "--strict-mcp-config",
         "--setting-sources", "", "--no-session-persistence",
         "--system-prompt", "Metin düzenleyicisin; kurallara harfiyen uyarsın.",
         "--model", MODEL, "--output-format", "json",
         "--json-schema", json.dumps(SCHEMA)],
        input=prompt, capture_output=True, text=True, timeout=300,
    )
    if out.returncode != 0:
        raise RuntimeError(f"claude çıkış kodu {out.returncode}: {out.stderr[-300:]}")
    reply = json.loads(out.stdout)
    data = reply.get("structured_output") or json.loads(reply.get("result") or "{}")
    return {k: str(data.get(k, "")).strip() for k in ("baslik", "metin", "ozet")}


def tidy(transcript: str) -> dict:
    """Title, formatted text and summary; the words are checked to be the
    transcript's own, else the plain transcript is used."""
    data = ask_claude(transcript)
    if flat(data["metin"]) != transcript:
        log("düzenleme kelimeleri değiştirdi, bir kez daha deneniyor")
        data = ask_claude(transcript, "\nÖNEMLİ: Önceki denemede kelimeler değişti. "
                          "Metni harfi harfine koru, yalnızca satır sonu ekle.")
    if flat(data["metin"]) != transcript:
        log("düzenleme yine tutmadı; düz metin kullanılıyor")
        data["metin"] = transcript
    data["metin"] = re.sub(r"\n{3,}", "\n\n", data["metin"]).strip()
    return data


def note_text(data: dict, fallback_title: str) -> str:
    title = data["baslik"].strip().strip('".') or fallback_title
    parts = [title, data["metin"]]
    if data["ozet"]:
        parts.append("Özet: " + data["ozet"])
    # Title line first; Not shows the clip right under it.
    return parts[0] + "\n" + "\n\n".join(parts[1:])


def send(cfg: dict, text: str, audio: Path, reminders: bool) -> dict:
    body = json.dumps({
        "text": text,
        "reminders": reminders,
        "audio": {
            "name": audio.name,
            "mime": MIME.get(audio.suffix.lower(), "audio/mpeg"),
            "data": base64.b64encode(audio.read_bytes()).decode("ascii"),
        },
    }).encode("utf-8")
    req = urllib.request.Request(
        cfg["url"].rstrip("/") + "/inbox", data=body, method="POST",
        # Cloudflare turns away urllib's default User-Agent (403).
        headers={"authorization": "Bearer " + cfg["secret"],
                 "content-type": "application/json",
                 "user-agent": "ses-bolucu-not/1.0"},
    )
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read())


def transcript_of(audio: Path, wait: int) -> str | None:
    txt = audio.with_suffix(".txt")
    for _ in range(wait):
        if txt.exists() and txt.stat().st_size > 0:
            return flat(txt.read_text(encoding="utf-8", errors="replace"))
        time.sleep(1)
    return None


def main(argv: list[str]) -> int:
    dry = "--deneme" in argv
    reminders = "--liste-disi" not in argv
    files = [Path(a).expanduser() for a in argv if not a.startswith("--")]
    if not files:
        print(__doc__)
        return 2
    cfg = None if dry else json.loads(CONFIG.read_text(encoding="utf-8"))
    failed = 0
    for audio in files:
        try:
            if not audio.exists():
                raise FileNotFoundError(audio)
            transcript = transcript_of(audio, wait=600)
            if not transcript:
                raise RuntimeError("döküm (.txt) bulunamadı")
            data = tidy(transcript)
            text = note_text(data, audio.stem)
            if dry:
                print(f"--- {audio.name} ---\n{text}\n")
                continue
            r = send(cfg, text, audio, reminders)
            title = text.split("\n", 1)[0]
            log(f"gönderildi: {audio.name} → “{title}” ({'telefon uyandı' if r.get('woke') else 'kuyrukta'})")
            notify("Not'a gönderildi", title)
        except Exception as e:  # one bad file must not stop the batch
            failed += 1
            log(f"HATA {audio.name}: {e}")
            notify("Not'a gönderilemedi", f"{audio.name}: {e}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
