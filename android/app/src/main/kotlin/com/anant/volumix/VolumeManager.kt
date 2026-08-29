package com.anant.volumix

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.media.AudioManager
import android.os.Build
import android.provider.Settings
import org.json.JSONObject

class VolumeManager(private val context: Context) {

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val prefs: SharedPreferences = context.getSharedPreferences("volumix_prefs", Context.MODE_PRIVATE)

    companion object {
        const val PREF_SAVED_SNAPSHOT = "saved_volume_snapshot"
        const val PREF_PERSISTENT_NOTIF = "persistent_notification_enabled"
        const val PREF_NOTIF_MEDIA = "notif_show_media"
        const val PREF_NOTIF_RING = "notif_show_ring"
        const val PREF_NOTIF_ALARM = "notif_show_alarm"
        const val PREF_NOTIF_NOTIF = "notif_show_notification"
        const val PREF_NOTIF_CALL = "notif_show_call"
        const val PREF_NOTIF_PERCENT = "notif_show_percentage"
        const val PREF_NOTIF_MUTE_BTN = "notif_show_mute_button"

        val STREAM_CONFIGS = listOf(
            StreamConfig(AudioManager.STREAM_MUSIC, "Media", "Spotify, YouTube, Games", "music_note", "#ADC7FF", "#4A8EFF"),
            StreamConfig(AudioManager.STREAM_RING, "Ring", "Calls & Alerts", "notifications_active", "#C3F5FF", "#00E5FF"),
            StreamConfig(AudioManager.STREAM_NOTIFICATION, "Notification", "App & System Alerts", "notifications", "#00DAF3", "#00E5FF"),
            StreamConfig(AudioManager.STREAM_ALARM, "Alarm", "Wake & Timers", "alarm", "#F1E9FF", "#D6C9FF"),
            StreamConfig(AudioManager.STREAM_VOICE_CALL, "Call", "In-call Voice", "phone_in_talk", "#BAC9CC", "#ADC7FF"),
            StreamConfig(AudioManager.STREAM_SYSTEM, "System", "Touch & Feedback", "tune", "#849396", "#BAC9CC")
        )
    }

    data class StreamConfig(
        val streamType: Int,
        val name: String,
        val description: String,
        val icon: String,
        val primaryColorHex: String,
        val secondaryColorHex: String
    )

    fun getStreams(): List<Map<String, Any>> {
        val result = mutableListOf<Map<String, Any>>()

        for (config in STREAM_CONFIGS) {
            val streamType = config.streamType
            val maxVol = try {
                audioManager.getStreamMaxVolume(streamType)
            } catch (e: Exception) {
                0
            }

            val minVol = try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    audioManager.getStreamMinVolume(streamType)
                } else {
                    0
                }
            } catch (e: Exception) {
                0
            }

            val currentVol = try {
                audioManager.getStreamVolume(streamType)
            } catch (e: Exception) {
                0
            }

            val isMuted = try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    audioManager.isStreamMute(streamType) || (currentVol <= minVol)
                } else {
                    currentVol <= minVol
                }
            } catch (e: Exception) {
                currentVol <= minVol
            }

            val isSupported = maxVol > 0

            val range = maxVol - minVol
            val percentage = if (isSupported && range > 0) {
                val rawPct = ((currentVol - minVol).toDouble() / range.toDouble() * 100.0).toInt()
                rawPct.coerceIn(0, 100)
            } else {
                0
            }

            val item = mapOf(
                "streamType" to streamType,
                "name" to config.name,
                "description" to config.description,
                "icon" to config.icon,
                "currentVolume" to currentVol,
                "maxVolume" to maxVol,
                "minVolume" to minVol,
                "percentage" to percentage,
                "isMuted" to isMuted,
                "isSupported" to isSupported,
                "primaryColor" to config.primaryColorHex,
                "secondaryColor" to config.secondaryColorHex
            )
            result.add(item)
        }

        return result
    }

    fun getMasterPercentage(): Int {
        val streams = getStreams().filter { it["isSupported"] == true }
        if (streams.isEmpty()) return 0

        // Prioritize Media, Ring, Notification, Alarm for master volume computation
        val priorityStreams = streams.filter {
            val type = it["streamType"] as Int
            type == AudioManager.STREAM_MUSIC || type == AudioManager.STREAM_RING ||
            type == AudioManager.STREAM_NOTIFICATION || type == AudioManager.STREAM_ALARM
        }

        val targetList = if (priorityStreams.isNotEmpty()) priorityStreams else streams
        val avg = targetList.map { it["percentage"] as Int }.average()
        return avg.toInt().coerceIn(0, 100)
    }

    fun setVolume(streamType: Int, targetVolume: Int, showUi: Boolean = false): Boolean {
        return try {
            val maxVol = audioManager.getStreamMaxVolume(streamType)
            val minVol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                audioManager.getStreamMinVolume(streamType)
            } else {
                0
            }
            val clamped = targetVolume.coerceIn(minVol, maxVol)
            val flags = if (showUi) AudioManager.FLAG_SHOW_UI else 0
            audioManager.setStreamVolume(streamType, clamped, flags)
            true
        } catch (e: SecurityException) {
            false
        } catch (e: Exception) {
            false
        }
    }

    fun setMasterVolume(percentage: Int): Boolean {
        val clampedPct = percentage.coerceIn(0, 100)
        var success = true

        val streams = getStreams().filter { it["isSupported"] == true }
        for (stream in streams) {
            val streamType = stream["streamType"] as Int
            val maxVol = stream["maxVolume"] as Int
            val minVol = stream["minVolume"] as Int
            val range = maxVol - minVol
            if (range > 0) {
                val targetVol = minVol + Math.round((clampedPct.toDouble() / 100.0) * range.toDouble()).toInt()
                val ok = setVolume(streamType, targetVol, false)
                if (!ok) success = false
            }
        }
        return success
    }

    fun adjustStreamVolume(streamType: Int, direction: Int): Boolean {
        return try {
            val dir = if (direction > 0) AudioManager.ADJUST_RAISE else AudioManager.ADJUST_LOWER
            audioManager.adjustStreamVolume(streamType, dir, 0)
            true
        } catch (e: Exception) {
            false
        }
    }

    fun adjustMasterVolume(stepPercent: Int): Boolean {
        val currentMaster = getMasterPercentage()
        val newMaster = (currentMaster + stepPercent).coerceIn(0, 100)
        return setMasterVolume(newMaster)
    }

    fun setStreamMute(streamType: Int, mute: Boolean): Boolean {
        return try {
            val minVol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                audioManager.getStreamMinVolume(streamType)
            } else {
                0
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val direction = if (mute) AudioManager.ADJUST_MUTE else AudioManager.ADJUST_UNMUTE
                audioManager.adjustStreamVolume(streamType, direction, 0)
            } else {
                if (mute) {
                    audioManager.setStreamVolume(streamType, minVol, 0)
                } else {
                    val maxVol = audioManager.getStreamMaxVolume(streamType)
                    val defaultVal = (maxVol * 0.5).toInt().coerceAtLeast(1)
                    audioManager.setStreamVolume(streamType, defaultVal, 0)
                }
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    fun muteAll(): Boolean {
        // First, snapshot current non-zero volumes to SharedPreferences if we don't already have an un-restored snapshot
        val currentStreams = getStreams().filter { it["isSupported"] == true }
        val snapshotObj = JSONObject()
        var hasNonZero = false

        for (stream in currentStreams) {
            val streamType = stream["streamType"] as Int
            val curVol = stream["currentVolume"] as Int
            snapshotObj.put(streamType.toString(), curVol)
            if (curVol > 0) {
                hasNonZero = true
            }
        }

        if (hasNonZero) {
            prefs.edit().putString(PREF_SAVED_SNAPSHOT, snapshotObj.toString()).apply()
        }

        // Mute all supported streams
        var allOk = true
        for (stream in currentStreams) {
            val streamType = stream["streamType"] as Int
            val minVol = stream["minVolume"] as Int
            val ok = setVolume(streamType, minVol, false)
            if (!ok) {
                // Try adjustStreamVolume mute
                setStreamMute(streamType, true)
            }
        }
        return allOk
    }

    fun restoreAll(): Boolean {
        val snapshotJson = prefs.getString(PREF_SAVED_SNAPSHOT, null)
        if (snapshotJson.isNullOrEmpty()) {
            // If no snapshot exists, restore reasonable defaults (60-80%)
            return resetDefaults()
        }

        return try {
            val snapshotObj = JSONObject(snapshotJson)
            val keys = snapshotObj.keys()
            var anyRestored = false

            while (keys.hasNext()) {
                val key = keys.next()
                val streamType = key.toIntOrNull() ?: continue
                val savedVol = snapshotObj.getInt(key)
                val ok = setVolume(streamType, savedVol, false)
                if (ok) anyRestored = true
            }

            // Clear snapshot once restored
            prefs.edit().remove(PREF_SAVED_SNAPSHOT).apply()
            anyRestored
        } catch (e: Exception) {
            resetDefaults()
        }
    }

    fun hasSavedSnapshot(): Boolean {
        val snapshotJson = prefs.getString(PREF_SAVED_SNAPSHOT, null)
        return !snapshotJson.isNullOrEmpty()
    }

    fun resetDefaults(): Boolean {
        var success = true
        val streams = getStreams().filter { it["isSupported"] == true }

        for (stream in streams) {
            val streamType = stream["streamType"] as Int
            val maxVol = stream["maxVolume"] as Int
            val minVol = stream["minVolume"] as Int
            val defaultTarget = when (streamType) {
                AudioManager.STREAM_MUSIC -> (maxVol * 0.75).toInt()
                AudioManager.STREAM_RING -> (maxVol * 0.60).toInt()
                AudioManager.STREAM_ALARM -> maxVol
                AudioManager.STREAM_NOTIFICATION -> (maxVol * 0.75).toInt()
                AudioManager.STREAM_VOICE_CALL -> (maxVol * 0.70).toInt()
                else -> (maxVol * 0.50).toInt()
            }.coerceIn(minVol, maxVol)

            val ok = setVolume(streamType, defaultTarget, false)
            if (!ok) success = false
        }

        prefs.edit().remove(PREF_SAVED_SNAPSHOT).apply()
        return success
    }

    fun isDndAccessGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            notificationManager.isNotificationPolicyAccessGranted
        } else {
            true
        }
    }

    fun openDndSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
            } catch (e: Exception) {
                // Fallback to app settings
                val intent = Intent(Settings.ACTION_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
            }
        }
    }
}
