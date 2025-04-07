// android/app/src/main/kotlin/io/bytebakehouse/trackie/MainActivity.kt
package io.bytebakehouse.trackie

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "io.bytebakehouse.trackie/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getConfigValues") {
                val configMap = mapOf(
                    "apiBaseUrl" to BuildConfig.API_BASE_URL,
                    "enableLogs" to BuildConfig.ENABLE_LOGS,
                    "appName" to resources.getString(R.string.app_name),
                )
                result.success(configMap)
            } else {
                result.notImplemented()
            }
        }
    }
}