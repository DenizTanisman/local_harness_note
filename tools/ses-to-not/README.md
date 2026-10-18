# Ses → Not

Ses Bölücü'den (claude.ai artifact) indirilen bir parçayı, Whisper dökümüyle
birlikte telefondaki Not'a **hatırlatma** olarak gönderir:

    Başlık (Türkçe, Claude yazar)
    [ses]
    Düzenlenmiş döküm — kilit ifadeler kendi paragraflarında
    Özet: … (Türkçe)

- `duzenle-prompt.md`: düzenleme kuralları (tek başına da kullanılabilir).
- `not-gonder.py`: döküm → Claude Code CLI (araçsız, sade oturum) → aktarıcının
  `/inbox` ucu → telefon uyanır, sesi indirir, notu Hatırlatmalar'ın sonuna
  ekler. Kelimeler değişirse düzenleme atılır, düz döküm gider.

Kurulum (bu Mac): iki dosya `~/Library/Application Support/ses-bolucu/` içine
kopyalanır; aynı yerde `not-relay.json` (`{"url", "secret"}`, `worker/pairing.json`
içinden, chmod 600) durur. `~/Library/Scripts/ses-bolucu-unzip.sh`, zip yorumunda
`not` geçen parçaları dökümden sonra bu script'e verir (Ses Bölücü'de
"Metin + telefona").

Elle / toplu: `not-gonder.py a.mp3 b.mp3 …` (yanlarında aynı adlı `.txt`),
`--deneme` göndermeden yazdırır, `--liste-disi` hatırlatmaya eklemez.
