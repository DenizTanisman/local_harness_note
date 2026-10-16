package dev.deniz.local_harness_not

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Person
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import android.provider.Settings

/**
 * The floating quick-note bubble (Android Bubbles API — no overlay
 * permission). A bubble needs a conversation: a long-lived shortcut with a
 * Person, a MessagingStyle notification on a bubble-allowed channel, and
 * BubbleMetadata pointing at [BubbleActivity].
 */
object QuickNoteBubble {
    private const val CHANNEL = "quick_note_bubble"
    private const val SHORTCUT = "quick_note"
    private const val NOTIFICATION_ID = 4242

    fun show(context: Context) {
        val nm = context.getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL, "Hızlı not baloncuğu", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "Her yerden not almak için yüzen baloncuk"
                setAllowBubbles(true)
                setShowBadge(false)
                setSound(null, null)
                enableVibration(false)
            }
        )
        val icon = Icon.createWithResource(context, R.mipmap.ic_launcher)
        val person = Person.Builder().setName("Not").setIcon(icon).setImportant(true).build()
        context.getSystemService(ShortcutManager::class.java).pushDynamicShortcut(
            ShortcutInfo.Builder(context, SHORTCUT)
                .setShortLabel("Hızlı not")
                .setLongLived(true)
                .setIcon(icon)
                .setPerson(person)
                .setIntent(Intent(context, MainActivity::class.java).setAction(Intent.ACTION_VIEW))
                .build()
        )
        // Bubbles need a mutable PendingIntent (the system adds extras).
        val bubbleIntent = PendingIntent.getActivity(
            context, 0, Intent(context, BubbleActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        val bubble = Notification.BubbleMetadata.Builder(bubbleIntent, icon)
            .setDesiredHeight(560)
            .setAutoExpandBubble(false)
            .setSuppressNotification(true)
            .build()
        val notification = Notification.Builder(context, CHANNEL)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Hızlı not")
            .setContentText("Baloncuğa dokun, not al")
            .setShortcutId(SHORTCUT)
            .addPerson(person)
            .setCategory(Notification.CATEGORY_MESSAGE)
            .setStyle(
                Notification.MessagingStyle(person)
                    .addMessage("Not almak için baloncuğa dokun", System.currentTimeMillis(), person)
            )
            .setBubbleMetadata(bubble)
            .setContentIntent(bubbleIntent)
            .setOngoing(false)
            .build()
        nm.notify(NOTIFICATION_ID, notification)
    }

    fun hide(context: Context) {
        context.getSystemService(NotificationManager::class.java).cancel(NOTIFICATION_ID)
    }

    /** Whether the system will actually float it, for the settings screen. */
    fun status(context: Context): Map<String, Any> {
        val nm = context.getSystemService(NotificationManager::class.java)
        val globalOn = Settings.Secure.getInt(context.contentResolver, "notification_bubbles", 1) == 1
        val appPreference = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            when (nm.bubblePreference) {
                NotificationManager.BUBBLE_PREFERENCE_ALL -> "all"
                NotificationManager.BUBBLE_PREFERENCE_SELECTED -> "selected"
                else -> "none"
            }
        } else {
            @Suppress("DEPRECATION")
            if (nm.areBubblesAllowed()) "all" else "none"
        }
        val channelOk = nm.getNotificationChannel(CHANNEL)?.canBubble() ?: false
        val showing = nm.activeNotifications.any { it.id == NOTIFICATION_ID }
        return mapOf(
            "globalOn" to globalOn,
            "appPreference" to appPreference,
            "channelCanBubble" to channelOk,
            "showing" to showing,
        )
    }

    fun openSettings(context: Context) {
        context.startActivity(
            Intent(Settings.ACTION_APP_NOTIFICATION_BUBBLE_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
    }
}
