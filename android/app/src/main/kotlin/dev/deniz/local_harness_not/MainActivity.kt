package dev.deniz.local_harness_not

import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.file.Files
import java.nio.file.StandardCopyOption

class MainActivity : FlutterActivity() {
    private var systemChannel: MethodChannel? = null

    /** Share-sheet text or widget tap that launched the app, until Dart takes it. */
    private var launchIntent: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        launchIntent = describe(intent)

        // Share sheet / home-screen widget / battery exemption (spec §7, §8).
        systemChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "local_harness_not/system")
            .apply {
                setMethodCallHandler { call, result ->
                    when (call.method) {
                        "takeLaunchIntent" -> {
                            result.success(launchIntent)
                            launchIntent = null
                        }
                        "isIgnoringBatteryOptimizations" -> {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            result.success(pm.isIgnoringBatteryOptimizations(packageName))
                        }
                        "requestIgnoreBatteryOptimizations" -> {
                            try {
                                startActivity(
                                    Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                                        .setData(Uri.parse("package:$packageName"))
                                )
                            } catch (e: Exception) {
                                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                            }
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                }
            }
        // FLAG_SECURE toggle (spec §11.6).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "local_harness_not/secure_window")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(null)
                    }
                    "disable" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Local Harness hub channel (docs/HUB_CONTRACT.md §3). File and IPC
        // work runs off the main thread; results are posted back on it.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "local_harness/hub")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "publishSnapshot" -> {
                        val json = call.arguments as? String
                        if (json == null) {
                            result.error("bad_args", "publishSnapshot expects a JSON string", null)
                        } else {
                            Thread {
                                try {
                                    writeSnapshotAtomically(json)
                                    runOnUiThread { result.success(null) }
                                } catch (e: Exception) {
                                    runOnUiThread { result.error("io", e.message, null) }
                                }
                            }.start()
                        }
                    }
                    "readPeerSnapshot" -> {
                        val app = appArg(call.arguments)
                        Thread {
                            val json = app?.let { readPeerSnapshot(it) }
                            runOnUiThread { result.success(json) }
                        }.start()
                    }
                    "isInstalled" -> {
                        val app = appArg(call.arguments)
                        result.success(app != null && isInstalled(app))
                    }
                    "launchApp" -> {
                        val app = appArg(call.arguments)
                        val route = (call.arguments as? Map<*, *>)?.get("route") as? String
                        result.success(app != null && launchApp(app, route))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        describe(intent)?.let { systemChannel?.invokeMethod("onIntent", it) }
    }

    /** What an incoming intent asks for, as the map the Dart side parses. */
    private fun describe(intent: Intent?): Map<String, String>? = when (intent?.action) {
        NEW_NOTE_ACTION -> mapOf("action" to "new_note")
        Intent.ACTION_SEND -> {
            val text = listOfNotNull(
                intent.getStringExtra(Intent.EXTRA_SUBJECT),
                intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString(),
            ).filter { it.isNotBlank() }.distinct().joinToString("\n")
            if (text.isBlank()) null else mapOf("action" to "share", "text" to text)
        }
        else -> null
    }

    /** App id from either a bare String argument or a map {"app": ...}. */
    private fun appArg(arguments: Any?): String? = when (arguments) {
        is String -> arguments
        is Map<*, *> -> arguments["app"] as? String
        else -> null
    }

    /** Serializes publishes: two overlapping writers must not share the tmp file. */
    private val snapshotLock = Any()

    /** tmp file + atomic rename, so HubProvider never serves a half-written file. */
    private fun writeSnapshotAtomically(json: String) = synchronized(snapshotLock) {
        val target = File(filesDir, HubProvider.SNAPSHOT_FILE)
        val tmp = File(filesDir, HubProvider.SNAPSHOT_FILE + ".tmp")
        tmp.writeText(json, Charsets.UTF_8)
        Files.move(
            tmp.toPath(),
            target.toPath(),
            StandardCopyOption.REPLACE_EXISTING,
            StandardCopyOption.ATOMIC_MOVE
        )
    }

    /** A peer's snapshot JSON, or null when not installed / not permitted / never published. */
    private fun readPeerSnapshot(app: String): String? = try {
        contentResolver
            .call(Uri.parse("content://${peerPackage(app)}.hub"), "snapshot", null, null)
            ?.getString("json")
    } catch (e: Exception) {
        null
    }

    private fun isInstalled(app: String): Boolean = try {
        packageManager.getPackageInfo(peerPackage(app), 0)
        true
    } catch (e: Exception) {
        false
    }

    private fun launchApp(app: String, route: String?): Boolean {
        val intent = packageManager.getLaunchIntentForPackage(peerPackage(app)) ?: return false
        if (route != null) intent.putExtra("lh_route", route)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun peerPackage(app: String) = "dev.deniz.local_harness_$app"

    companion object {
        const val NEW_NOTE_ACTION = "dev.deniz.local_harness_not.NEW_NOTE"
    }
}
