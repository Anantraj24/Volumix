package com.anant.volumix

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var volumePlatformChannel: VolumePlatformChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        volumePlatformChannel = VolumePlatformChannel(this).apply {
            registerWith(flutterEngine)
        }
    }

    override fun onDestroy() {
        volumePlatformChannel?.unregister()
        super.onDestroy()
    }
}
