package com.example.vtscanner

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.vtscanner/apk_path"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getApkPath") {
                val packageName = call.argument<String>("packageName")
                
                if (packageName != null) {
                    try {
                        val info: ApplicationInfo = packageManager.getApplicationInfo(packageName, 0)
                        val apkPath = info.sourceDir 
                        result.success(apkPath)
                    } catch (e: PackageManager.NameNotFoundException) {
                        result.error("NOT_FOUND", "App not found", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Package name is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
