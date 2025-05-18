plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.specialone"
    compileSdk = 33  // veya Flutter projesinde kullanılan sürüm

    defaultConfig {
        applicationId = "com.example.specialone"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}
