import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "io.bytebakehouse.trackie"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.0.13004108"
    
    // Enable BuildConfig generation
    buildFeatures {
        buildConfig = true
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "io.bytebakehouse.trackie"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Only define release signing config
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
        // The debug signing config will use the default debug keystore
    }

    flavorDimensions += "environment"
    
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Trackie Dev")
            buildConfigField("String", "API_BASE_URL", "\"https://dev-api.example.com/\"")
            buildConfigField("boolean", "ENABLE_LOGS", "true")
        }
        
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Trackie Staging")
            buildConfigField("String", "API_BASE_URL", "\"https://staging-api.example.com/\"")
            buildConfigField("boolean", "ENABLE_LOGS", "true")
        }
        
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Trackie")
            buildConfigField("String", "API_BASE_URL", "\"https://api.example.com/\"")
            buildConfigField("boolean", "ENABLE_LOGS", "false")
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            // Don't specify signingConfig here - it will use the default debug keystore
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        
        release {
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add any Android-specific dependencies here
}