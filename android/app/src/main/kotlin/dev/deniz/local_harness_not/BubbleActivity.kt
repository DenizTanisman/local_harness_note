package dev.deniz.local_harness_not

import io.flutter.embedding.android.FlutterActivity

/** What the quick-note bubble shows when expanded: Dart's `bubbleMain`. */
class BubbleActivity : FlutterActivity() {
    override fun getDartEntrypointFunctionName(): String = "bubbleMain"
}
