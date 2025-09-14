import 'dart:async';
import 'dart:math' as math;

import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();
  StreamController<LocationData>? _locationController;

  Future<bool> hasLocationPermission() async {
    try {
      final permission = await _location.hasPermission();
      return permission == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await _location.requestPermission();
      return permission == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _location.serviceEnabled();
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestLocationService() async {
    try {
      return await _location.requestService();
    } catch (e) {
      return false;
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        final serviceRequested = await requestLocationService();
        if (!serviceRequested) {
          print('LocationService: Location service could not be enabled');
          return null;
        }
      }

      // Check permission
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        final permissionGranted = await requestLocationPermission();
        if (!permissionGranted) {
          print('LocationService: Location permission denied');
          return null;
        }
      }

      // Get location with timeout
      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('LocationService: Location request timed out');
          throw TimeoutException(
            'Location request timed out',
            const Duration(seconds: 15),
          );
        },
      );

      // Validate location data
      if (locationData.latitude == null || locationData.longitude == null) {
        print('LocationService: Invalid location data received');
        return null;
      }

      // Check if location is reasonable (not 0,0)
      if (locationData.latitude == 0.0 && locationData.longitude == 0.0) {
        print('LocationService: Received invalid coordinates (0,0)');
        return null;
      }

      print(
        'LocationService: Successfully obtained location: ${locationData.latitude}, ${locationData.longitude}',
      );
      return locationData;
    } catch (e) {
      print('LocationService: Error getting location: $e');
      return null;
    }
  }

  Future<bool> isLocationAvailable() async {
    try {
      final hasPermission = await hasLocationPermission();
      final serviceEnabled = await isLocationServiceEnabled();
      return hasPermission && serviceEnabled;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      final permission = await _location.hasPermission();
      return permission == PermissionStatus.deniedForever;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPermissionDenied() async {
    try {
      final permission = await _location.hasPermission();
      return permission == PermissionStatus.denied;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPermissionLimited() async {
    try {
      final permission = await _location.hasPermission();
      return permission ==
          PermissionStatus.granted; // Simplified for location package
    } catch (e) {
      return false;
    }
  }

  // Calculate distance between two points using Haversine formula
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = _degreesToRadians(endLatitude - startLatitude);
    final double dLon = _degreesToRadians(endLongitude - startLongitude);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLatitude)) *
            math.cos(_degreesToRadians(endLatitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Location stream functionality
  Stream<LocationData>? get locationStream => _locationController?.stream;

  Future<bool> startLocationStream({
    double distanceFilter = 10.0, // meters
    Duration interval = const Duration(seconds: 30),
  }) async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        final serviceRequested = await requestLocationService();
        if (!serviceRequested) {
          return false;
        }
      }

      // Check permission
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        final permissionGranted = await requestLocationPermission();
        if (!permissionGranted) {
          return false;
        }
      }

      // Initialize stream controller if not already done
      _locationController ??= StreamController<LocationData>.broadcast();

      // Configure location settings
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        interval: interval.inMilliseconds,
      );

      // Start listening to location changes
      _location.onLocationChanged.listen(
        (LocationData locationData) {
          _locationController?.add(locationData);
        },
        onError: (error) {
          _locationController?.addError(error);
        },
      );

      return true;
    } catch (e) {
      _locationController?.addError(e);
      return false;
    }
  }

  void stopLocationStream() {
    _locationController?.close();
    _locationController = null;
  }

  void dispose() {
    stopLocationStream();
  }
}
