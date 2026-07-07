name: Build APK

on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      # Generate the android/ platform folder around the lib/ code
      - run: flutter create . --platforms=android --org za.co.tradeon --project-name restaurant_manager_pro

      # Inject the internet permission (needed for the AI coach in release builds)
      - run: |
          sed -i 's|<application|<uses-permission android:name="android.permission.INTERNET" />\n    <application|' android/app/src/main/AndroidManifest.xml

      - run: flutter pub get

      - run: flutter build apk --release

      - uses: actions/upload-artifact@v4
        with:
          name: restaurant-manager-pro-apk
          path: build/app/outputs/flutter-apk/app-release.apk
