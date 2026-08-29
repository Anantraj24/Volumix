package com.anant.volumix

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
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

        val notification = buildNotification(this)
        startForeground(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    companion object {
        const val NOTIFICATION_ID = 1001
        const val CHANNEL_ID = "volumix_persistent_control"

        const val ACTION_DECREASE_MASTER = "com.anant.volumix.ACTION_DECREASE_MASTER"
        const val ACTION_INCREASE_MASTER = "com.anant.volumix.ACTION_INCREASE_MASTER"
        const val ACTION_TOGGLE_MUTE = "com.anant.volumix.ACTION_TOGGLE_MUTE"

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

            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val notification = buildNotification(context)
            nm.notify(NOTIFICATION_ID, notification)
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

        private fun buildNotification(context: Context): Notification {
            createNotificationChannel(context)

            val vm = VolumeManager(context)
            val masterPct = vm.getMasterPercentage()
            val streams = vm.getStreams()

            val prefs = context.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)
            val showMedia = prefs.getBoolean(VolumeManager.PREF_NOTIF_MEDIA, true)
            val showRing = prefs.getBoolean(VolumeManager.PREF_NOTIF_RING, true)
            val showAlarm = prefs.getBoolean(VolumeManager.PREF_NOTIF_ALARM, true)
            val showNotification = prefs.getBoolean(VolumeManager.PREF_NOTIF_NOTIF, true)
            val showCall = prefs.getBoolean(VolumeManager.PREF_NOTIF_CALL, false)
            val showPercent = prefs.getBoolean(VolumeManager.PREF_NOTIF_PERCENT, true)
            val showMuteBtn = prefs.getBoolean(VolumeManager.PREF_NOTIF_MUTE_BTN, true)

            // Content Tap Intent (Opens App)
            val appIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val appPendingIntent = PendingIntent.getActivity(
                context, 0, appIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Minus Action
            val minusIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                action = ACTION_DECREASE_MASTER
            }
            val minusPendingIntent = PendingIntent.getBroadcast(
                context, 1, minusIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Plus Action
            val plusIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                action = ACTION_INCREASE_MASTER
            }
            val plusPendingIntent = PendingIntent.getBroadcast(
                context, 2, plusIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Mute Action
            val muteIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                action = ACTION_TOGGLE_MUTE
            }
            val mutePendingIntent = PendingIntent.getBroadcast(
                context, 3, muteIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Collapsed RemoteViews
            val collapsedView = RemoteViews(context.packageName, R.layout.notification_volumix_collapsed).apply {
                setTextViewText(R.id.notif_master_percentage, "$masterPct%")
                setViewVisibility(R.id.notif_badge_container, if (showPercent) View.VISIBLE else View.GONE)
                setViewVisibility(R.id.notif_btn_mute, if (showMuteBtn) View.VISIBLE else View.GONE)

                setOnClickPendingIntent(R.id.notif_btn_minus, minusPendingIntent)
                setOnClickPendingIntent(R.id.notif_btn_plus, plusPendingIntent)
                setOnClickPendingIntent(R.id.notif_btn_mute, mutePendingIntent)
            }

            // Expanded RemoteViews
            val expandedView = RemoteViews(context.packageName, R.layout.notification_volumix_expanded).apply {
                setTextViewText(R.id.notif_exp_master_percentage, "$masterPct%")
                setViewVisibility(R.id.notif_exp_badge_container, if (showPercent) View.VISIBLE else View.GONE)
                setViewVisibility(R.id.notif_exp_btn_mute, if (showMuteBtn) View.VISIBLE else View.GONE)

                setOnClickPendingIntent(R.id.notif_exp_btn_minus, minusPendingIntent)
                setOnClickPendingIntent(R.id.notif_exp_btn_plus, plusPendingIntent)
                setOnClickPendingIntent(R.id.notif_exp_btn_mute, mutePendingIntent)

                // Populate streams in expanded layout
                for (stream in streams) {
                    val streamType = stream["streamType"] as Int
                    val pct = stream["percentage"] as Int

                    when (streamType) {
                        AudioManager.STREAM_MUSIC -> {
                            setViewVisibility(R.id.notif_row_media, if (showMedia) View.VISIBLE else View.GONE)
                            setTextViewText(R.id.notif_val_media, "$pct%")
                            setProgressBar(R.id.notif_prog_media, 100, pct, false)
                        }
                        AudioManager.STREAM_RING -> {
                            setViewVisibility(R.id.notif_row_ring, if (showRing) View.VISIBLE else View.GONE)
                            setTextViewText(R.id.notif_val_ring, "$pct%")
                            setProgressBar(R.id.notif_prog_ring, 100, pct, false)
                        }
                        AudioManager.STREAM_ALARM -> {
                            setViewVisibility(R.id.notif_row_alarm, if (showAlarm) View.VISIBLE else View.GONE)
                            setTextViewText(R.id.notif_val_alarm, "$pct%")
                            setProgressBar(R.id.notif_prog_alarm, 100, pct, false)
                        }
                        AudioManager.STREAM_NOTIFICATION -> {
                            setViewVisibility(R.id.notif_row_notification, if (showNotification) View.VISIBLE else View.GONE)
                            setTextViewText(R.id.notif_val_notification, "$pct%")
                            setProgressBar(R.id.notif_prog_notification, 100, pct, false)
                        }
                        AudioManager.STREAM_VOICE_CALL -> {
                            setViewVisibility(R.id.notif_row_call, if (showCall) View.VISIBLE else View.GONE)
                            setTextViewText(R.id.notif_val_call, "$pct%")
                            setProgressBar(R.id.notif_prog_call, 100, pct, false)
                        }
                    }
                }
            }

            return NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_volumix_notification)
                .setContentTitle(context.getString(R.string.app_name))
                .setContentText("Master Volume: $masterPct%")
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
