# WaveMart App

A simple Flutter application with GitHub Actions CI/CD for automated debug APK builds.

## Features

- Simple counter app demonstrating Flutter basics
- Automated debug APK builds via GitHub Actions
- Material Design 3 UI

## Project Structure

```
wavemartapp/
├── lib/
│   └── main.dart          # Main application code
├── android/                # Android platform files
├── .github/
│   └── workflows/
│       └── build-apk.yml  # GitHub Actions workflow
└── pubspec.yaml           # Flutter dependencies
```

## GitHub Actions Build

The debug APK is automatically built when you:
- Push to `main` or `master` branch
- Open a pull request
- Manually trigger the workflow

### Download the APK

1. Go to the **Actions** tab in your GitHub repository
2. Select the workflow run you want
3. Scroll down to the **Artifacts** section
4. Click on `app-debug` to download the APK

### Manually Trigger Build

1. Go to **Actions** → **Build Debug APK**
2. Click **Run workflow**
3. Select the branch and click **Run workflow**

## Local Development

### Prerequisites

- Flutter SDK (3.19.0 or higher)
- Java 17
- Android Studio (optional, for emulators)

### Setup

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build debug APK locally
flutter build apk --debug
```

## License

MIT
