plugins { id("com.android.application") }

android {
    namespace = "de.maler.aufmass"
    compileSdk = 35
    defaultConfig {
        applicationId = "de.maler.aufmass"
        minSdk = 26
        targetSdk = 35
        versionCode = 4
        versionName = "1.1.1"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildTypes { release { isMinifyEnabled = false } }
}
