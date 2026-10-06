// MetJou for Wear OS: one SOS button that alerts through the paired phone.
// Shares the phone app's applicationId so the Data Layer connects them.
plugins {
    // No Kotlin plugin here: the Flutter Gradle plugin adds Kotlin support
    // to every Android module of this build, as it does for :app.
    id("com.android.application")
}

android {
    namespace = "io.github.adambouafia.metjou.wear"
    compileSdk = 37

    defaultConfig {
        applicationId = "io.github.adambouafia.metjou"
        minSdk = 30
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-wearable:20.0.1")
}
