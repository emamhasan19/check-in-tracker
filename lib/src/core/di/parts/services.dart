part of '../dependency_injection.dart';

@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) {
  return LocationService();
}

@Riverpod(keepAlive: true)
FirebaseService firebaseService(Ref ref) {
  return FirebaseService();
}

