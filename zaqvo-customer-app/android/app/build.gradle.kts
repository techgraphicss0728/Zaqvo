import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/**
 * Reads [key] from a `.env` file (project root). Used so the same key as Flutter/dotenv
 * is applied to [com.google.android.geo.API_KEY] for map tiles (Gradle does not read .env automatically).
 */
fun readEnvFileValue(envFile: File, key: String): String {
    if (!envFile.isFile) return ""
    for (line in envFile.readLines()) {
        val trimmed = line.trim()
        if (trimmed.isEmpty() || trimmed.startsWith("#")) continue
        val eq = trimmed.indexOf('=')
        if (eq <= 0) continue
        val k = trimmed.substring(0, eq).trim()
        if (k != key) continue
        var v = trimmed.substring(eq + 1).trim()
        if (v.length >= 2) {
            if ((v.startsWith("\"") && v.endsWith("\"")) || (v.startsWith("'") && v.endsWith("'"))) {
                v = v.substring(1, v.length - 1)
            }
        }
        return v
    }
    return ""
}

android {
    namespace = "com.example.zaqvo_customer_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.zaqvo_customer_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Priority: gradle -P / gradle.properties → env var → repo root .env (same as Flutter dotenv)
        val flutterProjectRoot = rootProject.projectDir.parentFile
        val mapsKey =
            (project.findProperty("GOOGLE_MAPS_API_KEY") as String?)
                ?.takeIf { it.isNotBlank() }
                ?: System.getenv("GOOGLE_MAPS_API_KEY")?.takeIf { it.isNotBlank() }
                ?: readEnvFileValue(File(flutterProjectRoot, ".env"), "GOOGLE_MAPS_API_KEY")
                    .takeIf { it.isNotBlank() }
                ?: ""
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
