plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.todo_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            // Для продакшена создай key.jks и укажи свои данные
            storeFile = file("key.jks")
            storePassword = ""
            keyAlias = "todoappkey"
            keyPassword = ""
        }
    }

    defaultConfig {
        applicationId = "com.example.todo_app"
        minSdk = 23 // Устанавливаем minSdk 23 для охвата большего числа устройств
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // Включаем минификацию кода
            isShrinkResources = true // Уменьшаем размер ресурсов
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}