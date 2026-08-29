package com.anant.volumix

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return

        val vm = VolumeManager(context)

        when (intent.action) {
            VolumeNotificationService.ACTION_DECREASE_MASTER -> {
                vm.adjustMasterVolume(-5)
            }
            VolumeNotificationService.ACTION_INCREASE_MASTER -> {
                vm.adjustMasterVolume(5)
            }
            VolumeNotificationService.ACTION_TOGGLE_MUTE -> {
                val master = vm.getMasterPercentage()
                if (master > 0) {
                    vm.muteAll()
                } else {
                    vm.restoreAll()
                }
            }
        }

        VolumeNotificationService.updateNotification(context)
        VolumeObserver.notifyVolumeChanged(context)
    }
}
