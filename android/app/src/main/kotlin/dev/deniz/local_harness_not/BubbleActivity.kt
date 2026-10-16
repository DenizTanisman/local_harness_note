package dev.deniz.local_harness_not

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** What the quick-note bubble shows when expanded: Dart's `bubbleMain`. */
class BubbleActivity : FlutterActivity() {
    override fun getDartEntrypointFunctionName(): String = "bubbleMain"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "local_harness_not/bubble")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Saved: confirm with a toast and fold the bubble so the
                    // user is back in the app they were using.
                    "savedAndCollapse" -> {
                        val title = call.arguments as? String
                        Toast.makeText(
                            applicationContext,
                            if (title.isNullOrBlank()) "Not kaydedildi" else "Not kaydedildi: $title",
                            Toast.LENGTH_SHORT
                        ).show()
                        moveTaskToBack(true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
