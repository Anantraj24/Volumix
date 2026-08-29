package com.anant.volumix

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.EventChannel

class VolumeObserver(private val context: Context) {

    private val handler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private val volumeManager = VolumeManager(context)

    private var contentObserver: ContentObserver? = null
    private var volumeChangeReceiver: BroadcastReceiver? = null
    private var isObserving = false

    private val debounceRunnable = Runnable {
        dispatchVolumeUpdate(isExternal = true)
    }

    companion object {
        private var activeObserver: VolumeObserver? = null

        fun notifyVolumeChanged(context: Context) {
            activeObserver?.dispatchVolumeUpdate(isExternal = false)
        }
    }

    fun startListening(sink: EventChannel.EventSink) {
        this.eventSink = sink
        activeObserver = this

        if (!isObserving) {
            registerContentObserver()
            registerBroadcastReceiver()
            isObserving = true
        }

        // Send initial state immediately
        dispatchVolumeUpdate(isExternal = false)
    }

    fun stopListening() {
        this.eventSink = null
        if (activeObserver == this) {
            activeObserver = null
        }

        if (isObserving) {
            unregisterContentObserver()
            unregisterBroadcastReceiver()
            isObserving = false
        }
    }

    private fun registerContentObserver() {
        try {
            contentObserver = object : ContentObserver(handler) {
                override fun onChange(selfChange: Boolean) {
                    super.onChange(selfChange)
                    onVolumeChangedEvent()
                }
            }
            context.contentResolver.registerContentObserver(
                Settings.System.CONTENT_URI,
                true,
                contentObserver!!
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun unregisterContentObserver() {
        contentObserver?.let {
            try {
                context.contentResolver.unregisterContentObserver(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            contentObserver = null
        }
    }

    private fun registerBroadcastReceiver() {
        try {
            volumeChangeReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    onVolumeChangedEvent()
                }
            }
            val filter = IntentFilter().apply {
                addAction("android.media.VOLUME_CHANGED_ACTION")
                addAction(AudioManager.RINGER_MODE_CHANGED_ACTION)
                addAction("android.media.STREAM_MUTE_CHANGED_ACTION")
            }
            context.registerReceiver(volumeChangeReceiver, filter)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun unregisterBroadcastReceiver() {
        volumeChangeReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            volumeChangeReceiver = null
        }
    }

    private fun onVolumeChangedEvent() {
        // Debounce 50ms to group multiple rapid events
        handler.removeCallbacks(debounceRunnable)
        handler.postDelayed(debounceRunnable, 50)
    }

    fun dispatchVolumeUpdate(isExternal: Boolean) {
        val streams = volumeManager.getStreams()
        val masterPct = volumeManager.getMasterPercentage()
        val hasSnapshot = volumeManager.hasSavedSnapshot()

        // Update persistent notification
        VolumeNotificationService.updateNotification(context)

        // Send to Flutter EventChannel
        handler.post {
            eventSink?.let { sink ->
                val payload = mapOf(
                    "type" to "volume_change",
                    "isExternal" to isExternal,
                    "masterPercentage" to masterPct,
                    "hasSavedSnapshot" to hasSnapshot,
                    "streams" to streams
                )
                try {
                    sink.success(payload)
                } catch (e: Exception) {
                    // Sink might be closed
                }
            }
        }
    }
}
