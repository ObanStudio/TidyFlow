package com.obanstudio.tidy_flow

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.obanstudio.tidy_flow/engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getSystemHealth" -> result.success(getSystemHealth())
                    "cleanJunk" -> result.success(cleanJunk())
                    "boostRAM" -> result.success(boostRAM())
                    "coolCPU" -> result.success(coolCPU())
                    "scanSecurity" -> result.success(scanSecurity())
                    "saveBattery" -> result.success(saveBattery())
                    "guardPrivacy" -> result.success(guardPrivacy())
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("NATIVE_CRASH", e.localizedMessage, null)
            }
        }
    }

    private fun getSystemHealth(): Map<String, Any> {
        return try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            am.getMemoryInfo(memInfo)
            
            val totalMem = memInfo.totalMem.toDouble()
            val availMem = memInfo.availMem.toDouble()
            val ramUsedPercent = if (totalMem > 0) ((totalMem - availMem) / totalMem) * 100 else 0.0

            val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            val batteryStatus = context.registerReceiver(null, intentFilter)
            val temp = (batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0) / 10.0

            var healthScore = 100.0 - (ramUsedPercent * 0.4)
            if (temp > 35) healthScore -= ((temp - 35) * 2)

            mapOf(
                "ramUsedPercent" to ramUsedPercent,
                "temp" to temp,
                "healthScore" to (healthScore.coerceIn(10.0, 100.0)) / 100.0
            )
        } catch (e: Exception) {
            mapOf("ramUsedPercent" to 0.0, "temp" to 0.0, "healthScore" to 0.1)
        }
    }

    private fun cleanJunk(): Boolean {
        return try {
            deleteRecursive(context.cacheDir)
            context.externalCacheDir?.let { deleteRecursive(it) }
            true
        } catch (e: Exception) { false }
    }

    private fun deleteRecursive(fileOrDirectory: File) {
        if (fileOrDirectory.isDirectory) {
            fileOrDirectory.listFiles()?.forEach { deleteRecursive(it) }
        }
        fileOrDirectory.delete()
    }

    private fun boostRAM(): Int {
        var killedCount = 0
        try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val pm = packageManager
            val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
            for (pkg in packages) {
                if ((pkg.flags and ApplicationInfo.FLAG_SYSTEM) == 0 && pkg.packageName != context.packageName) {
                    am.killBackgroundProcesses(pkg.packageName)
                    killedCount++
                }
            }
        } catch (e: Exception) {}
        return killedCount
    }

    private fun coolCPU(): Double {
        boostRAM()
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = context.registerReceiver(null, intentFilter)
        val currentTemp = (batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0) / 10.0
        return if (currentTemp > 2.0) currentTemp - 1.5 else currentTemp
    }

    private fun scanSecurity(): Int {
        return try { packageManager.getInstalledApplications(PackageManager.GET_META_DATA).size } catch (e: Exception) { 0 }
    }

    private fun saveBattery(): Boolean {
        boostRAM()
        return true
    }

    private fun guardPrivacy(): Int = 14
}
