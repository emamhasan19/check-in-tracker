# Check-In Tracker Application

A Flutter application that provides location-based check-in functionality with real-time check-in tracking, check-in management, and user authentication using Google Maps and Firebase with Clean Architecture implementation.

## 🚀 Features

- **Interactive Map Interface**: Users can view and interact with Google Maps showing check-in points and their current location
- **Real-time Check-in System**: Check in and out of designated locations with automatic radius validation
- **Check-In Management**: Create, manage, and participate in location-based events with custom radius settings
- **User Authentication**: Secure login/logout system with Firebase Authentication
- **Location Services**: Current location detection with comprehensive permission handling
- **Auto-logout Monitoring**: Automatic check-out when users move outside designated areas
- **Event Discovery**: Browse and join events created by other users
- **Real-time Updates**: Live updates of check-in status and event participants

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

### Architecture Layers

- **Presentation Layer** (`lib/src/presentation/`): UI components, state management using Riverpod, and navigation
- **Domain Layer** (`lib/src/domain/`): Business logic, entities, use cases, and repository interfaces
- **Data Layer** (`lib/src/data/`): Repository implementations, data models, and external services
- **Core Layer** (`lib/src/core/`): Base classes, utilities, dependency injection, and configuration

### Key Benefits

- ✅ **Separation of Concerns**: UI logic separated from business logic and data access
- ✅ **Testability**: Each layer can be tested independently
- ✅ **Maintainability**: Clear structure makes code easier to understand and modify
- ✅ **Scalability**: Easy to add new features following the same pattern
- ✅ **Dependency Inversion**: High-level modules don't depend on low-level modules

## 📋 Prerequisites

Before running this project, ensure you have:

- **Flutter SDK**: Version 3.8.1 or higher
- **Dart SDK**: Compatible with Flutter version
- **Android Studio** or **VS Code** with Flutter extensions
- **Google Maps API Key**: Required for map functionality
- **Firebase Project**: Required for authentication and data storage
- **Android SDK**: For Android development
- **Xcode**: For iOS development (macOS only)

## ��️ Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd check_in_tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable **Authentication** and **Firestore Database**
4. Configure authentication methods (Email/Password recommended)

#### Android Configuration

1. Add your app to the Firebase project
2. Download `google-services.json` from Firebase Console
3. Place it in `android/app/google-services.json`

#### iOS Configuration

1. Add your iOS app to the Firebase project
2. Download `GoogleService-Info.plist` from Firebase Console
3. Add it to `ios/Runner/GoogleService-Info.plist` in Xcode

### 4. Google Maps API Key Setup

#### Android
Add your API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

#### iOS
Add your API key to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

### 5. Generate Code

Run the build runner to generate necessary files:
```bash
flutter packages pub run build_runner build
```

### 6. Run the Application

```bash
flutter run
```

## 🔧 Dependencies

### Core Dependencies

- **`flutter_riverpod`**: State management and dependency injection
- **`go_router`**: Navigation and routing
- **`google_maps_flutter`**: Google Maps integration
- **`location`**: Location services and GPS functionality
- **`permission_handler`**: Permission management for location access
- **`firebase_core`**: Firebase core functionality
- **`cloud_firestore`**: NoSQL database for storing check-in data
- **`firebase_auth`**: User authentication
- **`google_fonts`**: Custom font support
- **`logger`**: Logging utilities

### Development Dependencies

- **`build_runner`**: Code generation
- **`freezed`**: Immutable data classes
- **`riverpod_annotation`**: Code generation for Riverpod
- **`flutter_lints`**: Code quality and style enforcement

## 🗂️ Project Structure

lib/
├── main.dart # Application entry point
├── src/
│ ├── core/ # Core functionality
│ │ ├── base/ # Base classes and interfaces
│ │ ├── constants/ # Application constants
│ │ ├── di/ # Dependency injection
│ │ └── logger/ # Logging utilities
│ ├── data/ # Data layer
│ │ ├── models/ # Data models
│ │ ├── repositories/ # Repository implementations
│ │ └── services/ # External services
│ ├── domain/ # Domain layer
│ │ ├── entities/ # Business entities
│ │ ├── repositories/ # Repository interfaces
│ │ └── use_cases/ # Business logic use cases
│ └── presentation/ # Presentation layer
│ ├── core/ # Core UI components
│ │ ├── theme/ # App theming
│ │ └── widgets/ # Common widgets
│ └── features/ # Feature-specific UI
│ └── map/ # Map feature
│ ├── riverpod/ # State management
│ ├── utils/ # Map utilities
│ ├── view/ # Map page
│ └── widgets/ # Map-specific widgets
*
This is the complete README file that you can copy and paste directly into your project. It includes all the sections, features, setup instructions, and documentation specific to your Check-in Tracker application.



## �� Usage

### User Authentication

1. **Sign Up**: Create a new account with email and password
2. **Sign In**: Log in with existing credentials
3. **Sign Out**: Securely log out from the application

### Check-In System

1. **View Map**: See all available check-in points on the interactive map
2. **Check In**: Tap on a check-in point to check in (must be within radius)
3. **Check Out**: Tap the check-out button when leaving the area
4. **Auto-logout**: Automatically checked out when moving outside the designated radius

### Check-In Management

1. **Create Event**: Tap the "+" button to create a new check-in event
2. **Set Location**: Choose the event location by tapping on the map
3. **Configure Settings**: Set event name, radius, and other parameters
4. **Manage Events**: View, edit, or delete your created events
5. **Join Events**: Browse and participate in events created by others

### Location Services

1. **Permission Handling**: Automatic location permission requests with user-friendly dialogs
2. **Current Location**: Use the location button to center the map on your current position
3. **Map Controls**: Zoom in/out, pan, and interact with the map view
4. **Real-time Updates**: Live location tracking and status updates

## 🔐 Security Features

### Authentication & Authorization

- **Firebase Authentication**: Secure user authentication with email/password
- **User Session Management**: Automatic session handling and token refresh
- **Permission-based Access**: Role-based access control for different features

### Data Security

- **Firestore Security Rules**: Database-level security rules for data protection
- **Input Validation**: Comprehensive validation of user inputs
- **Location Privacy**: Secure handling of location data with user consent

### Security Best Practices

- ✅ User authentication required for all operations
- ✅ Location data encrypted in transit
- ✅ Secure API key management (Secret Gradle Plugin)
- ✅ Input sanitization and validation
- ✅ Proper error handling without data exposure

## 🚀 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release
```

## 🔧 Troubleshooting

### Common Issues

#### Firebase Configuration
- Ensure `google-services.json` and `GoogleService-Info.plist` are properly placed
- Check Firebase project configuration and enabled services
- Verify authentication methods are enabled in Firebase Console

#### Location Permissions
- Ensure location permissions are granted in device settings
- Check that location services are enabled
- Verify app has necessary permissions in manifest files

#### Google Maps Issues
- Ensure valid Google Maps API key is configured
- Check API key restrictions and billing settings
- Verify Maps SDK is enabled for your project

#### Build Errors
- Run `flutter clean` and `flutter pub get`
- Ensure all dependencies are compatible
- Check Flutter and Dart SDK versions
- Run `flutter packages pub run build_runner build` for code generation

## �� Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Modern browsers with WebGL support (limited functionality)
- **Desktop**: Windows, macOS, and Linux (experimental)

## 🎯 Key Features Explained

### Real-time Check-in System
- **Radius Validation**: Users must be within a specified radius to check in
- **Automatic Monitoring**: Continuous location monitoring while checked in
- **Auto-logout**: Automatic check-out when leaving the designated area
- **Status Tracking**: Real-time updates of check-in status

### Check-In Management
- **Custom Events**: Create location-based events with custom parameters
- **Participant Tracking**: See who's checked into each event
- **Event Discovery**: Browse and join events created by other users
- **Real-time Updates**: Live participant count and status updates

### Location Services
- **Permission Handling**: Comprehensive location permission management
- **Background Monitoring**: Location tracking even when app is backgrounded
- **Accuracy Control**: Configurable location accuracy and update intervals
- **Privacy Protection**: User consent and data protection measures

## 📊 Performance Features

- **Efficient State Management**: Riverpod for optimal performance
- **Lazy Loading**: On-demand loading of map data and events
- **Caching**: Intelligent caching of frequently accessed data
- **Background Optimization**: Efficient background location tracking
- **Memory Management**: Proper cleanup of resources and listeners

## 📱 App Screenshots

## 📱 App Screenshots

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/92eaeaf1-e48a-4606-bb16-d02e90fb1d49" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/8a1cf32f-b095-4e08-b197-b90a5e387acb" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/03c07baf-259d-477e-88ca-cf9c6197d83b" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/f6f2a953-32bf-44e5-a2cc-9ff9e2130ec4" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/73179350-60bd-4f36-92bb-e825f5427e97" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/fc013cfa-9e3f-4b52-8103-84cdea77b666" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/90e30b45-0d32-4747-864f-c74000a280b8" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/a3911b46-6c23-44b1-a93e-e16bdb4cf2b6" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/d8ef97e1-0333-44a8-b648-e15d1c408be2" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/e13257ab-7aa1-4b87-86bd-68c9781e8ca5" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/8eac82df-b2a3-452f-9ac4-e7e36be83c24" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/7f5cf388-5cfc-4919-a902-fbf9e23db3d3" width="200"/></td>
  </tr>
</table>



**Note**: This application requires a valid Google Maps API key and Firebase project to function. Please ensure you have proper API key and Firebase setup before running the application.
