package com.anant.volumix

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VolumePlatformChannel(private val activity: Activity) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL_NAME = "com.anant.volumix/volume_methods"
        const val EVENT_CHANNEL_NAME = "com.anant.volumix/volume_events"
        const val REQUEST_CODE_POST_NOTIFICATIONS = 101
    }

    private val volumeManager = VolumeManager(activity)
    private val volumeObserver = VolumeObserver(activity)
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null

    fun registerWith(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME).apply {
            setMethodCallHandler(this@VolumePlatformChannel)
        }
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME).apply {
            setStreamHandler(this@VolumePlatformChannel)
        }
    }

    fun unregister() {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        volumeObserver.stopListening()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStreams" -> {
                val streams = volumeManager.getStreams()
                result.success(streams)
            }
            "getMasterPercentage" -> {
                val masterPct = volumeManager.getMasterPercentage()
                result.success(masterPct)
            }
            "setVolume" -> {
                val streamType = call.argument<Int>("streamType") ?: 3
                val volume = call.argument<Int>("volume") ?: 0
                val ok = volumeManager.setVolume(streamType, volume, false)
                volumeObserver.dispatchVolumeUpdate(isExternal = false)
                result.success(ok)
            }
            "setMasterVolume" -> {
                val percentage = call.argument<Int>("percentage") ?: 50
                val ok = volumeManager.setMasterVolume(percentage)
                volumeObserver.dispatchVolumeUpdate(isExternal = false)
                result.success(ok)
            }
            "adjustStreamVolume" -> {
                val streamType = call.argument<Int>("streamType") ?: 3
                val direction = call.argument<Int>("direction") ?: 1
                val ok = volumeManager.adjustStreamVolume(streamType, direction)
                volumeObserver.dispatchVolumeUpdate(isExternal = false)
                result.success(ok)
            }
            "setStreamMute" -> {
                val streamType = call.argument<Int>("streamType") ?: 3
                val mute = call.argument<Boolean>("mute") ?: true
                val ok = volumeManager.setStreamMute(streamType, mute)
                volumeObserver.dispatchVolumeUpdate(isExternal = false)
                result.success(ok)
            }
            "muteAll" -> {
                val ok = volumeManager.muteAll()
                volumeObserver.dispatchVolumeUpdate(isExternal = false)
                result.success(ok)
            }
            "restoreAll" -> {
                val ok = volumeManager.restoreAll()
                volumeObserver.dispatchVolumeUpdate(isExternal = false)
                result.success(ok)
            }
            "hasSavedSnapshot" -> {
                result.success(volumeManager.hasSavedSnapshot())
            }
            "resetDefaults" -> {
                val ok = volumeManager.resetDefaults()
                volumeObserver.dispatchVolumeUpdate(isExternal = false)
                result.success(ok)
            }
            "isNotificationPermissionGranted" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    val granted = ContextCompat.checkSelfPermission(
                        activity,
                        android.Manifest.permission.POST_NOTIFICATIONS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(granted)
                } else {
                    result.success(true)
                }
            }
            "requestNotificationPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                        REQUEST_CODE_POST_NOTIFICATIONS
                    )
                }
                result.success(true)
            }
            "setPersistentNotificationEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                if (enabled) {
                    VolumeNotificationService.startService(activity)
                } else {
                    VolumeNotificationService.stopService(activity)
                }
                result.success(true)
            }
            "updateNotificationControls" -> {
                val prefs = activity.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE).edit()
                call.argument<Boolean>("showMedia")?.let { prefs.putBoolean(VolumeManager.PREF_NOTIF_MEDIA, it) }
                call.argument<Boolean>("showRing")?.let { prefs.putBoolean(VolumeManager.PREF_NOTIF_RING, it) }
                call.argument<Boolean>("showAlarm")?.let { prefs.putBoolean(VolumeManager.PREF_NOTIF_ALARM, it) }
                call.argument<Boolean>("showNotification")?.let { prefs.putBoolean(VolumeManager.PREF_NOTIF_NOTIF, it) }
                call.argument<Boolean>("showCall")?.let { prefs.putBoolean(VolumeManager.PREF_NOTIF_CALL, it) }
                call.argument<Boolean>("showPercentage")?.let { prefs.putBoolean(VolumeManager.PREF_NOTIF_PERCENT, it) }
                call.argument<Boolean>("showMute")?.let { prefs.putBoolean(VolumeManager.PREF_NOTIF_MUTE_BTN, it) }
                prefs.apply()

                VolumeNotificationService.updateNotification(activity)
                result.success(true)
            }
            "isDndAccessGranted" -> {
                result.success(volumeManager.isDndAccessGranted())
            }
            "openDndSettings" -> {
                volumeManager.openDndSettings()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events != null) {
            volumeObserver.startListening(events)
        }
    }

    override fun onCancel(arguments: Any?) {
        volumeObserver.stopListening()
    }
}
