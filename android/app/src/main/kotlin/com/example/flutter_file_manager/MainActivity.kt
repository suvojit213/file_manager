package com.example.flutter_file_manager

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_file_manager/permissions"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "requestStoragePermission" -> {
                    requestStoragePermission(result)
                }
                "checkStoragePermission" -> {
                    result.success(checkStoragePermission())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            val result = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
            val result2 = ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
            result == PackageManager.PERMISSION_GRANTED && result2 == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestStoragePermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            if (!Environment.isExternalStorageManager()) {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:" + applicationContext.packageName)
                startActivityForResult(intent, 100)
            } else {
                result.success(true)
            }
        } else {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE),
                101
            )
        }
        // Store the result object to send the result back after permission request
        // This is a simplified approach. For a robust solution, consider using a callback manager.
        // For now, we assume the permission dialog will be handled by the system and the checkStoragePermission
        // will be called again from Dart after the activity resumes.
        result.success(checkStoragePermission())
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 100) {
            // MANAGE_EXTERNAL_STORAGE permission result
            // No direct result from here, rely on checkStoragePermission from Dart
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 101) {
            // READ/WRITE_EXTERNAL_STORAGE permission result
            // No direct result from here, rely on checkStoragePermission from Dart
        }
    }
}
