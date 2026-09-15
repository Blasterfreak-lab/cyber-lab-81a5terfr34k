plugins { id("com.android.application") }

android {
    namespace = "de.maler.aufmass"
    compileSdk = 35
    defaultConfig {
        applicationId = "de.maler.aufmass"
        minSdk = 26
        targetSdk = 35
        versionCode = 3
        versionName = "1.1.0"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildTypes { release { isMinifyEnabled = false } }
}
