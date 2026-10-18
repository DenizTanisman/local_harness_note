package dev.deniz.local_harness_not

import android.app.Activity
import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.drawable.Icon
import android.os.Bundle
import android.util.Rational
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.VideoView

/**
 * A reminder's video in a floating picture-in-picture window ("🎬 İzle"):
 * it plays over whatever app is open, can be dragged, enlarged or closed,
 * and the Not app itself stays in the background.
 */
class VideoPipActivity : Activity() {
    private lateinit var video: VideoView
    private var params: PictureInPictureParams.Builder? = null
    private var ended = false

    private val controls = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != ACTION_TOGGLE) return
            if (video.isPlaying) {
                video.pause()
            } else {
                if (ended) video.seekTo(0)
                ended = false
                video.start()
            }
            updateActions()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        video = VideoView(this)
        setContentView(
            FrameLayout(this).apply {
                setBackgroundColor(Color.BLACK)
                addView(
                    video,
                    FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        Gravity.CENTER,
                    ),
                )
            },
        )
        registerReceiver(controls, IntentFilter(ACTION_TOGGLE), RECEIVER_NOT_EXPORTED)
        play(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        play(intent)
    }

    private fun play(intent: Intent) {
        val path = intent.getStringExtra(EXTRA_PATH) ?: return finish()
        ended = false
        video.setOnPreparedListener { player ->
            val w = player.videoWidth
            val h = player.videoHeight
            // PiP accepts 1:2.39 … 2.39:1.
            val ratio = if (w > 0 && h > 0) {
                val r = w.toDouble() / h
                when {
                    r > 2.39 -> Rational(239, 100)
                    r < 1 / 2.39 -> Rational(100, 239)
                    else -> Rational(w, h)
                }
            } else {
                Rational(16, 9)
            }
            params = PictureInPictureParams.Builder().setAspectRatio(ratio)
            updateActions()
            video.start()
            if (!isInPictureInPictureMode) enterPictureInPictureMode(params!!.build())
        }
        video.setOnCompletionListener {
            ended = true
            updateActions()
        }
        video.setOnErrorListener { _, _, _ -> finish(); true }
        video.setVideoPath(path)
    }

    /** One button in the PiP window: play / pause (replay at the end). */
    private fun updateActions() {
        val builder = params ?: return
        val playing = video.isPlaying
        val toggle = PendingIntent.getBroadcast(
            this,
            0,
            Intent(ACTION_TOGGLE).setPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val icon = Icon.createWithResource(
            this,
            if (playing) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play,
        )
        val label = if (playing) "Duraklat" else "Oynat"
        builder.setActions(listOf(RemoteAction(icon, label, label, toggle)))
        setPictureInPictureParams(builder.build())
    }

    override fun onPictureInPictureModeChanged(inPip: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(inPip, newConfig)
        updateActions()
    }

    override fun onStop() {
        super.onStop()
        // The PiP window was closed (✕ or swiped away): stop for good.
        if (!isChangingConfigurations) finish()
    }

    override fun onDestroy() {
        unregisterReceiver(controls)
        video.stopPlayback()
        super.onDestroy()
    }

    companion object {
        const val EXTRA_PATH = "path"
        const val EXTRA_TITLE = "title"
        private const val ACTION_TOGGLE = "dev.deniz.local_harness_not.PIP_TOGGLE"
    }
}
