import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_frame"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    signingConfigs {
        create("release") {
            enableV1Signing = true
            enableV2Signing = true
            enableV3Signing = true
            storeFile = file("frame.jks")
            storePassword = "frame1021"
            keyAlias = "frame1021"
            keyPassword = "frame1021"
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_frame"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        signingConfig = signingConfigs.getByName("release")
    }

    buildTypes {
        release {
          isMinifyEnabled =true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // 配置 APK 输出文件名：Frame-版本号-时间戳
    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val versionName = variant.versionName ?: "1.0.0"
            val buildType = variant.buildType.name
            val timestamp = SimpleDateFormat("yyyyMMddHHmmss", Locale.getDefault()).format(Date())
            
            // 文件名格式：Frame-版本号-构建类型-时间戳.apk
            // 例如：Frame-1.0.0-release-20250202143000.apk
            val apkName = "Frame-${versionName}-${buildType}-${timestamp}.apk"
            
            // 设置输出文件名
            val outputImpl = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            outputImpl.outputFileName = apkName
        }
    }
}

flutter {
    source = "../.."
}
