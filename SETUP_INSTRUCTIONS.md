# Check-in Tracker - Firebase Setup Instructions

## Overview
This Flutter app allows users to create check-in points and enables other users to check in only if they are within a specified radius of the location. The app uses Firebase Firestore for data storage and real-time updates.

## Firebase Console Setup

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `check-in-tracker` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Add Android App
1. In your Firebase project, click "Add app" and select Android
2. Enter your Android package name (found in `android/app/build.gradle.kts`):
   ```
   com.example.check_in_tracker
   ```
3. Enter app nickname: `Check-in Tracker Android`
4. Download the `google-services.json` file
5. Place it in `android/app/google-services.json`

### 3. Add iOS App (Optional)
1. Click "Add app" and select iOS
2. Enter your iOS bundle ID (found in `ios/Runner/Info.plist`):
   ```
   com.example.checkInTracker
   ```
3. Enter app nickname: `Check-in Tracker iOS`
4. Download the `GoogleService-Info.plist` file
5. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Enable Authentication
1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable "Anonymous" authentication
3. Click "Save"

### 5. Create Firestore Database
1. Go to "Firestore Database" in Firebase Console
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

### 6. Set Up Firestore Security Rules
1. Go to "Firestore Database" → "Rules"
2. Replace the default rules with the content from `firestore.rules` file in this project:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Check-in Points collection
    match /checkinPoints/{docId} {
      // Allow read access to everyone (for checking active points)
      allow read: if true;
      // Allow write access to authenticated users only
      allow write: if request.auth != null;
    }
    
    // Check-ins collection
    match /checkins/{docId} {
      // Allow read access to everyone (for live user counts)
      allow read: if true;
      // Allow write access only if:
      // 1. User is authenticated
      // 2. User is writing their own check-in data
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click "Publish"

### 7. Enable Location Services (Android)
1. In `android/app/src/main/AndroidManifest.xml`, add these permissions:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### 8. Enable Location Services (iOS)
1. In `ios/Runner/Info.plist`, add these permissions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to check in at specific locations.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track your check-in status in the background.</string>
```

## Running the App

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run on Android
```bash
flutter run
```

### 4. Run on iOS
```bash
flutter run -d ios
```

## App Features

### Organizer Mode
- Create check-in points at current location
- Set radius for check-in area
- Only one active check-in point at a time
- View all check-in points
- Toggle active status
- Delete check-in points
- See live user count

### User Mode
- View active check-in point
- Check in if within radius
- Check out when leaving
- See live user count
- Background location tracking (Android only)

## Data Structure

### Check-in Points Collection (`checkinPoints`)
```json
{
  "name": "Meeting Room A",
  "lat": 23.8103,
  "lng": 90.4125,
  "radiusMeters": 50,
  "active": true,
  "activeCount": 5
}
```

### Check-ins Collection (`checkins`)
```json
{
  "userId": "user123",
  "pointId": "point456",
  "checkedInAt": "2024-01-01T10:00:00Z",
  "checkedOutAt": null,
  "lastLocation": {
    "lat": 23.8105,
    "lng": 90.4127,
    "ts": "2024-01-01T10:30:00Z"
  }
}
```

## Security Notes

- This is a prototype implementation
- Distance validation is done client-side (not secure for production)
- Single active point enforcement is client-side
- For production, implement server-side validation using Cloud Functions

## Troubleshooting

### Common Issues

1. **Location permission denied**
   - Check device settings
   - Ensure permissions are properly configured in manifest/plist

2. **Firebase connection issues**
   - Verify `google-services.json` is in correct location
   - Check internet connection
   - Verify Firebase project configuration

3. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Regenerate code with `dart run build_runner build --delete-conflicting-outputs`

4. **Background location not working**
   - Background location is Android-only
   - Check WorkManager permissions
   - Verify location services are enabled

## Production Considerations

1. Implement server-side distance validation
2. Add proper user authentication (not anonymous)
3. Implement role-based access control
4. Add data validation and sanitization
5. Implement proper error handling and logging
6. Add offline support
7. Implement push notifications
8. Add analytics and monitoring
