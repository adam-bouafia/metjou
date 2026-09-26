package io.github.adambouafia.metjou

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService

/**
 * Receives the SOS press from the MetJou watch app. When the app is running
 * the countdown starts right away; otherwise Android does not allow opening
 * the app from the background, so an urgent notification opens it.
 */
class WearSosListenerService : WearableListenerService() {
    companion object {
        const val SOS_PATH = "/metjou/sos"
        private const val CHANNEL_ID = "WATCH_SOS"
        private const val NOTIFICATION_ID = 781
    }

    override fun onMessageReceived(event: MessageEvent) {
        if (event.path != SOS_PATH) return
        val channel = MainActivity.activeChannel
        if (channel != null) {
            Handler(Looper.getMainLooper()).post { channel.invokeMethod("launchAction", "sos") }
            return
        }
        notifyToOpen()
    }

    private fun notifyToOpen() {
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "SOS from watch", NotificationManager.IMPORTANCE_HIGH)
            )
        }
        val intent = Intent(this, MainActivity::class.java)
            .putExtra(MainActivity.EXTRA_ACTION, "sos")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pending = PendingIntent.getActivity(
            this, 2, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_shortcut_sos)
            .setContentTitle("SOS")
            .setContentText(getString(R.string.watch_sos_open))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setContentIntent(pending)
            .setAutoCancel(true)
            .build()
        manager.notify(NOTIFICATION_ID, notification)
    }
}
