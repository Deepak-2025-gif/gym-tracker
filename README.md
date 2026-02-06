# Gym Tracker App

A mobile fitness tracking application built with Flutter for logging workout sets and managing exercise routines by muscle groups.

## Features

### Core Functionality
- **Multi-Profile Support**: Create and manage multiple user profiles to track separate workout logs
  - Profile names with duplicate prevention
  - Profile-specific workout data isolation
  - Quick profile switching from the app

- **7 Muscle Categories**: Pre-defined exercise categories
  - Chest
  - Shoulders
  - Back
  - Biceps
  - Triceps
  - Legs
  - Core/Abs

- **Exercise Management**
  - Pre-defined exercises in each category
  - Add custom exercises within any category
  - Edit and delete custom exercises
  - Search and filter exercises by name

- **Workout Set Logging**
  - Log sets with weight (in kg) and reps
  - Optional notes for each set
  - View recent set history (last 10 sets per exercise)
  - Delete logged sets
  - Sets are isolated per profile

- **Offline First**
  - Local SQLite database storage
  - No internet connection required
  - All data stored on device

## Technical Stack

### Technology & Dependencies
- **Framework**: Flutter 3.24.3 with Dart 3.5.3
- **State Management**: Provider package
- **Database**: SQLite (sqflite)
- **ID Generation**: uuid
- **Date Formatting**: intl
- **Platform**: Android (SDK 34) with minimum SDK 24
- **Java Version**: Java 11+
- **IDE**: Android Studio with Dart/Flutter plugins

### Project Structure
```
lib/
├── main.dart                    # App entry point with MultiProvider setup
├── models/
│   ├── category.dart           # Category model (id, name, icon, color)
│   ├── exercise.dart           # Exercise model (name, categoryId, description, etc.)
│   ├── workout_set.dart        # WorkoutSet model (weight, reps, profileId)
│   └── profile.dart            # Profile model (id, name, createdAt)
├── providers/
│   ├── exercise_provider.dart  # Exercise state management
│   ├── workout_provider.dart   # Workout/set logging state management
│   └── profile_provider.dart   # Profile management and selection
├── screens/
│   ├── profile_selection_screen.dart  # Profile create/select UI
│   ├── home_screen.dart               # Main categories display
│   ├── category_screen.dart           # Exercises in category with search
│   ├── exercise_detail_screen.dart    # Log sets and view history
│   └── add_custom_exercise_screen.dart # Custom exercise form
└── services/
    └── database_service.dart   # SQLite database operations
```

### Database Schema

#### Profiles Table
```sql
CREATE TABLE profiles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  createdAt TEXT NOT NULL
)
```

#### Exercises Table
```sql
CREATE TABLE exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  categoryId TEXT NOT NULL,
  description TEXT,
  youtubeVideoId TEXT,
  defaultWeight REAL NOT NULL,
  defaultReps INTEGER NOT NULL,
  isCustom BOOLEAN NOT NULL,
  createdAt TEXT NOT NULL
)
```

#### Workout Sets Table
```sql
CREATE TABLE workout_sets (
  id TEXT PRIMARY KEY,
  profileId TEXT NOT NULL,
  exerciseId TEXT NOT NULL,
  weight REAL NOT NULL,
  reps INTEGER NOT NULL,
  date TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (profileId) REFERENCES profiles(id) ON DELETE CASCADE,
  FOREIGN KEY (exerciseId) REFERENCES exercises(id) ON DELETE CASCADE
)
```

## Installation & Setup

### Prerequisites
- Flutter SDK 3.24.3+
- Android Studio with SDK 34
- Java 11+
- Android device or emulator

### Step 1: Clone/Extract Project
```bash
cd "path/to/Gym tracker project"
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Enable Developer Mode (Android Device)
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times until "Developer Mode" is enabled
3. Go to **Settings** → **Developer Options**
4. Enable **USB Debugging**

### Step 4: Connect Device
Connect your Android device via USB cable.

## Building & Running

### Run Debug Version
```bash
flutter run
```

Or specify device:
```bash
flutter run -d SM-S908E
```

### Build Release APK
```bash
flutter build apk --release
```

APK will be generated at: `build/app/outputs/flutter-app/release/app-release.apk`

### Install APK on Device (No USB Connection)
```bash
adb install build/app/outputs/flutter-app/release/app-release.apk
```

Then run the app from your device's app drawer.

## Usage Guide

### Creating Your First Profile
1. Launch the app
2. Tap **Create New Profile**
3. Enter your name (2+ characters, no duplicates)
4. Tap **Create**

### Logging a Workout Set
1. Select a profile
2. Tap a muscle category
3. Select an exercise
4. Enter weight (kg) and reps
5. Optionally add notes
6. Tap **Log Set**

### Adding a Custom Exercise
1. In a category, tap **Add an Exercise**
2. Fill in exercise name (required)
3. Enter description (optional)
4. Add YouTube video ID (optional)
5. Set default weight and reps
6. Tap **Create**

### Viewing Set History
- In exercise detail screen, scroll to **Recent Sets**
- Shows last 10 logged sets
- Tap the delete icon to remove a set

### Switching Profiles
1. From home screen, tap the **Switch Account** icon (top-right)
2. Select a different profile or create a new one
3. Exercise logs automatically filter by selected profile

### Editing Custom Exercises
1. In category view, tap the edit icon on a custom exercise
2. Modify details
3. Tap **Update**

### Deleting Custom Exercises
1. In category view, tap the delete icon on a custom exercise
2. Confirm deletion

## Data Privacy & Storage

- All data is stored **locally on your device** using SQLite
- No data is sent to cloud services or external servers
- Each profile has isolated workout data (sets from one profile won't appear in another's logs)
- Uninstalling the app will delete all data (backup not included)

## Troubleshooting

### Build Fails with "Java Version" Error
**Error**: "source value 8 is obsolete"
**Solution**: Ensure Java 11+ is installed. Check `android/app/build.gradle` has:
```gradle
sourceCompatibility = JavaVersion.VERSION_11
targetCompatibility = JavaVersion.VERSION_11
```

### Build Fails with "AAR Metadata" Error
**Error**: "requires Android SDK 34"
**Solution**: Update Android Gradle Plugin. Check `android/settings.gradle` has:
```gradle
com.android.application version 8.3.0 or higher
```

### App Crashes on Startup
**Solution**:
1. Clear app data: Settings → Apps → Gym Tracker → Clear Cache/Data
2. Reinstall the app
3. Re-open to reinitialize database

### Sets Not Appearing in Different Profile
This is **expected behavior** - each profile has its own isolated workout logs.

### Can't Create New Profile with Same Name
**Expected behavior** - duplicate profile names are prevented. Choose a different name.

## Future Enhancements

- YouTube video integration for exercise demonstrations
- Statistics and progress tracking
- Export workout data to CSV
- Cloud backup and sync
- Offline data sync when connection available
- Rest timer between sets
- Workout templates and plans
- Social features (share routines)

## Performance Notes

- App is optimized for offline use
- SQLite queries are indexed for fast searches
- UI remains responsive with 1000+ logged sets
- Memory efficient with streamed data loading

## Support

For issues or feature requests, email deepakjave@gmail.com

---

**Last Updated**: January 2026
**Version**: 1.0 (with Multi-Profile Support)
