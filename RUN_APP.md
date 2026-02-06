# How to Run the Gym Tracker App

## Prerequisites

1. **Flutter SDK** - Download from https://flutter.dev/docs/get-started/install
2. **Android SDK** - Usually installed with Android Studio
3. **Java 11+** - Required for Android builds
4. **Android Device or Emulator** - For running the app

## Step 1: Extract Flutter (if not already done)

```bash
# Navigate to your flutter.zip location
cd C:\Users\Deepak\Documents

# Extract flutter.zip (or use Windows Explorer)
# This will create a 'flutter' folder
```

## Step 2: Add Flutter to PATH

1. Extract Flutter to a permanent location (e.g., `C:\flutter`)
2. Add `C:\flutter\bin` to your Windows PATH environment variable:
   - Right-click "This PC" → Properties
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", click "New"
   - Variable name: `Path`
   - Variable value: `C:\flutter\bin`
   - Click OK

3. Open a new Command Prompt and verify:
   ```bash
   flutter --version
   ```

## Step 3: Set Up Android Device/Emulator

### For Physical Device:
1. Enable Developer Mode on your Android phone:
   - Settings → About Phone → Build Number (tap 7 times)
   - Settings → Developer Options → Enable USB Debugging
2. Connect via USB cable

### For Emulator:
```bash
# Open Android Studio and create/launch an emulator
# Or from command line:
flutter emulators --launch <emulator_name>
```

## Step 4: Get Project Dependencies

```bash
# Navigate to project directory
cd "C:\Users\Deepak\Documents\Claude Projects\Gym tracker project"

# Install dependencies
flutter pub get
```

## Step 5: Run the App

### Debug Mode (Development):
```bash
flutter run
```

Or specify device:
```bash
flutter run -d <device_id>
```

Find device ID:
```bash
flutter devices
```

### Release Mode (for testing/distribution):
```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-app/release/app-release.apk`

Install on device:
```bash
adb install build/app/outputs/flutter-app/release/app-release.apk
```

## Step 6: Verify Installation

Once the app is running:

1. ✅ **Create Profile** - Enter your name
2. ✅ **Home Screen** - See 7 muscle categories
3. ✅ **Log Workouts**:
   - Select a category → Exercise
   - Enter weight (kg) and reps
   - Tap "Log Set"
4. ✅ **View Progress** (NEW):
   - Tap the 📊 Progress button in top-right
   - Should see all exercises with stats
   - Tap any exercise to see charts
5. ✅ **Test Charts**:
   - Log several sets for same exercise
   - View Progress → Tap Exercise
   - See weight/reps/volume charts

## Troubleshooting

### "flutter: command not found"
- ✅ Solution: Add Flutter to PATH (Step 2)
- Restart Command Prompt after adding to PATH

### "No device found"
- ✅ Solution: Ensure device is connected with USB Debugging enabled
- Or launch Android emulator first

### Build fails with "Android SDK not found"
- ✅ Solution: Install Android Studio with SDK 34+
- Run: `flutter doctor` to see what's missing

### App crashes on startup
```bash
# Clean build and try again
flutter clean
flutter pub get
flutter run
```

### Port already in use
```bash
# Use different port
flutter run --device-timeout=300
```

## Quick Commands

```bash
# Check setup
flutter doctor

# List connected devices
flutter devices

# Run with verbose output (debugging)
flutter run -v

# Stop running app
# Press Ctrl+C in terminal

# Clean build
flutter clean

# Analyze code
flutter analyze
```

## Project Structure

```
Gym Tracker/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/
│   │   ├── category.dart
│   │   ├── exercise.dart
│   │   ├── profile.dart
│   │   ├── workout_set.dart
│   │   └── progress_metrics.dart          # NEW: Progress data model
│   ├── providers/
│   │   ├── exercise_provider.dart
│   │   ├── profile_provider.dart
│   │   ├── workout_provider.dart
│   │   └── progress_provider.dart         # NEW: Progress state management
│   ├── screens/
│   │   ├── profile_selection_screen.dart
│   │   ├── home_screen.dart
│   │   ├── category_screen.dart
│   │   ├── exercise_detail_screen.dart
│   │   ├── add_custom_exercise_screen.dart
│   │   ├── progress_screen.dart           # NEW: Progress dashboard
│   │   └── exercise_progress_detail_screen.dart  # NEW: Progress charts
│   └── services/
│       └── database_service.dart
├── android/                               # Android project files
├── ios/                                   # iOS project files
├── pubspec.yaml                           # Dependencies
└── pubspec.lock                           # Locked versions
```

## Features to Test

✅ **Profile Management**
- Create profile
- Switch profiles
- View profile name in AppBar

✅ **Exercise Logging**
- View all categories
- See exercises in category
- Log weight, reps, and notes
- View recent sets

✅ **NEW - Progress Tracking**
- View Progress screen with all exercises
- Filter exercises by category
- See PR, total sets, average weight
- View detailed charts (Weight/Reps/Volume)
- Adjust chart data range
- View statistics
- View recent sets with dates

✅ **Workout Management**
- Add custom exercises
- Edit custom exercises
- Delete exercises
- Delete sets

## Support

For issues:
1. Run `flutter doctor` to check setup
2. Check logcat for errors: `adb logcat`
3. Review test report: `PROGRESS_TRACKING_TEST_REPORT.md`

---

**Happy tracking! 💪**
