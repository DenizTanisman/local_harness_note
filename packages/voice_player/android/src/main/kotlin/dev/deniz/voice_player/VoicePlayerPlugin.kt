package dev.deniz.voice_player

import android.content.Context
import android.content.Intent
import android.media.MediaMetadataRetriever
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** `voice_player`: play / stop / state / duration (lib/voice_player.dart). */
class VoicePlayerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "voice_player")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("bad_args", "path expected", null)
                    return
                }
                val intent = Intent(context, VoicePlayerService::class.java)
                    .setAction(VoicePlayerService.ACTION_PLAY)
                    .putExtra(VoicePlayerService.EXTRA_PATH, path)
                    .putExtra(VoicePlayerService.EXTRA_TITLE, call.argument<String>("title") ?: "")
                    .putExtra(VoicePlayerService.EXTRA_IMAGE, call.argument<String>("image"))
                try {
                    context.startForegroundService(intent)
                    result.success(true)
                } catch (e: Exception) {
                    // Not allowed to start a foreground service right now:
                    // play anyway, just without the service.
                    result.success(VoicePlayerService.playWithoutService(context, path))
                }
            }
            "stop" -> {
                VoicePlayerService.stopAll(context)
                result.success(null)
            }
            "state" -> result.success(VoicePlayerService.state())
            "duration" -> {
                val path = call.arguments as? String
                result.success(path?.let { durationMs(it) })
            }
            else -> result.notImplemented()
        }
    }

    private fun durationMs(path: String): Int? = try {
        MediaMetadataRetriever().use {
            it.setDataSource(path)
            it.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toIntOrNull()
        }
    } catch (e: Exception) {
        null
    }
}
