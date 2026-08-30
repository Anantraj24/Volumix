package com.anant.volumix

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager

class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return

        val vm = VolumeManager(context)

        when (intent.action) {
            // Media
            VolumeNotificationService.ACTION_MEDIA_MINUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_MUSIC, -1)
            }
            VolumeNotificationService.ACTION_MEDIA_PLUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_MUSIC, 1)
            }
            VolumeNotificationService.ACTION_MEDIA_MUTE -> {
                vm.toggleStreamMute(AudioManager.STREAM_MUSIC)
            }

            // Ring
            VolumeNotificationService.ACTION_RING_MINUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_RING, -1)
            }
            VolumeNotificationService.ACTION_RING_PLUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_RING, 1)
            }
            VolumeNotificationService.ACTION_RING_MUTE -> {
                vm.toggleStreamMute(AudioManager.STREAM_RING)
            }

            // Alarm
            VolumeNotificationService.ACTION_ALARM_MINUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_ALARM, -1)
            }
            VolumeNotificationService.ACTION_ALARM_PLUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_ALARM, 1)
            }
            VolumeNotificationService.ACTION_ALARM_MUTE -> {
                vm.toggleStreamMute(AudioManager.STREAM_ALARM)
            }

            // Call
            VolumeNotificationService.ACTION_CALL_MINUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_VOICE_CALL, -1)
            }
            VolumeNotificationService.ACTION_CALL_PLUS -> {
                vm.adjustStreamVolume(AudioManager.STREAM_VOICE_CALL, 1)
            }
            VolumeNotificationService.ACTION_CALL_MUTE -> {
                vm.toggleStreamMute(AudioManager.STREAM_VOICE_CALL)
            }
        }

        VolumeNotificationService.updateNotification(context)
        VolumeObserver.notifyVolumeChanged(context)
    }
}
