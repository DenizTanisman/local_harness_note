# voice_player

Local plugin of the Not app. A foreground `mediaPlayback` service plays one
audio file and shows a "🔊 … · Durdur" notification. Being a plugin, it is
registered in every Flutter engine — including the background engine that
handles a reminder notification's **▶ Oynat** action — so the clip plays
without opening the app.
