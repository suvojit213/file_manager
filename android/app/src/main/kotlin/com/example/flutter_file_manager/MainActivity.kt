package com.example.flutter_file_manager

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle // Added
import android.os.Environment
import android.provider.Settings
import android.view.Display // Added
import android.view.WindowManager // Added
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.os.StatFs
import java.io.File
import androidx.core.content.FileProvider

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_file_manager/permissions"
    private val DISK_SPACE_CHANNEL = "com.example.flutter_file_manager/disk_space"
    private val APK_INSTALL_CHANNEL = "com.example.flutter_file_manager/apk_install"
    private var pendingResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val display = display
            if (display != null) {
                val modes = display.supportedModes
                var bestMode: Display.Mode? = null
                for (mode in modes) {
                    if (bestMode == null || mode.refreshRate > bestMode.refreshRate) {
                        bestMode = mode
                    }
                }
                if (bestMode != null) {
                    val layoutParams = window.attributes
                    layoutParams.preferredDisplayModeId = bestMode.modeId
                    window.attributes = layoutParams
                }
            }
        }
    }

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DISK_SPACE_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getDiskSpace") {
                val path = call.argument<String>("path") ?: Environment.getExternalStorageDirectory().path
                val statFs = StatFs(path)
                val blockSize = statFs.blockSizeLong
                val totalBlocks = statFs.blockCountLong
                val availableBlocks = statFs.availableBlocksLong

                val totalSpace = totalBlocks * blockSize
                val freeSpace = availableBlocks * blockSize

                val resultMap = HashMap<String, Long>()
                resultMap["totalSpace"] = totalSpace
                resultMap["freeSpace"] = freeSpace
                result.success(resultMap)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APK_INSTALL_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    installApk(filePath)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is null", null)
                }
            } else {
                result.notImplemented()
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
        pendingResult = result
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
            // No direct result from here, rely on checkStoragePermission from Dart after activity resumes
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 100) {
            pendingResult?.success(checkStoragePermission())
            pendingResult = null
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 101) {
            pendingResult?.success(checkStoragePermission())
            pendingResult = null
        }
    }

    private fun installApk(filePath: String) {
        val file = File(filePath)
        if (file.exists()) {
            val uri = FileProvider.getUriForFile(this, "${applicationContext.packageName}.provider", file)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } else {
            // Handle file not found
        }
    }
}
