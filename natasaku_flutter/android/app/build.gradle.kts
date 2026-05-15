import java.io.FileInputStream
import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystoreCandidates = listOf(
    rootProject.file("../../keystore.properties"),
    rootProject.file("../key.properties"),
    rootProject.file("key.properties")
)
val keystorePropertiesFile = keystoreCandidates.firstOrNull { it.exists() }
if (keystorePropertiesFile != null) {
    FileInputStream(keystorePropertiesFile).use { input ->
        keystoreProperties.load(input)
    }
}

fun resolveStoreFile(path: String, baseDir: File): File {
    val file = File(path)
    return if (file.isAbsolute) file else File(baseDir, path)
}

val releaseStoreFilePath =
    keystoreProperties.getProperty("storeFile") ?: System.getenv("NATASAKU_STORE_FILE")
val releaseStorePassword =
    keystoreProperties.getProperty("storePassword") ?: System.getenv("NATASAKU_STORE_PASSWORD")
val releaseKeyAlias =
    keystoreProperties.getProperty("keyAlias") ?: System.getenv("NATASAKU_KEY_ALIAS")
val releaseKeyPassword =
    keystoreProperties.getProperty("keyPassword") ?: System.getenv("NATASAKU_KEY_PASSWORD")
val hasReleaseSigning =
    !releaseStoreFilePath.isNullOrBlank() &&
        !releaseStorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank()

android {
    namespace = "com.natasaku.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.natasaku.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                val storeFilePath = releaseStoreFilePath!!
                val propsDir = keystorePropertiesFile?.parentFile ?: rootProject.projectDir
                storeFile = resolveStoreFile(storeFilePath, propsDir)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
