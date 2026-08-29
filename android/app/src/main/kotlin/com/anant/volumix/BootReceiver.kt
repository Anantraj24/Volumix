package com.anant.volumix

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = context.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)
            val isEnabled = prefs.getBoolean(VolumeManager.PREF_PERSISTENT_NOTIF, true)
            if (isEnabled) {
                VolumeNotificationService.startService(context)
            }
        }
    }
}
