package com.example.flutter_frame

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "app_update"
    private var pendingApkPath: String? = null
    private var awaitingInstallPermission: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "installApk" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrEmpty()) {
                        result.error("INVALID_PATH", "APK path is null or empty", null)
                        return@setMethodCallHandler
                    }
                    try {
                        installApk(path)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (awaitingInstallPermission && pendingApkPath != null) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || packageManager.canRequestPackageInstalls()) {
                val path = pendingApkPath
                // reset flags before attempting to install to avoid loops
                awaitingInstallPermission = false
                pendingApkPath = null
                if (path != null) {
                    installApkInternal(path)
                }
            }
        }
    }

    private fun installApk(apkPath: String) {
        val file = File(apkPath)
        if (!file.exists()) throw IllegalArgumentException("APK not found: $apkPath")

        // Android 8.0+ 检查未知来源安装权限
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val canInstall = packageManager.canRequestPackageInstalls()
            if (!canInstall) {
                val uri = Uri.parse("package:$packageName")
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, uri)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                // 标记等待授权并保存路径，返回后自动继续
                awaitingInstallPermission = true
                pendingApkPath = apkPath
                startActivity(intent)
                return
            }
        }

        installApkInternal(apkPath)
    }

    private fun installApkInternal(apkPath: String) {
        val file = File(apkPath)
        if (!file.exists()) throw IllegalArgumentException("APK not found: $apkPath")

        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val authority = "$packageName.fileprovider"
            val contentUri = FileProvider.getUriForFile(this, authority, file)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            intent.setDataAndType(contentUri, "application/vnd.android.package-archive")
        } else {
            val uri = Uri.fromFile(file)
            intent.setDataAndType(uri, "application/vnd.android.package-archive")
        }

        try {
            startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            throw e
        }
    }
}
