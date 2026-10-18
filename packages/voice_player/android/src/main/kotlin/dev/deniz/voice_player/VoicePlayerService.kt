package dev.deniz.voice_player

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.IBinder

/**
 * Plays one clip as a foreground media service with a "Durdur" action and
 * goes away when the clip ends. One player per process: a new clip
 * replaces the current one.
 */
class VoicePlayerService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_PLAY -> {
                val path = intent.getStringExtra(EXTRA_PATH)
                val title = intent.getStringExtra(EXTRA_TITLE).orEmpty()
                startForeground(
                    NOTIFICATION_ID,
                    notification(title),
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
                )
                if (path == null || !start(this, path) { finish() }) finish()
            }
            else -> finish()
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        release(this)
        super.onDestroy()
    }

    private fun finish() {
        release(this)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun notification(title: String): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(CHANNEL) == null) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL, "Sesli notlar", NotificationManager.IMPORTANCE_LOW)
                    .apply { description = "Çalan sesli not" },
            )
        }
        val stop = PendingIntent.getService(
            this,
            0,
            Intent(this, VoicePlayerService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return Notification.Builder(this, CHANNEL)
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode_off)
            .setContentTitle(if (title.isBlank()) "🔊 Sesli not" else "🔊 $title")
            .setContentText("Çalınıyor")
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_TRANSPORT)
            .addAction(
                Notification.Action.Builder(null, "Durdur", stop).build(),
            )
            .build()
    }

    companion object {
        const val ACTION_PLAY = "dev.deniz.voice_player.PLAY"
        const val ACTION_STOP = "dev.deniz.voice_player.STOP"
        const val EXTRA_PATH = "path"
        const val EXTRA_TITLE = "title"
        private const val CHANNEL = "voice_player"
        private const val NOTIFICATION_ID = 4343

        private var player: MediaPlayer? = null
        private var current: String? = null
        private var focus: AudioFocusRequest? = null

        private val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
            .build()

        @Synchronized
        fun start(context: Context, path: String, onDone: () -> Unit): Boolean {
            release(context)
            return try {
                val audio = context.getSystemService(AudioManager::class.java)
                focus = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                    .setAudioAttributes(attributes)
                    .build()
                    .also { audio.requestAudioFocus(it) }
                player = MediaPlayer().apply {
                    setAudioAttributes(attributes)
                    setDataSource(path)
                    setOnCompletionListener { onDone() }
                    setOnErrorListener { _, _, _ -> onDone(); true }
                    prepare()
                    start()
                }
                current = path
                true
            } catch (e: Exception) {
                release(context)
                false
            }
        }

        @Synchronized
        fun release(context: Context) {
            player?.release()
            player = null
            current = null
            focus?.let { context.getSystemService(AudioManager::class.java).abandonAudioFocusRequest(it) }
            focus = null
        }

        fun playWithoutService(context: Context, path: String): Boolean =
            start(context.applicationContext, path) { release(context.applicationContext) }

        fun stopAll(context: Context) {
            release(context)
            context.stopService(Intent(context, VoicePlayerService::class.java))
        }

        @Synchronized
        fun state(): Map<String, Any?> {
            val p = player
            return mapOf(
                "path" to current,
                "playing" to (p?.isPlaying == true),
                "position" to (p?.currentPosition ?: 0),
                "duration" to (p?.duration ?: 0),
            )
        }
    }
}
