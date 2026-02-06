# Gym Tracker App - Testing Guide

## Quick Start Testing

### Build Status: 🔨 Building...
Currently building the app for testing. Check the progress below.

## Test Plan Overview

### Test Environment Setup

**Devices Available:**
- ✅ Android Emulator (Pixel 5)
- ✅ Chrome Web Browser
- ✅ Windows Desktop (requires Visual Studio)
- ✅ iOS Simulator (requires macOS)

**Build Commands:**
```bash
# Windows Desktop
flutter run -d windows

# Android Emulator
flutter emulators --launch Pixel_5
flutter run -d android

# Chrome Web
flutter run -d chrome

# Physical Android Device
flutter run -d <device_id>
```

## Test Scenarios

### 1. App Launch Test ✅
**Expected:** App loads without crashes

**Steps:**
1. Run app with `flutter run -d chrome`
2. App should display profile selection screen
3. UI should be responsive

**Pass Criteria:**
- ✅ No crashes during startup
- ✅ Profile selection screen visible
- ✅ App is responsive

---

### 2. Profile Management Test ✅
**Expected:** Users can create and manage profiles

**Steps:**
1. Tap "Create New Profile"
2. Enter profile name (e.g., "John")
3. Tap "Create"
4. Verify profile appears in list
5. Tap to select profile
6. Verify profile name shows in home screen

**Pass Criteria:**
- ✅ Profile creation works
- ✅ Profile selection works
- ✅ Profile name displays correctly
- ✅ No duplicate profile names allowed

---

### 3. Home Screen Navigation Test ✅
**Expected:** Users can navigate categories

**Steps:**
1. From home screen, verify 7 muscle categories visible:
   - Chest 💪
   - Shoulders 🏋️
   - Back 🔙
   - Biceps 💪
   - Triceps 💪
   - Legs 🦵
   - Core/Abs 🎯
2. Tap any category
3. Should navigate to category screen with exercises

**Pass Criteria:**
- ✅ All 7 categories displayed
- ✅ Category icons visible
- ✅ Tapping navigates to category detail
- ✅ Back button returns to home

---

### 4. Exercise Listing Test ✅
**Expected:** Exercises display with search/filter

**Steps:**
1. Select any category (e.g., Chest)
2. Verify exercises list displays
3. Verify each exercise shows name and description
4. Try search bar - search for "press"
5. Verify results filter correctly

**Pass Criteria:**
- ✅ Exercises load for category
- ✅ Search filters exercises
- ✅ Pre-defined exercises present (5+ per category)
- ✅ Can add custom exercise

---

### 5. Workout Set Logging Test ✅
**Expected:** Users can log workout sets

**Steps:**
1. From category, select an exercise (e.g., Bench Press)
2. Enter Weight: 60 kg
3. Enter Reps: 8
4. Optionally add notes (e.g., "felt strong")
5. Tap "Log Set"
6. Verify success message shows
7. Verify set appears in "Recent Sets"

**Pass Criteria:**
- ✅ Form validation works (requires weight & reps)
- ✅ Set logged successfully
- ✅ Success notification shown
- ✅ Set appears in recent sets list
- ✅ Correct weight and reps display

---

### 6. Recent Sets Display Test ✅
**Expected:** Workout history displays correctly

**Steps:**
1. Log 5 sets for same exercise with different weights/reps
2. Scroll to "Recent Sets" section
3. Verify sets display in reverse chronological order (newest first)
4. Verify each set shows:
   - Weight × Reps
   - Date/Time
   - Notes (if added)
5. Tap delete icon on a set
6. Confirm deletion
7. Verify set removed from list

**Pass Criteria:**
- ✅ Last 10 sets display
- ✅ Newest first ordering
- ✅ Date/time formats correctly
- ✅ Delete functionality works
- ✅ Confirmation dialog appears

---

### 7. **NEW** Progress Screen Test ✅
**Expected:** View overall progress for all exercises

**Steps:**
1. From home screen, tap Progress button (📊 icon, top-right)
2. Should display all exercises with stats
3. Verify each exercise shows:
   - PR (Personal Record) weight
   - Total sets count
   - Average weight
4. Tap category filter chips
5. Verify list filters by category
6. Tap any exercise to see detailed progress

**Pass Criteria:**
- ✅ Progress screen loads
- ✅ All exercises displayed with stats
- ✅ PR calculated correctly (max weight)
- ✅ Set count accurate
- ✅ Category filtering works
- ✅ No crashes when viewing

---

### 8. **NEW** Exercise Progress Detail Test ✅
**Expected:** View detailed charts and statistics

**Steps:**
1. From Progress screen, tap any exercise (e.g., Bench Press)
2. Detailed progress screen should display
3. Verify line chart is visible
4. Tap "Weight" tab - chart should show weight progression
5. Tap "Reps" tab - chart should show reps progression
6. Tap "Volume" tab - chart should show tonnage progression
7. Adjust slider from 5 to 50 sets
8. Verify chart updates with correct data range
9. Scroll down to view statistics section
10. Verify displays:
    - PR Weight (e.g., "60.0 kg")
    - PR Reps (e.g., "10 reps")
    - Average Weight
    - Average Reps
    - Total Volume
    - Total Sets
    - Last Workout date

**Pass Criteria:**
- ✅ Charts render without errors
- ✅ Weight/Reps/Volume tabs work
- ✅ Data limit slider functions
- ✅ Chart updates when sliding
- ✅ All statistics calculated correctly
- ✅ Formatting is readable (e.g., "60.0 kg")

---

### 9. **NEW** Progress Stats in Exercise Detail Test ✅
**Expected:** Quick stats visible in exercise logging screen

**Steps:**
1. From category, select an exercise
2. Below exercise description, look for "Your Progress" card
3. Card should show:
   - PR weight (e.g., "65.0 kg")
   - Total sets (e.g., "10 sets")
   - "View Details" button
4. Tap "View Details" button
5. Should navigate to detailed progress screen

**Pass Criteria:**
- ✅ Progress card visible
- ✅ PR calculated correctly
- ✅ Set count accurate
- ✅ "View Details" button navigates to progress detail
- ✅ Returns to exercise detail when back

---

### 10. Profile Isolation Test ✅
**Expected:** Each profile has separate workout data

**Steps:**
1. Create Profile A, log 5 sets for Bench Press
2. Switch profile: tap switch account button (top-right)
3. Create Profile B
4. View Bench Press progress in Profile B
5. Verify it shows "No data" or empty
6. Log sets in Profile B
7. Switch back to Profile A
8. Verify Profile A shows original 5 sets
9. Switch to Profile B
10. Verify Profile B shows newly logged sets

**Pass Criteria:**
- ✅ Each profile has isolated data
- ✅ Switching profiles shows correct data
- ✅ Progress metrics don't mix between profiles
- ✅ No data leakage between profiles

---

### 11. Edge Cases Test ✅
**Expected:** App handles edge cases gracefully

**Test 11.1: Single Set**
1. Log 1 set for an exercise
2. View progress detail
3. Verify no division by zero errors
4. Verify chart displays single point
5. Verify average equals single value

**Test 11.2: No Data**
1. Select an exercise with no logged sets
2. Tap "View Progress"
3. Verify shows "No data available" message
4. Verify no crashes

**Test 11.3: Large Dataset**
1. Log 50+ sets for same exercise
2. View progress detail
3. Adjust slider to 50 sets
4. Verify chart renders without lag
5. Verify statistics calculate correctly

**Pass Criteria:**
- ✅ No crashes with edge cases
- ✅ Proper error messages display
- ✅ UI remains responsive
- ✅ Calculations handle edge cases

---

### 12. Data Persistence Test ✅
**Expected:** Data persists after app restart

**Steps:**
1. Log 3 workout sets
2. Close app completely
3. Reopen app
4. Select same profile
5. View same exercise
6. Verify all 3 sets still appear
7. Verify progress metrics unchanged

**Pass Criteria:**
- ✅ Data persists in SQLite
- ✅ Sets recover after restart
- ✅ Progress metrics recalculate correctly
- ✅ No data loss

---

### 13. Calculation Accuracy Test ✅
**Expected:** All calculations are mathematically correct

**Test Data:**
- Set 1: 60 kg × 8 reps = 480 volume
- Set 2: 65 kg × 10 reps = 650 volume
- Set 3: 62 kg × 9 reps = 558 volume

**Verify:**
1. PR Weight = 65 kg ✅
2. PR Reps = 10 ✅
3. Avg Weight = (60+65+62)/3 = 62.33 kg ✅
4. Avg Reps = (8+10+9)/3 = 9 ✅
5. Total Volume = 480+650+558 = 1688 kg ✅
6. Total Sets = 3 ✅

**Pass Criteria:**
- ✅ All calculations accurate to 2 decimals
- ✅ No rounding errors
- ✅ Charts display exact values

---

### 14. Performance Test ✅
**Expected:** App responds quickly

**Steps:**
1. Log 100+ sets for various exercises
2. Navigate between screens
3. Measure response times:
   - Progress screen load: <2 seconds
   - Exercise detail load: <1 second
   - Chart render: <1 second
   - Filter category: <500ms

**Pass Criteria:**
- ✅ No UI freezing
- ✅ Charts render smoothly
- ✅ Scrolling is smooth
- ✅ No memory warnings

---

### 15. UI/UX Test ✅
**Expected:** App is intuitive and visually consistent

**Steps:**
1. Verify color scheme consistency (deepPurple primary)
2. Verify all buttons are clickable
3. Verify text is readable
4. Verify icons are clear
5. Verify spacing/padding consistent
6. Verify no overlapping elements
7. Verify proper error messages
8. Verify loading states (spinners) show

**Pass Criteria:**
- ✅ Consistent design throughout
- ✅ All interactive elements respond
- ✅ Good visual hierarchy
- ✅ Professional appearance

---

## Test Execution Checklist

- [ ] Build succeeds without errors
- [ ] App launches on device/emulator
- [ ] No crashes during testing
- [ ] All scenarios pass
- [ ] Edge cases handled
- [ ] Performance is acceptable
- [ ] UI looks professional
- [ ] Data persists
- [ ] Calculations are accurate
- [ ] Profile isolation works

## Known Limitations

1. Windows desktop requires Visual Studio
2. iOS requires macOS
3. Physical Android device requires USB debugging enabled
4. Some features may perform differently on web vs native

## Build Command Reference

```bash
# Setup
flutter pub get

# Development/Testing
flutter run -d chrome          # Web (fastest for testing)
flutter run -d android         # Android emulator
flutter run -d windows         # Windows desktop

# Build for distribution
flutter build apk --release    # Android APK
flutter build web              # Web build
flutter build windows          # Windows executable
```

## Troubleshooting

**Build Fails:**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

**App Crashes:**
- Check logcat: `adb logcat`
- Run with verbose: `flutter run -v`

**Emulator Issues:**
```bash
flutter emulators
flutter emulators --launch Pixel_5
```

---

**Test Date:** February 6, 2026
**Build Version:** 1.0.0 with Progress Tracking
**Status:** Ready for Testing
