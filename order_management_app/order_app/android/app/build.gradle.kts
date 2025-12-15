plugins {
    id("com.android.application")
    id("kotlin-android")

    // ✅ Add Google Services plugin
    id("com.google.gms.google-services")

    // ✅ Must come after Android & Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.order_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion =  "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.order_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase BoM - Bill of Materials for consistent versions
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))

    // ✅ Add Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // ✅ Add other Firebase dependencies as needed, for example:
     implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}
