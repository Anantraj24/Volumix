package com.anant.volumix

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioManager
import android.os.Build
import android.os.IBinder
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class VolumeNotificationService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val prefs = getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)
        val isEnabled = prefs.getBoolean(VolumeManager.PREF_PERSISTENT_NOTIF, true)

        if (!isEnabled) {
            stopForeground(true)
            stopSelf()
            return START_NOT_STICKY
        }

        try {
            val notification = buildNotification(this)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            android.util.Log.i("VolumeNotifService", "Foreground service started successfully")
        } catch (e: Exception) {
            android.util.Log.e("VolumeNotifService", "Error starting foreground service", e)
        }
        return START_STICKY
    }

    companion object {
        const val NOTIFICATION_ID = 1001
        const val CHANNEL_ID = "volumix_persistent_control_v3"

        // Action identifiers
        const val ACTION_MEDIA_MINUS = "com.anant.volumix.ACTION_MEDIA_MINUS"
        const val ACTION_MEDIA_PLUS = "com.anant.volumix.ACTION_MEDIA_PLUS"
        const val ACTION_MEDIA_MUTE = "com.anant.volumix.ACTION_MEDIA_MUTE"

        const val ACTION_RING_MINUS = "com.anant.volumix.ACTION_RING_MINUS"
        const val ACTION_RING_PLUS = "com.anant.volumix.ACTION_RING_PLUS"
        const val ACTION_RING_MUTE = "com.anant.volumix.ACTION_RING_MUTE"

        const val ACTION_ALARM_MINUS = "com.anant.volumix.ACTION_ALARM_MINUS"
        const val ACTION_ALARM_PLUS = "com.anant.volumix.ACTION_ALARM_PLUS"
        const val ACTION_ALARM_MUTE = "com.anant.volumix.ACTION_ALARM_MUTE"

        const val ACTION_CALL_MINUS = "com.anant.volumix.ACTION_CALL_MINUS"
        const val ACTION_CALL_PLUS = "com.anant.volumix.ACTION_CALL_PLUS"
        const val ACTION_CALL_MUTE = "com.anant.volumix.ACTION_CALL_MUTE"

        fun startService(context: Context) {
            val prefs = context.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)
            prefs.edit().putBoolean(VolumeManager.PREF_PERSISTENT_NOTIF, true).apply()

            val intent = Intent(context, VolumeNotificationService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stopService(context: Context) {
            val prefs = context.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)
            prefs.edit().putBoolean(VolumeManager.PREF_PERSISTENT_NOTIF, false).apply()

            val intent = Intent(context, VolumeNotificationService::class.java)
            context.stopService(intent)

            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.cancel(NOTIFICATION_ID)
        }

        fun updateNotification(context: Context) {
            val prefs = context.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)
            val isEnabled = prefs.getBoolean(VolumeManager.PREF_PERSISTENT_NOTIF, true)
            if (!isEnabled) return

            try {
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                val notification = buildNotification(context)
                nm.notify(NOTIFICATION_ID, notification)
            } catch (e: Exception) {
                android.util.Log.e("VolumeNotifService", "Error updating notification", e)
            }
        }

        private fun createNotificationChannel(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    context.getString(R.string.notification_channel_name),
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = context.getString(R.string.notification_channel_desc)
                    setShowBadge(false)
                    enableLights(false)
                    enableVibration(false)
                    setSound(null, null)
                }
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.createNotificationChannel(channel)
            }
        }

        private fun createActionPendingIntent(context: Context, action: String, requestCode: Int): PendingIntent {
            val intent = Intent(context, NotificationActionReceiver::class.java).apply {
                this.action = action
            }
            return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun buildNotification(context: Context): Notification {
            createNotificationChannel(context)

            val vm = VolumeManager(context)
            val mediaPct = vm.getStreamPercentage(AudioManager.STREAM_MUSIC)
            val ringPct = vm.getStreamPercentage(AudioManager.STREAM_RING)
            val alarmPct = vm.getStreamPercentage(AudioManager.STREAM_ALARM)
            val callPct = vm.getStreamPercentage(AudioManager.STREAM_VOICE_CALL)

            val prefs = context.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)
            val showMedia = prefs.getBoolean(VolumeManager.PREF_NOTIF_MEDIA, true)
            val showRing = prefs.getBoolean(VolumeManager.PREF_NOTIF_RING, true)
            val showAlarm = prefs.getBoolean(VolumeManager.PREF_NOTIF_ALARM, true)
            val showCall = prefs.getBoolean(VolumeManager.PREF_NOTIF_CALL, true)
            val showPercent = prefs.getBoolean(VolumeManager.PREF_NOTIF_PERCENT, true)

            // Content Tap Intent (Opens App)
            val appIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val appPendingIntent = PendingIntent.getActivity(
                context, 0, appIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Pending Intents for Actions
            val mediaMinusPending = createActionPendingIntent(context, ACTION_MEDIA_MINUS, 10)
            val mediaPlusPending = createActionPendingIntent(context, ACTION_MEDIA_PLUS, 11)
            val mediaMutePending = createActionPendingIntent(context, ACTION_MEDIA_MUTE, 12)

            val ringMinusPending = createActionPendingIntent(context, ACTION_RING_MINUS, 20)
            val ringPlusPending = createActionPendingIntent(context, ACTION_RING_PLUS, 21)
            val ringMutePending = createActionPendingIntent(context, ACTION_RING_MUTE, 22)

            val alarmMinusPending = createActionPendingIntent(context, ACTION_ALARM_MINUS, 30)
            val alarmPlusPending = createActionPendingIntent(context, ACTION_ALARM_PLUS, 31)
            val alarmMutePending = createActionPendingIntent(context, ACTION_ALARM_MUTE, 32)

            val callMinusPending = createActionPendingIntent(context, ACTION_CALL_MINUS, 40)
            val callPlusPending = createActionPendingIntent(context, ACTION_CALL_PLUS, 41)
            val callMutePending = createActionPendingIntent(context, ACTION_CALL_MUTE, 42)

            // Collapsed RemoteViews
            val collapsedView = RemoteViews(context.packageName, R.layout.notification_volumix_collapsed).apply {
                setTextViewText(R.id.notif_media_percentage, "Media $mediaPct%")
                setViewVisibility(R.id.notif_badge_container, if (showPercent) View.VISIBLE else View.GONE)

                setOnClickPendingIntent(R.id.notif_btn_media_minus, mediaMinusPending)
                setOnClickPendingIntent(R.id.notif_btn_media_plus, mediaPlusPending)
                setOnClickPendingIntent(R.id.notif_btn_media_mute, mediaMutePending)
            }

            // Expanded RemoteViews
            val expandedView = RemoteViews(context.packageName, R.layout.notification_volumix_expanded).apply {
                // Media Row
                setViewVisibility(R.id.notif_row_media, if (showMedia) View.VISIBLE else View.GONE)
                setTextViewText(R.id.notif_val_media, "$mediaPct%")
                setProgressBar(R.id.notif_prog_media, 100, mediaPct, false)
                setOnClickPendingIntent(R.id.notif_exp_media_minus, mediaMinusPending)
                setOnClickPendingIntent(R.id.notif_exp_media_plus, mediaPlusPending)
                setOnClickPendingIntent(R.id.notif_exp_media_mute, mediaMutePending)

                // Ring Row
                setViewVisibility(R.id.notif_row_ring, if (showRing) View.VISIBLE else View.GONE)
                setTextViewText(R.id.notif_val_ring, "$ringPct%")
                setProgressBar(R.id.notif_prog_ring, 100, ringPct, false)
                setOnClickPendingIntent(R.id.notif_exp_ring_minus, ringMinusPending)
                setOnClickPendingIntent(R.id.notif_exp_ring_plus, ringPlusPending)
                setOnClickPendingIntent(R.id.notif_exp_ring_mute, ringMutePending)

                // Alarm Row
                setViewVisibility(R.id.notif_row_alarm, if (showAlarm) View.VISIBLE else View.GONE)
                setTextViewText(R.id.notif_val_alarm, "$alarmPct%")
                setProgressBar(R.id.notif_prog_alarm, 100, alarmPct, false)
                setOnClickPendingIntent(R.id.notif_exp_alarm_minus, alarmMinusPending)
                setOnClickPendingIntent(R.id.notif_exp_alarm_plus, alarmPlusPending)
                setOnClickPendingIntent(R.id.notif_exp_alarm_mute, alarmMutePending)

                // Call Row
                setViewVisibility(R.id.notif_row_call, if (showCall) View.VISIBLE else View.GONE)
                setTextViewText(R.id.notif_val_call, "$callPct%")
                setProgressBar(R.id.notif_prog_call, 100, callPct, false)
                setOnClickPendingIntent(R.id.notif_exp_call_minus, callMinusPending)
                setOnClickPendingIntent(R.id.notif_exp_call_plus, callPlusPending)
                setOnClickPendingIntent(R.id.notif_exp_call_mute, callMutePending)
            }

            return NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_volumix_notification)
                .setContentTitle(context.getString(R.string.app_name))
                .setContentText("Media: $mediaPct%")
                .setCustomContentView(collapsedView)
                .setCustomBigContentView(expandedView)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setContentIntent(appPendingIntent)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .build()
        }
    }
}
