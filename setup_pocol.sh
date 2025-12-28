#!/usr/bin/env bash
set -euo pipefail

GITHUB_OWNER="MagoDruidaVajraMaster"
REPO_NAME="pocol-pcco"
REPO_VISIBILITY="public"
BRANCH_SETUP="pocol/setup"
MAIN_BRANCH="main"

echo "=== [POCOL] Iniciando Setup do Projeto Android MVCR-Ω ==="

mkdir -p app/src/main/java/org/pocol/{interface_usuario/telas,ui/tema,servicos,dados/{db/dao,db/entidades,repositorio},mvcr/models,conectores,analises,utilitarios,seguranca}
mkdir -p app/src/main/res/values
mkdir -p .github/workflows
mkdir -p privacy help
mkdir -p gradle/wrapper

cat > settings.gradle <<'EOT'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "POCOL"
include ':app'
EOT

cat > build.gradle <<'EOT'
buildscript {
    ext { compose_version = '1.5.0'; kotlin_version = '1.9.10' }
    dependencies {
        classpath "com.android.tools.build:gradle:8.1.0"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
plugins {
    id 'com.android.application' version '8.1.0' apply false
    id 'org.jetbrains.kotlin.android' version '1.9.10' apply false
}
EOT

cat > app/build.gradle <<'EOT'
plugins { id 'com.android.application'; id 'org.jetbrains.kotlin.android'; id 'kotlin-kapt' }
android {
    namespace 'org.pocol'
    compileSdk 33
    defaultConfig {
        applicationId "org.pocol"
        minSdk 29
        targetSdk 33
        versionCode 1
        versionName "0.1-Ω"
    }
    buildFeatures { compose true }
    composeOptions { kotlinCompilerExtensionVersion '1.5.3' }
    kotlinOptions { jvmTarget = '17' }
}
dependencies {
    implementation 'androidx.core:core-ktx:1.10.1'
    implementation 'androidx.activity:activity-compose:1.7.2'
    implementation 'androidx.compose.ui:ui'
    implementation 'androidx.compose.material3:material3'
    implementation 'androidx.room:room-runtime:2.5.2'
    kapt 'androidx.room:room-compiler:2.5.2'
}
EOT

cat > gradle/wrapper/gradle-wrapper.properties <<'EOT'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.1.1-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOT

touch gradlew
chmod +x gradlew

cat > .github/workflows/android-debug.yml <<'EOT'
name: POCOL Build Debug
on:
  push:
    branches: [ main, pocol/setup ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: gradle
      - name: Build with Gradle
        run: chmod +x gradlew && ./gradlew assembleDebug
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: pocol-debug-apk
          path: app/build/outputs/apk/debug/*.apk
EOT

git init || true
git checkout -b main || true
git add .
git commit -m "Initial commit POCOL" || true

if gh repo view "${GITHUB_OWNER}/${REPO_NAME}" >/dev/null 2>&1; then
  git remote add origin "https://github.com/${GITHUB_OWNER}/${REPO_NAME}.git" || true
else
  gh repo create "${GITHUB_OWNER}/${REPO_NAME}" --public --source=. --remote=origin --push
fi

git checkout -b pocol/setup || true
git push -u origin pocol/setup --force

echo "=== Tudo pronto! Verifique a aba Actions no seu GitHub ==="
