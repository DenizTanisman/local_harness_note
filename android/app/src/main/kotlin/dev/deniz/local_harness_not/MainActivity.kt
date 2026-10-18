package dev.deniz.local_harness_not

import android.content.ActivityNotFoundException
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.os.PowerManager
import android.provider.DocumentsContract
import android.provider.MediaStore
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

    /** Dart's pickLesson call, answered when the system picker returns. */
    private var pendingPick: MethodChannel.Result? = null

    /** Share-sheet text, lesson file or widget tap that launched the app, until Dart takes it. */
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
                        "openUrl" -> {
                            val url = call.arguments as? String
                            result.success(url != null && openUrl(url))
                        }
                        "showBubble" -> {
                            QuickNoteBubble.show(this@MainActivity)
                            result.success(QuickNoteBubble.status(this@MainActivity))
                        }
                        "hideBubble" -> {
                            QuickNoteBubble.hide(this@MainActivity)
                            result.success(null)
                        }
                        "bubbleStatus" -> result.success(QuickNoteBubble.status(this@MainActivity))
                        "pickLesson" -> {
                            pendingPick?.success(null)
                            pendingPick = result
                            pickLesson(call.arguments as? String)
                        }
                        "saveLessonFile", "openLessonFile" -> {
                            val args = call.arguments as? Map<*, *>
                            val name = args?.get("name") as? String
                            val html = args?.get("html") as? String
                            if (name == null || html == null) {
                                result.error("bad_args", "name and html expected", null)
                            } else {
                                val open = call.method == "openLessonFile"
                                Thread {
                                    val uri = try {
                                        saveToDocuments(name, html)
                                    } catch (e: Exception) {
                                        null
                                    }
                                    runOnUiThread {
                                        result.success(
                                            if (open) uri != null && openHtml(uri) else uri?.let { LESSON_DIR + name }
                                        )
                                    }
                                }.start()
                            }
                        }
                        "openBubbleSettings" -> {
                            QuickNoteBubble.openSettings(this@MainActivity)
                            result.success(null)
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

    /**
     * The system picker, opened straight in the folder lessons usually come
     * from ("download", "whatsapp", "lessons" — Not's own copies) and
     * showing HTML only; its search box searches that folder. No storage
     * permission needed.
     */
    private fun pickLesson(place: String?) {
        val folder = when (place) {
            "download" -> "Download"
            "whatsapp" -> "Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents"
            "lessons" -> LESSON_DIR.trimEnd('/')
            else -> null
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType("text/html")
            .putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("text/html", "application/xhtml+xml"))
        if (folder != null) {
            intent.putExtra(
                DocumentsContract.EXTRA_INITIAL_URI,
                DocumentsContract.buildDocumentUri(EXTERNAL_DOCS, "primary:$folder"),
            )
        }
        try {
            startActivityForResult(intent, PICK_LESSON)
        } catch (e: Exception) {
            pendingPick?.success(null)
            pendingPick = null
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_LESSON) return
        val result = pendingPick ?: return
        pendingPick = null
        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        Thread {
            val html = lessonFrom(uri)?.get("html")
            runOnUiThread { result.success(html ?: "") }
        }.start()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        describe(intent)?.let { systemChannel?.invokeMethod("onIntent", it) }
    }

    /** What an incoming intent asks for, as the map the Dart side parses. */
    private fun describe(intent: Intent?): Map<String, String>? = when (intent?.action) {
        NEW_NOTE_ACTION -> mapOf("action" to "new_note")
        Intent.ACTION_VIEW -> intent.data?.let { lessonFrom(it) }
        Intent.ACTION_SEND -> {
            @Suppress("DEPRECATION")
            val stream = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            if (stream != null && intent.type == "text/html") lessonFrom(stream) else shareText(intent)
        }
        else -> null
    }

    private fun shareText(intent: Intent): Map<String, String>? {
        val text = listOfNotNull(
            intent.getStringExtra(Intent.EXTRA_SUBJECT),
            intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString(),
        ).filter { it.isNotBlank() }.distinct().joinToString("\n")
        return if (text.isBlank()) null else mapOf("action" to "share", "text" to text)
    }

    /** An HTML lesson opened ("Not ile aç") or shared from a file app. */
    private fun lessonFrom(uri: Uri): Map<String, String>? = try {
        contentResolver.openInputStream(uri)?.use { input ->
            val bytes = input.readBytes()
            if (bytes.size > MAX_LESSON_BYTES) null
            else mapOf("action" to "lesson", "html" to String(bytes, Charsets.UTF_8))
        }
    } catch (e: Exception) {
        null
    }

    /**
     * Writes a lesson to Documents/Not/Dersler/ through MediaStore (no
     * storage permission needed) so file managers and browsers can open
     * it; rewrites our own copy when it is already there.
     */
    private fun saveToDocuments(name: String, html: String): Uri? {
        val files = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val existing = contentResolver.query(
            files,
            arrayOf(MediaStore.MediaColumns._ID),
            "${MediaStore.MediaColumns.RELATIVE_PATH}=? AND ${MediaStore.MediaColumns.DISPLAY_NAME}=?",
            arrayOf(LESSON_DIR, name),
            null,
        )?.use { c -> if (c.moveToFirst()) ContentUris.withAppendedId(files, c.getLong(0)) else null }
        val uri = existing ?: contentResolver.insert(files, ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, name)
            put(MediaStore.MediaColumns.MIME_TYPE, "text/html")
            put(MediaStore.MediaColumns.RELATIVE_PATH, LESSON_DIR)
        }) ?: return null
        contentResolver.openOutputStream(uri, "wt")?.use { it.write(html.toByteArray(Charsets.UTF_8)) }
            ?: return null
        return uri
    }

    /** Lets the user pick a browser / HTML viewer for a saved lesson. */
    private fun openHtml(uri: Uri): Boolean {
        val view = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, "text/html")
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        return try {
            startActivity(Intent.createChooser(view, "Dersi aç"))
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Opens a link in the app that owns it (YouTube, Instagram, X …) and
     * only falls back to the browser when no such app is installed.
     */
    private fun openUrl(url: String): Boolean {
        val view = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            .addCategory(Intent.CATEGORY_BROWSABLE)
        return try {
            startActivity(Intent(view).addFlags(Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER))
            true
        } catch (e: ActivityNotFoundException) {
            try {
                startActivity(view)
                true
            } catch (e: Exception) {
                false
            }
        }
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
        val LESSON_DIR = Environment.DIRECTORY_DOCUMENTS + "/Not/Dersler/"
        const val MAX_LESSON_BYTES = 16 * 1024 * 1024
        const val PICK_LESSON = 7301
        const val EXTERNAL_DOCS = "com.android.externalstorage.documents"
    }
}
