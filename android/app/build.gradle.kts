import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load API keys from .env at the Flutter project root (single source of truth)
val envProperties = Properties().apply {
    val file = rootProject.file("../.env")
    if (file.exists()) file.inputStream().use { load(it) }
}
val googleMapsApiKey: String = envProperties.getProperty("GOOGLE_MAPS_API_KEY", "")

// Dynamically generate app_secrets.dart from .env to ensure Dart always has access to the key
val appSecretsFile = rootProject.file("../lib/core/constants/app_secrets.dart")
if (googleMapsApiKey.isNotEmpty()) {
    appSecretsFile.parentFile.mkdirs()
    appSecretsFile.writeText("""
        // Generated dynamically from .env. Do not commit.
        class AppSecrets {
          static const String googleMapsApiKey = '$googleMapsApiKey';
        }
    """.trimIndent())
}


android {
    namespace = "com.bennu.tareeq"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.bennu.tareeq"
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Inject the key into AndroidManifest.xml via ${GOOGLE_MAPS_API_KEY}
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

