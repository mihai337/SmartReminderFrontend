package com.MSA.SmartReminderApp

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import models.TaskModel
import models.TaskModelMapper
import services.LocationService

class MainActivity : FlutterActivity() {

    companion object {
        lateinit var channel: MethodChannel
    }

    private val CHANNEL_NAME = "location_control"

    @SuppressLint("ImplicitSamInstance")
    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val intent = Intent(this, LocationService::class.java)

                    startForegroundService(intent)

                    result.success(null)
                }

                "stopService" -> {
                    stopService(Intent(this, LocationService::class.java))
                    result.success(null)
                }

                "sendTasks" -> {
                    val tasks = call.argument<List<Map<String, Any>>>("tasks")

                    if(tasks == null) {
                        result.error("INVALID_ARGUMENT", "Tasks argument is missing or invalid", null)
                        return@setMethodCallHandler
                    }

                    val tasksList = tasks.map { taskMap ->
                        try {
                            TaskModelMapper.mapToTaskModel(taskMap)
                        } catch (e: Exception) {
                            null
                        }
                    }

                    LocationService.updateTasks(tasksList.filterNotNull())
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
